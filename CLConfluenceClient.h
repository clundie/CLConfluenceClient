//
//  CLConfluenceClient.h
//  Confluence client
//
//  Created by Chris Lundie on 09/Apr/2012.
//  Copyright (c) 2012 Chris Lundie. All rights reserved.
//


@class GTMHTTPFetcher;


#import <Foundation/Foundation.h>


extern NSString * const CLConfluenceClientErrorDomain;
extern const NSInteger kCLConfluenceClientInvalidServerResponseError;


@interface CLConfluenceClient : NSObject

/**
 Designated initializer.
 
 \param baseURL Base URL of your server. For example, <https://confluence.example.com>. Must not be nil.
 */
- (id)initWithBaseURL:(NSURL *)baseURL;

- (void)setPassword:(NSString *)password;

/**
 Perform a search.
 */
- (GTMHTTPFetcher *)searchQuery:(NSString *)query completionHandler:(void(^)(NSError *error, NSArray *result))completionHandler;

@property (copy) NSString *username;
@property (copy, readonly) NSURL *baseURL;

@end
