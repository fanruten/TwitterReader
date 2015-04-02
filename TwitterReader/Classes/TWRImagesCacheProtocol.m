//
//  TWRHomeTimelineCacheProtocol.m
//  TwitterReader
//
//  Created by Ruslan Gumennyi on 11/12/14.
//  Copyright (c) 2014 e-legion. All rights reserved.
//

#import "TWRImagesCacheProtocol.h"
#import "TWRImageCacheContextManager.h"


@interface TWRImagesCacheProtocol ()

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSMutableData *responseData;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation TWRImagesCacheProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    id marker = [NSURLProtocol propertyForKey:[self protocolMaker]
                                    inRequest:request];
    return !marker;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

+ (NSString *)protocolMaker
{
    return NSStringFromClass(self);
}

- (void)startLoading
{
    TWRImageCacheEntity *cachedImage = [[TWRImageCacheContextManager sharedInstance] cachedImageForURL:self.request.URL.absoluteString];
    if (cachedImage) {
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:self.request.URL
                                                            MIMEType:cachedImage.mimeType
                                               expectedContentLength:cachedImage.data.length
                                                    textEncodingName:nil];
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [self.client URLProtocol:self didLoadData:cachedImage.data];
        [self.client URLProtocolDidFinishLoading:self];
    } else {
        NSMutableURLRequest *mURLRequest = [self.request mutableCopy];
        [NSURLProtocol setProperty:[TWRImagesCacheProtocol protocolMaker]
                            forKey:[TWRImagesCacheProtocol protocolMaker]
                         inRequest:mURLRequest];
        self.connection = [[NSURLConnection alloc] initWithRequest:[mURLRequest copy]
                                                      delegate:self startImmediately:NO];
        [self.connection start];
    }
}

- (void)stopLoading
{
    [self.connection cancel];
}

#pragma mark - NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
    [[self client] URLProtocol:self didLoadData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.response = response;
    self.responseData = [NSMutableData new];
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
    if (redirectResponse) {
        [[self client] URLProtocol:self wasRedirectedToRequest:request redirectResponse:redirectResponse];
    }
    return request;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [[TWRImageCacheContextManager sharedInstance] saveCacheForURL:self.request.URL
                                                         response:self.response
                                                             data:self.responseData];
    [[self client] URLProtocolDidFinishLoading:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [[self client] URLProtocol:self didFailWithError:error];
}

#pragma mark Connection Authentication

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    [[self client] URLProtocol:self didCancelAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    [[self client] URLProtocol:self didReceiveAuthenticationChallenge:challenge];
}

@end

