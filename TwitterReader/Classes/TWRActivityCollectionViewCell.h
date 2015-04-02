//
//  TWRActivityCollectionViewCell.h
//  TwitterReader
//
//  Created by Ruslan Gumennyi on 09/12/14.
//  Copyright (c) 2014 e-legion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TWRActivityCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

+ (NSString *)reuseIdentifier;

- (void)showActivity;

- (void)showMessage:(NSString *)message;

@end
