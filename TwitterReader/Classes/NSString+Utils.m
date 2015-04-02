//
//  NSString+Utils.m
//  TwitterReader
//
//  Created by Ruslan Gumennyi on 11/12/14.
//  Copyright (c) 2014 e-legion. All rights reserved.
//

#import "NSString+Utils.h"

#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Utils)

- (NSDate *)twr_dateFromTwitterJSONString
{
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"eee MMM dd HH:mm:ss ZZZZ yyyy"];
    });
    return [dateFormatter dateFromString:self];
}

- (NSString *)twr_MS5String
{
    const char *str = [self UTF8String] ?: "";
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *hash = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    return hash;
}

@end
