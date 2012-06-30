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
    
    return [super supportsMethod:method atPath:path];
}


-(NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
	id thingToSend;
    if ([method isEqualToString:@"GET"] && (thingToSend = [((SSAppDelegate*)[NSApp delegate]).offers objectForKey:path])) {
		if ([thingToSend isKindOfClass:[NSURL class]]) {
			if ([thingToSend isFileURL]) {
				return [[HTTPFileResponse alloc] initWithFilePath:[thingToSend path] forConnection:self];
			}
		}
	}
    
    return [super httpResponseForMethod:method URI:path];
}

@end
