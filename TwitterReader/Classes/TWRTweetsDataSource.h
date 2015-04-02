//
//  TWRTweetsDataSource.h
//  TwitterReader
//
//  Created by Ruslan Gumennyi on 04/12/14.
//  Copyright (c) 2014 e-legion. All rights reserved.
//

#import <Foundation/Foundation.h>

@import Social;
@import Accounts;

@class TWRTweetsDataSource;

@protocol TWRTweetsDataSourceDelegate <NSObject>

@optional

- (void)tweetsDataSourceLoadNewTweets:(TWRTweetsDataSource *)dataSource withError:(NSError *)error;

- (void)tweetsDataSourceLoadOldTweets:(TWRTweetsDataSource *)dataSource withError:(NSError *)error;

@end

@interface TWRTweetsDataSource : NSObject

@property (nonatomic, readonly, copy) NSArray *items;
@property (nonatomic, readonly, strong) ACAccount *twitterAccount;
@property (nonatomic, readonly, assign) BOOL canLoadMore;
@property (nonatomic, readonly, assign) BOOL isLoading;

@property (nonatomic, weak) id<TWRTweetsDataSourceDelegate> delegate;

- (instancetype)initWithAccount:(ACAccount *)account;

- (void)loadNewTweets;

- (void)loadOldTweets;

@end
