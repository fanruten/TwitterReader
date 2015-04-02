//
//  TWRImageCacheContextManager.m
//  TwitterReader
//
//  Created by Ruslan Gumennyi on 12/12/14.
//  Copyright (c) 2014 e-legion. All rights reserved.
//

#import "TWRImageCacheContextManager.h"

@interface TWRImageCacheContextManager ()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation TWRImageCacheContextManager {
    
}

+ (instancetype)sharedInstance
{
    static TWRImageCacheContextManager *contextManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        contextManager = [TWRImageCacheContextManager new];
    });
    return contextManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.queue = dispatch_queue_create("TWRImageCacheContextManagerQueue",  DISPATCH_QUEUE_SERIAL);
        [self cleanUp];
    }
    return self;
}

- (TWRImageCacheEntity *)cachedImageForURL:(NSString *)imageURL
{
    __block TWRImageCacheEntity *cachedImage;
    Weakify(self);
    dispatch_sync(self.queue, ^{
        Strongify(self);
        NSFetchRequest *fetchRequest = [NSFetchRequest new];
        NSEntityDescription *entity = [NSEntityDescription entityForName:[TWRImageCacheEntity entityNameInModel]
                                                  inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"imageURL == %@", imageURL];
        [fetchRequest setPredicate:predicate];
        
        NSError *error;
        NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if (result.count) {
            cachedImage = result[0];
            cachedImage.data = [NSData dataWithContentsOfFile:[self pathForImagesWithPhotoURL:cachedImage.imageURL]];
            if (!cachedImage.data) {
                [self.managedObjectContext deleteObject:cachedImage];
                [self saveContext];
                cachedImage = nil;
            }
        }
    });
    
    return cachedImage;
}

- (void)saveCacheForURL:(NSURL *)mURL response:(NSURLResponse *)response data:(NSData *)data
{
    Weakify(self);
    dispatch_async(self.queue, ^{
        Strongify(self);
        TWRImageCacheEntity *cacheEntity = [NSEntityDescription insertNewObjectForEntityForName:[TWRImageCacheEntity entityNameInModel]
                                                                         inManagedObjectContext:self.managedObjectContext];
        cacheEntity.imageURL = mURL.absoluteString;
        cacheEntity.timestamp = [NSDate date];
        cacheEntity.mimeType = response.MIMEType;
        
        NSError *error;
        [self.managedObjectContext save:&error];
        if (!error) {
            [self saveContext];
            [data writeToFile:[self pathForImagesWithPhotoURL:cacheEntity.imageURL]
                      options:NSDataWritingAtomic
                        error:&error];
            if (error) {
                NSLog(@"Error on writeToFile: %@", error);
            }
        } else {
            NSLog(@"Error in saveCacheForURL: %@", error);
        }
    });
}

#pragma mark - Helpers

- (void)cleanUp
{
    Weakify(self);
    dispatch_async(self.queue, ^{
        Strongify(self);
        NSFetchRequest *fetchRequest = [NSFetchRequest new];
        NSEntityDescription *entity = [NSEntityDescription entityForName:[TWRImageCacheEntity entityNameInModel]
                                                  inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit ) fromDate:[NSDate date]];
        [components setDay:-3];
        
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setDay:-1];
        NSDate *lastValidDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:[NSDate date] options:0];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"timestamp < %@", lastValidDate];

        [fetchRequest setPredicate:predicate];
        
        NSError *error;
        NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        [result enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self.managedObjectContext deleteObject:obj];
        }];
        [self saveContext];
    });
}

- (void)saveContext
{
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges]) {
            NSError *error = nil;
            [managedObjectContext save:&error];
            if (error) {
                NSLog(@"Error on saving context: %@", error);
            }
        }
    }
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSString *)pathForImagesWithPhotoURL:(NSString *)photoURL
{
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[photoURL twr_MS5String]];
    return filePath;
}

#pragma mark - Core Data

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TWRImageCacheContextManager" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"TWRImageCacheContextManager.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:nil
                                                           error:&error]) {
        NSLog(@"Error in addPersistentStoreWithType: %@", error);
        abort();
    }
    
    return self.persistentStoreCoordinator;
}
                               
@end
