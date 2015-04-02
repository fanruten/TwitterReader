//
//  TWRTweetCollectionViewCell.m
//  TwitterReader
//
//  Created by Ruslan Gumennyi on 08/12/14.
//  Copyright (c) 2014 e-legion. All rights reserved.
//

#import "TWRTweetCollectionViewCell.h"

@interface TWRTweetCollectionViewCell ()

@end

@implementation TWRTweetCollectionViewCell

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass(self);
}

+ (CGFloat)heightForTweet:(TWRTweet *)tweet cellWidth:(CGFloat)cellWidth
{
    UITextView *textView = [UITextView new];
    textView.text = tweet.text;
    textView.font = [UIFont systemFontOfSize:14.0f];
    
    CGFloat textViewWidth = cellWidth - 8 * 2;
    CGSize tweetTextViewSize = [textView sizeThatFits:CGSizeMake(textViewWidth, CGFLOAT_MAX)];
    
    CGFloat contentHeight = tweetTextViewSize.height;
    if (tweet.photoSize.height) {
        CGFloat ratio = tweet.photoSize.height / tweet.photoSize.width;
        contentHeight += textViewWidth * ratio + 8;
    }
    
    return contentHeight + 50 + 34 + 8;
}

- (NSString *)stringForDate:(NSDate *)date
{
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"dd-MM-YYYY\nH:mm:ss"];
    });
    return [dateFormatter stringFromDate:date];
}

- (void)configureWithTweet:(TWRTweet *)tweet
{
    self.avatarImageView.layer.cornerRadius = 5.0f;
    self.avatarImageView.layer.masksToBounds = YES;

    self.layer.cornerRadius = 3.0f;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = self.tintColor.CGColor;
    
    self.tweetTextView.text = tweet.text;
    self.tweetTextView.font = [UIFont systemFontOfSize:14.0f];
    CGFloat textViewWidth = self.frame.size.width - 8 * 2;
    CGSize tweetTextViewSize = [self.tweetTextView sizeThatFits:CGSizeMake(textViewWidth, CGFLOAT_MAX)];
    self.textViewHeightConstraint.constant = tweetTextViewSize.height;
    
    self.usernameLabel.text = [NSString stringWithFormat:@"@%@\n%@", tweet.screenName, tweet.username];
    self.dateLabel.text = [self stringForDate:tweet.createdAt];
    
    self.photoImageView.image = nil;
    self.avatarImageView.image = nil;
    
    [self.photoImageView twr_loadImageWithURL:tweet.photoURL];
    self.photoImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.avatarImageView  twr_loadImageWithURL:tweet.profileImageURL];
}

@end
