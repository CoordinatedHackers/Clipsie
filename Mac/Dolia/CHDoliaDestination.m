
//  CHDoliaDestination.m
//  Dolia
//
//  Created by Sidney San Martín on 5/7/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

#import "CHDoliaDestination.h"

@implementation CHDoliaDestination

- (id)initWithService:(NSNetService*)service
{
    if ((self = [super init])) {
        self.service = service;
    }
    return self;
}

- (NSString *)name
{
    return self.service.name;
}

- (void)offerJSON:(id)obj
{
    NSOutputStream *outputStream;
    if (![self.service getInputStream:NULL outputStream:&outputStream]) {
        return;
    }
    [outputStream open];
    [NSJSONSerialization writeJSONObject:obj toStream:outputStream options:0 error:NULL];
    [outputStream close];
}

@end
