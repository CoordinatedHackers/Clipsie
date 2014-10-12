//
//  CHClipsieDestination.m
//  Clipsie
//
//  Created by Sidney San Martín on 5/7/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

#import "CHClipsieDestination.h"

@implementation CHClipsieDestination

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

- (void)sendOffer:(CHClipsieOffer *)offer
{
    NSOutputStream *outputStream;
    if ([self.service getInputStream:NULL outputStream:&outputStream]) {
        [CHStreamWriter writeData:offer.data toStream:outputStream withCompletionBlock:^void (){}];
    }
}

@end
