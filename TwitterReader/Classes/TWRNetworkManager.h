//
//  TWRNetworkManager.h
//  TwitterReader
//
//  Created by Ruslan Gumennyi on 09/12/14.
//  Copyright (c) 2014 e-legion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TWRNetworkManager : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong) NSURLSession *session;

@end
