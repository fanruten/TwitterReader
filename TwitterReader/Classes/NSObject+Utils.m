//
//  NSObject+Utils.m
//  TwitterReader
//
//  Created by Ruslan Gumennyi on 09/12/14.
//  Copyright (c) 2014 e-legion. All rights reserved.
//

#import "NSObject+Utils.h"

static NSString * const kTWRErrorDomain = @"TWRErrorDomain";

@implementation NSObject (Utils)

+ (NSString *)twr_defaultDomain
{
    return kTWRErrorDomain;
}

+ (NSError *)twr_errorWithLocalizedDescription:(NSString *)localizedDescription
{
    return [NSError errorWithDomain:[self twr_defaultDomain]
                               code:0
                           userInfo:@{
                                      NSLocalizedDescriptionKey : localizedDescription ?: @""
                                      }];
}

@end
