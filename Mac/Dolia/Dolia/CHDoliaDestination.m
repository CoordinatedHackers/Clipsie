
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

- (void)offerData:(NSData *)data
{
    NSOutputStream *outputStream;
    if ([self.service getInputStream:NULL outputStream:&outputStream]) {
        [CHStreamWriter writeData:data toStream:outputStream withCompletionBlock:^void (bool worked){
            NSLog(@"Hey, making an offer %s", worked ? "worked" : "didn't work");
        }];
    }
}

@end
