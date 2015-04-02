//
//  TWRImageCacheContextManager.h
//  TwitterReader
//
//  Created by Ruslan Gumennyi on 12/12/14.
//  Copyright (c) 2014 e-legion. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "TWRImageCacheEntity.h"

@interface TWRImageCacheContextManager : NSObject

+ (instancetype)sharedInstance;

- (TWRImageCacheEntity *)cachedImageForURL:(NSString *)imageURL;

- (void)saveCacheForURL:(NSURL *)mURL response:(NSURLResponse *)response data:(NSData *)data;
    
@end
