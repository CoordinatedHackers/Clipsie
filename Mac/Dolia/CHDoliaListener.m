//
//  CHDoliaListener.m
//  Dolia
//
//  Created by Sidney San Martín on 5/3/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

#import "CHDoliaListener.h"

@implementation CHDoliaListener

- (id)init
{
    if ((self = [super init])) {
        self.service = [[NSNetService alloc] initWithDomain:@""
                                                       type:@"_dolia._tcp"
                                                       name:@""
                                                       port:0];
        self.service.delegate = self;
        [self.service publishWithOptions:NSNetServiceListenForConnections];
    }
    return self;
}

- (void)netService:(NSNetService *)sender didAcceptConnectionWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream
{
    [inputStream open];
    NSDictionary *offerData = [NSJSONSerialization JSONObjectWithStream:inputStream options:0 error:nil];
    [inputStream close];
    if (!offerData) { return; }
    NSString *type = [offerData objectForKey:@"type"];
    if ([type isEqualToString:@"clipboard"]) {
        NSDictionary *pbData = [offerData objectForKey:@"data"];
        if (pbData) {
            [self.delegate gotOffer:[[CHDoliaClipboardOffer alloc] initWithData:pbData]];
        }
    } else {
        NSLog(@"Unknown offer type: %@", type);
    }
}

@end
