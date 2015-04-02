//
//  TWRTweetsDataSource.m
//  TwitterReader
//
//  Created by Ruslan Gumennyi on 04/12/14.
//  Copyright (c) 2014 e-legion. All rights reserved.
//

#import "TWRTweetsDataSource.h"
#import "TWRTweet.h"

static const NSUInteger kTWRTweetsPerPage = 60;
static NSString * const kTWRTwitterHomeTimelineURL = @"https://api.twitter.com/1.1/statuses/home_timeline.json";


@interface TWRTweetsDataSource ()

@property (nonatomic, copy) NSArray *items;
@property (nonatomic, strong) ACAccount *twitterAccount;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL canLoadMore;

@end

@implementation TWRTweetsDataSource

- (instancetype)initWithAccount:(ACAccount *)account
{
    self = [super init];
    if (self) {
        self.twitterAccount = account;
        self.canLoadMore = YES;
    }
    
    return self;
}

- (void)loadNewTweets
{
    @synchronized(self) {
        if (!self.isLoading) {
            self.isLoading = YES;
            TWRTweet *recentTweet = [self.items firstObject];
            
            Weakify(self);
            [self loadWithTwitterAccount:self.twitterAccount
                                 sinceID:recentTweet.tweetID
                                   maxID:nil
                     withCompletionBlock:^(NSArray *items, NSError *error) {
                         Strongify(self);
                         if (!error) {
                             NSMutableArray *tmpItems = [NSMutableArray arrayWithArray:items];
                             [tmpItems addObjectsFromArray:self.items];
                             self.items = tmpItems;
                         }
                         
                         if ([self.delegate respondsToSelector:@selector(tweetsDataSourceLoadNewTweets:withError:)]) {
                             [self.delegate tweetsDataSourceLoadNewTweets:self withError:error];
                         }
                         
                         self.isLoading = NO;
                     }];
        }
    }
}

- (void)loadOldTweets
{
    @synchronized(self) {
        if (!self.isLoading) {
            self.isLoading = YES;
            TWRTweet *oldestTweet = self.items.lastObject;
            
            Weakify(self);
            [self loadWithTwitterAccount:self.twitterAccount
                                   sinceID:nil
                                   maxID:oldestTweet.tweetID
                     withCompletionBlock:^(NSArray *items, NSError *error) {
                         Strongify(self);
                         if (!error) {
                             NSMutableArray *tmpItems = [NSMutableArray arrayWithArray:self.items];
                             [tmpItems addObjectsFromArray:items];
                             self.items = tmpItems;
                             self.canLoadMore = items.count;
                         }
                         
                         if ([self.delegate respondsToSelector:@selector(tweetsDataSourceLoadOldTweets:withError:)]) {
                             [self.delegate tweetsDataSourceLoadOldTweets:self withError:error];
                         }
                         
                         self.isLoading = NO;
                     }];
        }
    }
}

#pragma mark - Helpers

- (void)loadWithTwitterAccount:(ACAccount *)account
                       sinceID:(NSNumber *)sinceID
                         maxID:(NSNumber *)maxID
           withCompletionBlock:(void (^)(NSArray *items, NSError *error))completionBlock
{
    NSMutableDictionary *params = ({
        NSMutableDictionary *tmpParams = [NSMutableDictionary new];
        tmpParams[@"exclude_replies"] = @"0";
        tmpParams[@"trim_user"] = @"0";
        tmpParams[@"count"] = [@(kTWRTweetsPerPage) stringValue];
        if (sinceID) {
            tmpParams[@"since_id"] = [sinceID stringValue];
        }
        if (maxID) {
            tmpParams[@"max_id"] = [@([maxID longValue] - 1) stringValue] ;
        }
        tmpParams;
    });
    
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                            requestMethod:SLRequestMethodGET
                                                      URL:[NSURL URLWithString:kTWRTwitterHomeTimelineURL]
                                               parameters:params];
    [request setAccount:self.twitterAccount];
    [request performRequestWithHandler:^(NSData *responseData,
                                         NSHTTPURLResponse *urlResponse,
                                         NSError *error) {
        if (error) {
            completionBlock(nil, error);
            return;
        }
        
        // Look https://dev.twitter.com/overview/api/response-codes
        if (urlResponse.statusCode == 200) {
            NSError *jsonError;
            NSArray *timelineData = [NSJSONSerialization
                                     JSONObjectWithData:responseData
                                     options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (jsonError) {
                NSString *errorDescription = [NSString stringWithFormat:@"JSON Error: %@", [jsonError localizedDescription]];
                completionBlock(nil, [NSError twr_errorWithLocalizedDescription:errorDescription]);
            } else {
                NSArray *tweets = [TWRTweet tweetsWithDictionaryArray:timelineData];
                completionBlock(tweets, nil);
            }
        }
        else {
            NSString *errorDescription = [NSString stringWithFormat:@"API error (response status code is %ld)", (long)urlResponse.statusCode];
            completionBlock(nil, [NSError twr_errorWithLocalizedDescription:errorDescription]);
        }
    }];
}

@end
