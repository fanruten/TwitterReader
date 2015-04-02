//
//  TWRTweetCollectionViewCell.h
//  TwitterReader
//
//  Created by Ruslan Gumennyi on 08/12/14.
//  Copyright (c) 2014 e-legion. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TWRTweet.h"

@interface TWRTweetCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UITextView *tweetTextView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeightConstraint;

+ (NSString *)reuseIdentifier;

+ (CGFloat)heightForTweet:(TWRTweet *)tweet cellWidth:(CGFloat)cellWidth;

- (void)configureWithTweet:(TWRTweet *)tweet;

@end
