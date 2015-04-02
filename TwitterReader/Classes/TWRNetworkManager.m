//
//  TWRNetworkManager.m
//  TwitterReader
//
//  Created by Ruslan Gumennyi on 09/12/14.
//  Copyright (c) 2014 e-legion. All rights reserved.
//

#import "TWRNetworkManager.h"
#import "TWRImagesCacheProtocol.h"

@implementation TWRNetworkManager

+ (instancetype)sharedInstance
{
    static TWRNetworkManager *networkManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkManager = [TWRNetworkManager new];
    });
    return networkManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.protocolClasses = @[[TWRImagesCacheProtocol class]];
        self.session = [NSURLSession sessionWithConfiguration:configuration];
    }
    return self;
}

@end
