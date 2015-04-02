//
//  TWRFeedViewController.m
//  TwitterReader
//
//  Created by Ruslan Gumennyi on 04/12/14.
//  Copyright (c) 2014 e-legion. All rights reserved.
//

#import "TWRFeedViewController.h"
#import "TWRTweetsDataSource.h"
#import "TWRAlert.h"
#import "TWRTweetCollectionViewCell.h"
#import "TWRActivityCollectionViewCell.h"
#import "NSObject+Utils.h"

typedef NS_ENUM(NSInteger, TWRFeedViewControllerMode) {
    TWRFeedViewControllerMode_Table,
    TWRFeedViewControllerMode_Mosaic
};

@interface TWRFeedViewController () <TWRTweetsDataSourceDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *feedCollectionView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *modeSegmentControl;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *accountButton;
@property (nonatomic, weak) UIRefreshControl *refreshControl;

@property (nonatomic, strong) TWRTweetsDataSource *tweetsDataSource;
@property (nonatomic, strong) NSError *loadMoreError;

@property (nonatomic, assign) TWRFeedViewControllerMode mode;

@end

@implementation TWRFeedViewController

#pragma mark - UIViewController 

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self.feedCollectionView.delegate = self;
    self.feedCollectionView.dataSource = self;
    
    self.mode = TWRFeedViewControllerMode_Table;

    [self setupPullToRefresh];
    [self loadFeedForSavedUser];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    
    [self.feedCollectionView.collectionViewLayout invalidateLayout];
}

- (void)loadFeedForSavedUser
{
    NSString *userID = [[NSUserDefaults standardUserDefaults] stringForKey:@"userID"];
    if (userID.length) {
        [self accountsListWithCompletionBlock:^(NSArray *accounts, NSError *error) {
            if (!error) {
                for (ACAccount *account in accounts) {
                    if ([account.identifier isEqual:userID]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self setupDataSourceWithAccount:account];
                        });
                        return;
                    }
                };
            }
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"userID"];
        }];
    }
}

#pragma mark - Helpers

- (void)setupPullToRefresh
{
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl = refreshControl;
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(refershControlAction) forControlEvents:UIControlEventValueChanged];
    [self.feedCollectionView addSubview:refreshControl];
    self.feedCollectionView.alwaysBounceVertical = YES;
    self.feedCollectionView.bounces = YES;
}

- (void)setMode:(TWRFeedViewControllerMode)mode
{
    _mode = mode;
    [self.feedCollectionView.collectionViewLayout invalidateLayout];
}

- (void)setupDataSourceWithAccount:(ACAccount *)account;
{
    TWRTweetsDataSource *dataSource = [[TWRTweetsDataSource alloc] initWithAccount:account];
    dataSource.delegate = self;
    self.tweetsDataSource = dataSource;
    
    [self.feedCollectionView performBatchUpdates:^{
        [self.feedCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    } completion:nil];
    
    [self.refreshControl beginRefreshing];
    [self.feedCollectionView setContentOffset:CGPointMake(0, self.feedCollectionView.contentOffset.y - self.refreshControl.frame.size.height)
                                     animated:YES];
    [self.tweetsDataSource loadNewTweets];
}

- (void)accountsListWithCompletionBlock:(void(^)(NSArray *accounts, NSError *error))completionBlock
{
    ACAccountStore *accountStore = [ACAccountStore new];
    ACAccountType *twitterAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore
     requestAccessToAccountsWithType:twitterAccountType
     options:NULL
     completion:^(BOOL granted, NSError *error) {
         if (granted) {
             NSArray *accounts =[accountStore accountsWithAccountType:twitterAccountType];
             if (accounts.count) {
                 completionBlock(accounts, nil);
             } else {
                 completionBlock(nil, [NSError twr_errorWithLocalizedDescription:@"Add Twitter account in\nSettings->Twitter"]);
             }
         } else {
             completionBlock(nil, [NSError twr_errorWithLocalizedDescription:@"Enable access to Twitter account in\nSettings->Privacy->Twitter"]);
         }
     }];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    TWRAlert *accountsAlert = [[TWRAlert alloc] initWithTitle:title
                                                      message:message
                                                         type:TWRAlertType_Alert
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:nil
                                             clickButotnBlock:nil];
    [accountsAlert showInController:self withBarButtonItem:nil];
}

#pragma mark - TWRTweetsDataSourceDelegate

- (void)tweetsDataSourceLoadNewTweets:(TWRTweetsDataSource *)dataSource withError:(NSError *)error;
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshControl endRefreshing];
        if (error) {
            [self showAlertWithTitle:@"Error" message:error.localizedDescription];
        } else {
            [self.feedCollectionView performBatchUpdates:^{
                [self.feedCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
            } completion:nil];
        }
    });
}

- (void)tweetsDataSourceLoadOldTweets:(TWRTweetsDataSource *)dataSource withError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.loadMoreError = error;
        [self.feedCollectionView performBatchUpdates:^{
            [self.feedCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        } completion:nil];
    });
    
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.tweetsDataSource.items ? self.tweetsDataSource.items.count + 1 : 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.tweetsDataSource.items.count && self.tweetsDataSource.canLoadMore && !self.loadMoreError) {
        self.loadMoreError = nil;
        [self.tweetsDataSource loadOldTweets];
    }
    
    NSInteger itemIndex;
    if (indexPath.row == self.tweetsDataSource.items.count) {
        TWRActivityCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[TWRActivityCollectionViewCell reuseIdentifier]
                                                                                    forIndexPath:indexPath];
        if (self.loadMoreError) {
            NSString *message = [NSString stringWithFormat:@"%@\nTap to retry.", self.loadMoreError.localizedDescription];
            [cell showMessage:message];
        } else if (self.tweetsDataSource.canLoadMore) {
            [cell showActivity];
        } else {
            [cell showMessage:@"No more tweets."];
        }
        return cell;
    } else {
        itemIndex = indexPath.row;
    }
    
    TWRTweetCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[TWRTweetCollectionViewCell reuseIdentifier]
                                                                           forIndexPath:indexPath];
    TWRTweet *tweet = self.tweetsDataSource.items[itemIndex];
    [cell configureWithTweet:tweet];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.tweetsDataSource.items.count && self.tweetsDataSource.canLoadMore) {
        self.loadMoreError = nil;
        TWRActivityCollectionViewCell *activityCell = (TWRActivityCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        [activityCell showActivity];
        [self.tweetsDataSource loadOldTweets];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width;
    const CGFloat kSpacing = 5.0f;
    if (self.mode == TWRFeedViewControllerMode_Table) {
        width = collectionView.frame.size.width - kSpacing * 2;
    } else {
        const NSInteger kTweetPerLine = 4;
        width = (collectionView.frame.size.width - kSpacing * 2) / kTweetPerLine - kSpacing * 2;
        width = MAX(width, 150.0f);
    }
    
    // size for "load more" cell
    if (indexPath.row >= self.tweetsDataSource.items.count) {
        return CGSizeMake(width, 80.0f);
    }
    
    NSInteger itemIndex = indexPath.row;
    TWRTweet *tweet = self.tweetsDataSource.items[itemIndex];
    
    CGFloat height = [TWRTweetCollectionViewCell heightForTweet:tweet cellWidth:width];
    return CGSizeMake(width, height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section;
{
    return UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f);
}

#pragma mark - Actions

- (IBAction)refershControlAction
{
    if (self.tweetsDataSource) {
        [self.tweetsDataSource loadNewTweets];
    } else {
        [self.refreshControl endRefreshing];
        [self showAlertWithTitle:@"Attention" message:@"Select Account"];
    }
}

- (IBAction)modeSegmentControlValueChanged:(id)sender
{
    if (self.modeSegmentControl.selectedSegmentIndex == 0) {
        self.mode = TWRFeedViewControllerMode_Table;
    } if (self.modeSegmentControl.selectedSegmentIndex == 1){
        self.mode = TWRFeedViewControllerMode_Mosaic;
    }
}

- (IBAction)accountButtonTapped:(id)sender
{
    Weakify(self);
    [self accountsListWithCompletionBlock:^(NSArray *accounts, NSError *error) {
        Strongify(self);
        if (!error) {
            NSMutableArray *buttons = [NSMutableArray new];
            [accounts enumerateObjectsUsingBlock:^(ACAccount *account, NSUInteger idx, BOOL *stop) {
                [buttons addObject:account.username];
            }];
            
            TWRAlert *accountsAlert = [[TWRAlert alloc] initWithTitle:nil
                                                              message:@"Select account"
                                                                 type:TWRAlertType_ActionSheet
                                                    cancelButtonTitle:@"Cancel"
                                                    otherButtonTitles:buttons
                                                     clickButotnBlock:^(TWRAlert *alert, NSInteger clickedButtonIndex) {
                                                         if (clickedButtonIndex != -1) {
                                                             ACAccount *selectedAccount = accounts[clickedButtonIndex];
                                                             [[NSUserDefaults standardUserDefaults] setObject:selectedAccount.identifier forKey:@"userID"];
                                                             [self setupDataSourceWithAccount:selectedAccount];
                                                         }
                                                     }];
            [accountsAlert showInController:self withBarButtonItem:self.accountButton];
        } else {
            [self showAlertWithTitle:@"Attention" message:error.localizedDescription];
        }
    }];
}

@end
