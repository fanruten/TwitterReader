//
//  NSString+Utils.h
//  TwitterReader
//
//  Created by Ruslan Gumennyi on 11/12/14.
//  Copyright (c) 2014 e-legion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Utils)

- (NSDate *)twr_dateFromTwitterJSONString;

- (NSString *)twr_MS5String;

@end
