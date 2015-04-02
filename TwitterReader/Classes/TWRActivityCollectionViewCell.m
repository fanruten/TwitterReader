//
//  TWRActivityCollectionViewCell.m
//  TwitterReader
//
//  Created by Ruslan Gumennyi on 09/12/14.
//  Copyright (c) 2014 e-legion. All rights reserved.
//

#import "TWRActivityCollectionViewCell.h"

@interface TWRActivityCollectionViewCell ()

@end

@implementation TWRActivityCollectionViewCell

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass(self);
}

- (void)showActivity
{
    self.messageLabel.hidden = YES;
    self.activityIndicatorView.hidden = NO;
    [self.activityIndicatorView startAnimating];
}

- (void)showMessage:(NSString *)message
{
    self.messageLabel.text = message;
    self.messageLabel.hidden = NO;
    self.activityIndicatorView.hidden =YES;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.layer.cornerRadius = 3.0f;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 1.0f;
        self.layer.borderColor = self.tintColor.CGColor;
        
        self.activityIndicatorView.hidden = YES;
        self.messageLabel.hidden = YES;
    }
    return self;
}

@end
