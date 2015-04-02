//
//  TWRAlert.h
//  TwitterReader
//
//  Created by Ruslan Gumennyi on 08/12/14.
//  Copyright (c) 2014 e-legion. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TWRAlert;

typedef void (^TWRAlertClickButtonBlock)(TWRAlert *alert, NSInteger clickedButtonIndex);

typedef NS_ENUM(NSInteger, TWRAlertType) {
    TWRAlertType_Alert,
    TWRAlertType_ActionSheet
};

@interface TWRAlert : NSObject

@property (nonatomic, strong) TWRAlertClickButtonBlock clickButotnBlock;

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                         type:(TWRAlertType)type
            cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSArray *)otherButtonTitles
             clickButotnBlock:(TWRAlertClickButtonBlock)clickButotnBlock;

- (void)showInController:(UIViewController *)presentedViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem;

@end
