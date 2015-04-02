//
//  NSObject+Utils.h
//  TwitterReader
//
//  Created by Ruslan Gumennyi on 09/12/14.
//  Copyright (c) 2014 e-legion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Utils)

+ (NSString *)twr_defaultDomain;

+ (NSError *)twr_errorWithLocalizedDescription:(NSString *)localizedDescription;

@end
