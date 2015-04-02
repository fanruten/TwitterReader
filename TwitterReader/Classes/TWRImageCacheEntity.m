//
//  TWRImageCacheEntity.m
//  TwitterReader
//
//  Created by Ruslan Gumennyi on 12/12/14.
//  Copyright (c) 2014 e-legion. All rights reserved.
//

#import "TWRImageCacheEntity.h"

@implementation TWRImageCacheEntity

@dynamic imageURL;
@dynamic mimeType;
@dynamic timestamp;

@synthesize data;

+ (NSString *)entityNameInModel
{
    return NSStringFromClass([self class]);
}
@end