//
//  CLConfluenceClient.m
//  Confluence client
//
//  Created by Chris Lundie on 09/Apr/2012.
//  Copyright (c) 2012 Chris Lundie. All rights reserved.
//


#import "CLConfluenceClient.h"
#import "GTMHTTPFetcher.h"
#import "NSData+Base64.h"


NSString * const CLConfluenceClientErrorDomain = @"ca.lundie.CLConfluenceClient";
const NSInteger kCLConfluenceClientInvalidServerResponseError = 1;


@interface CLConfluenceClient ()
{
@private
    NSString *_password;
}

- (void)signRequest:(NSMutableURLRequest *)request;

@property (copy, readwrite) NSURL *baseURL;

@end


@implementation CLConfluenceClient

@synthesize username = _username;
@synthesize baseURL = _baseURL;

- (id)initWithBaseURL:(NSURL *)baseURL
{
    if (baseURL == nil) {
        [NSException raise:NSInvalidArgumentException format:@"baseURL cannot be nil"];
    }
    self = [super init];
    if (self != nil) {
        _baseURL = [baseURL copy];
    }
    return self;
}

- (void)setPassword:(NSString *)password
{
    _password = [password copy];
}

- (GTMHTTPFetcher *)searchQuery:(NSString *)query completionHandler:(void (^)(NSError *, NSArray *))completionHandler
{
	GTMHTTPFetcher *fetcher = nil;
	NSString *relativeURLStr = [NSString stringWithFormat:@"rest/prototype/1/search.json?query=%@", [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	NSURL *URL = [[NSURL alloc] initWithString:relativeURLStr relativeToURL:self.baseURL];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
    [self signRequest:request];
	fetcher = [[GTMHTTPFetcher alloc] initWithRequest:request];
	BOOL fetchStarted = [fetcher beginFetchWithCompletionHandler:^(NSData *fetchedData, NSError *fetchError) {
		if (fetchError != nil) {
			if (completionHandler != nil) {
				completionHandler(fetchError, nil);
			}
			return;
		}
		if (completionHandler != nil) {
			NSDictionary *obj = [NSJSONSerialization JSONObjectWithData:fetchedData options:0 error:NULL];
			if (![obj isKindOfClass:[NSDictionary class]]) {
				obj = nil;
			}
			NSArray *result = [obj objectForKey:@"result"];
			if (![result isKindOfClass:[NSArray class]]) {
				result = nil;
			}
			completionHandler(nil, result);
		}
	}];
	if (!fetchStarted) {
		fetcher = nil;
	}
	return fetcher;
}

- (void)signRequest:(NSMutableURLRequest *)request
{
	if ((self.username != nil) && (_password != nil)) {
        NSString *auth = [[[NSString stringWithFormat:@"%@:%@", self.username, _password] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString];
        [request setValue:[NSString stringWithFormat:@"Basic %@", auth] forHTTPHeaderField:@"Authorization"];
	}
}

@end
