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
        [self.service publishWithOptions:NSNetServiceListenForConnections];
    }
    return self;
}

- (void)netService:(NSNetService *)sender didAcceptConnectionWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream
{
    [CHStreamReader readFromStream:inputStream withCompletionBlock:^void (NSData *data) {
        NSDictionary *pbData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if (pbData) {
            NSPasteboard *pb = [NSPasteboard generalPasteboard];
            [pb clearContents];
            for (NSString *key in pbData) {
                NSData *data = [[NSData alloc] initWithBase64EncodedString:[pbData objectForKey:key] options:0];
                [pb setData:data forType:key];
            }
        }
    }];
}

@end
