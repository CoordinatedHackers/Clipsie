//
//  CHDoliaListener.m
//  Dolia
//
//  Created by Sidney San Martín on 5/3/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

#import "CHDoliaListener.h"
#import "CHStreamInterface.h"

@implementation CHDoliaListener

- (id)init
{
    if ((self = [super init])) {
        self.service = [[NSNetService alloc] initWithDomain:@""
                                                       type:@"_dolia._tcp"
                                                       name:@""
                                                       port:0];
        self.service.delegate = self;
    }
    return self;
}

- (void)start
{
    [self.service publishWithOptions:NSNetServiceListenForConnections];
}

- (void)stop
{
    [self.service stop];
}

- (void)netService:(NSNetService *)sender didAcceptConnectionWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream
{
    [CHStreamReader readFromStream:inputStream withCompletionBlock:^void (NSData *data) {
        CHDoliaOffer *offer = [CHDoliaOffer deserializeWithData:data];
        if (offer) {
            offer.received = [NSDate date];
            [self.delegate gotOffer:offer];
        }
    }];
}

@end
