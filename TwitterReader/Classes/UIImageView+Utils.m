//
//  UIImageView+Utils.m
//  TwitterReader
//
//  Created by Ruslan Gumennyi on 12/12/14.
//  Copyright (c) 2014 e-legion. All rights reserved.
//

#import "UIImageView+Utils.h"
#import "TWRNetworkManager.h"

static char kTwrImageURLKey;

@interface UIImageView ()

@property (nonatomic, strong) NSString *twr_imageURL;

@end

@implementation UIImageView (Utils)

- (NSString *)twr_imageURL
{
    return objc_getAssociatedObject(self, &kTwrImageURLKey);
}

- (void)setTwr_imageURL:(NSString *)twr_imageURL
{
    objc_setAssociatedObject(self, &kTwrImageURLKey, twr_imageURL, OBJC_ASSOCIATION_COPY);
}

- (void)twr_loadImageWithURL:(NSString *)imageURL
{
    NSString *copyOfImageURL = [imageURL copy];
    self.twr_imageURL = copyOfImageURL;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]];
    NSURLSession *session = [TWRNetworkManager sharedInstance].session;
    Weakify(self);
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        Strongify(self);
                                                        if ([self.twr_imageURL isEqual:copyOfImageURL]) {
                                                            UIImage *image = [[UIImage alloc] initWithData:data scale:2.0f];
                                                            self.alpha = 0.0f;
                                                            self.image = image;
                                                            [UIView animateWithDuration:1.0f animations:^{
                                                                self.alpha = 1.0f;
                                                            }];
                                                            
                                                        }
                                                    });
                                                }];
    [dataTask resume];
}

@end
