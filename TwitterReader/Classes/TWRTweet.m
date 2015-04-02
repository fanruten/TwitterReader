//
//  TWRTweet.m
//  TwitterReader
//
//  Created by Ruslan Gumennyi on 08/12/14.
//  Copyright (c) 2014 e-legion. All rights reserved.
//

#import "TWRTweet.h"
#import "NSString+Utils.h"

@interface TWRTweet ()

@property (nonatomic, copy) NSNumber *tweetID;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *profileImageURL;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *screenName;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, copy) NSString *photoURL;
@property (nonatomic, assign) CGSize photoSize;

@end

@implementation TWRTweet

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        self.tweetID = dictionary[@"id"];
        self.text = dictionary[@"text"];
        self.profileImageURL = dictionary[@"user"][@"profile_image_url_https"];
        self.createdAt = [dictionary[@"created_at"] twr_dateFromTwitterJSONString];
        self.username = dictionary[@"user"][@"name"];
        self.screenName = dictionary[@"user"][@"screen_name"];
        
        NSArray *media = dictionary[@"entities"][@"media"];
        for (NSDictionary *mediaInfo in media) {
            if ([mediaInfo[@"type"] isEqual:@"photo"]) {
                self.photoURL = mediaInfo[@"media_url"];
                NSNumber *width = mediaInfo[@"sizes"][@"medium"][@"w"];
                NSNumber *height = mediaInfo[@"sizes"][@"medium"][@"h"];
                self.photoSize = CGSizeMake([width floatValue], [height floatValue]);
            }
        }
    }
    return self;
}

+ (TWRTweet *)tweetWithDictionary:(NSDictionary *)dictionary
{
    return [[self alloc] initWithDictionary:dictionary];
}

+ (NSArray *)tweetsWithDictionaryArray:(NSArray *)array
{
    NSMutableArray *tweets = [NSMutableArray new];
    [array enumerateObjectsUsingBlock:^(NSDictionary *tweetInfo, NSUInteger idx, BOOL *stop) {
        TWRTweet *tweet = [TWRTweet tweetWithDictionary:tweetInfo];
        [tweets addObject:tweet];
    }];
    return tweets;
}

@end
