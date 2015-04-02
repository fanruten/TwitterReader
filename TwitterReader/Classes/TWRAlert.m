//
//  TWRAlert.m
//  TwitterReader
//
//  Created by Ruslan Gumennyi on 08/12/14.
//  Copyright (c) 2014 e-legion. All rights reserved.
//

#import "TWRAlert.h"

@interface TWRRetainableActionSheet : UIActionSheet

@property (nonatomic, strong) TWRAlert *twrAlert;

@end

@implementation TWRRetainableActionSheet

@end


@interface TWRRetainableAlertView : UIAlertView

@property (nonatomic, strong) TWRAlert *twrAlert;

@end

@implementation TWRRetainableAlertView

@end


@interface TWRAlert () <UIActionSheetDelegate, UIAlertViewDelegate>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, assign) TWRAlertType type;
@property (nonatomic, copy) NSString *cancelButtonTitle;
@property (nonatomic, copy) NSArray *otherButtonTitles;

@end

@implementation TWRAlert

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                         type:(TWRAlertType)type
            cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSArray *)otherButtonTitles
             clickButotnBlock:(TWRAlertClickButtonBlock)clickButotnBlock
{
    self = [super init];
    if (self) {
        self.title = title;
        self.message = message;
        self.type = type;
        self.cancelButtonTitle = cancelButtonTitle;
        self.otherButtonTitles = [[NSArray alloc] initWithArray:otherButtonTitles copyItems:YES];
        self.clickButotnBlock = clickButotnBlock;
    }
    return self;
}

- (void)showInController:(UIViewController *)presentedViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if (NSClassFromString(@"UIAlertController")) {
            [self showAlertContrllerInController:presentedViewController withBarButtonItem:barButtonItem];
        } else {
            if (self.type == TWRAlertType_Alert) {
                [self showAlert];
            } else {
                [self showAtionSheetFromBarButtonItem:barButtonItem];
            }
        }
    }];
}

- (void)showAlert
{
    TWRRetainableAlertView *alert = [[TWRRetainableAlertView alloc] initWithTitle:self.title
                                                                          message:self.message
                                                                         delegate:self
                                                                cancelButtonTitle:self.cancelButtonTitle
                                                                otherButtonTitles:nil];
    alert.twrAlert = self;
    
    [self.otherButtonTitles enumerateObjectsUsingBlock:^(NSString *buttonTitle, NSUInteger idx, BOOL *stop) {
        [alert addButtonWithTitle:buttonTitle];
    }];
    
    [alert show];
}

- (void)showAtionSheetFromBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    TWRRetainableActionSheet *actionSheet = [TWRRetainableActionSheet new];
    actionSheet.twrAlert = self;
    actionSheet.title = self.message;
    actionSheet.delegate = self;
    
    [self.otherButtonTitles enumerateObjectsUsingBlock:^(NSString *buttonTitle, NSUInteger idx, BOOL *stop) {
        [actionSheet addButtonWithTitle:buttonTitle];
    }];
    actionSheet.destructiveButtonIndex = [actionSheet addButtonWithTitle:self.cancelButtonTitle];
    
    [actionSheet showFromBarButtonItem:barButtonItem animated:YES];
}

- (void)showAlertContrllerInController:(UIViewController *)presentedViewController
                     withBarButtonItem:(UIBarButtonItem *)barButtonItem
{

    UIAlertControllerStyle style = (self.type == TWRAlertType_Alert) ? UIAlertControllerStyleAlert : UIAlertControllerStyleActionSheet;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:self.title
                                                                             message:self.message
                                                                      preferredStyle:style];
    
    [self.otherButtonTitles enumerateObjectsUsingBlock:^(NSString *buttonTitle, NSUInteger idx, BOOL *stop) {
        UIAlertAction* alertAction = [UIAlertAction actionWithTitle:buttonTitle
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action) {
                                                                if (self.clickButotnBlock) {
                                                                    self.clickButotnBlock(self, idx);
                                                                }
                                                            }];
        [alertController addAction:alertAction];
    }];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:self.cancelButtonTitle
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * action) {
                                                              if (self.clickButotnBlock) {
                                                                  self.clickButotnBlock(self, -1);
                                                              }
                                                          }];
    [alertController addAction:defaultAction];
    alertController.popoverPresentationController.barButtonItem = barButtonItem;
    
    [presentedViewController presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(TWRRetainableActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSInteger convertedIndex;
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        convertedIndex = -1;
    } else {
        convertedIndex = buttonIndex;
    }
    if (self.clickButotnBlock) {
        self.clickButotnBlock(self, convertedIndex);
    }
}

- (void)actionSheet:(TWRRetainableActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    actionSheet.twrAlert = nil;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(TWRRetainableAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.clickButotnBlock) {
        self.clickButotnBlock(self, buttonIndex);
    }
}

- (void)alertView:(TWRRetainableAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    alertView.twrAlert = nil;
}

@end
