//
//  SSDoliaHTTPConnection.m
//  Dolia
//
//  Created by Sam Epstein on 6/27/12.
//  Copyright (c) 2012 Sam and Sidney. All rights reserved.
//

#import "SSAppDelegate.h"
#import "SSDoliaHTTPConnection.h"
#import "HTTPMessage.h"
#import "HTTPDataResponse.h"
#import "HTTPFileResponse.h"


#import "HTTPLogging.h"

@implementation SSDoliaHTTPConnection : HTTPConnection

static const int httpLogLevel = HTTP_LOG_LEVEL_VERBOSE | HTTP_LOG_FLAG_TRACE;

-(BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path
{
    HTTPLogTrace();
    
	if ([path isEqualToString:@"/offer"]) {
		return [method isEqualToString:@"POST"];
	}
	return [super supportsMethod:method atPath:path];
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path
{
	HTTPLogTrace();
	
	// Inform HTTP server that we expect a body to accompany a POST request
	
	if([method isEqualToString:@"POST"])
		return YES;
	
	return [super expectsRequestBodyFromMethod:method atPath:path];
}

-(NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
	id thingToSend;
	if ([method isEqualToString:@"POST"] && [path isEqualToString:@"/offer"]) {
		NSString *post = [[NSString alloc] initWithData:[request body] encoding:NSUTF8StringEncoding];
		if (post) {
			NSLog(@"YO I GOT POST: %@", post);
		}
		return [[HTTPDataResponse alloc] initWithData:[NSData data]];
	} else if ([method isEqualToString:@"GET"] && (thingToSend = [((SSAppDelegate*)[NSApp delegate]).offers objectForKey:path])) {
		if ([thingToSend isKindOfClass:[NSURL class]]) {
			if ([thingToSend isFileURL]) {
				return [[HTTPFileResponse alloc] initWithFilePath:[thingToSend path] forConnection:self];
			}
		}
	}
    
    return [super httpResponseForMethod:method URI:path];
}

- (void)processBodyData:(NSData *)postDataChunk
{
	if ( ! [request appendData:postDataChunk]) {
		// This is some pretty minimal error handling right there
		HTTPLogError(@"%@[%p]: %@ - Couldn't append bytes!", THIS_FILE, self, THIS_METHOD);
	}
}

@end
