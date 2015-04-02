//
//  TWRTweet.h
//  TwitterReader
//
//  Created by Ruslan Gumennyi on 08/12/14.
//  Copyright (c) 2014 e-legion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>

@interface TWRTweet : NSObject

@property (nonatomic, readonly, copy) NSNumber *tweetID;
@property (nonatomic, readonly, copy) NSString *text;
@property (nonatomic, readonly, copy) NSString *profileImageURL;
@property (nonatomic, readonly, copy) NSString *username;
@property (nonatomic, readonly, copy) NSString *screenName;
@property (nonatomic, readonly, strong) NSDate *createdAt;
@property (nonatomic, readonly, copy) NSString *photoURL;
@property (nonatomic, readonly, assign) CGSize photoSize;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

+ (TWRTweet *)tweetWithDictionary:(NSDictionary *)dictionary;

+ (NSArray *)tweetsWithDictionaryArray:(NSArray *)array;

@end
