//
//  TWRImageCacheEntity.h
//  TwitterReader
//
//  Created by Ruslan Gumennyi on 12/12/14.
//  Copyright (c) 2014 e-legion. All rights reserved.
//

@import CoreData;

@interface TWRImageCacheEntity : NSManagedObject

@property (nonatomic, copy) NSString *imageURL;
@property (nonatomic, copy) NSString *mimeType;
@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic, strong) NSData *data;

+ (NSString *)entityNameInModel;

@end

