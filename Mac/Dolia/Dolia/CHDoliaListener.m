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
    NSLog(@"gotz a connection");
    inputStream.delegate = self;
    [inputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [inputStream open];
    // - Handle getting an offer
    // - Give the offer to my delegate
}

- (void)stream:(NSInputStream *)stream handleEvent:(NSStreamEvent)streamEvent
{
    switch (streamEvent) {
        case NSStreamEventHasBytesAvailable:
            if (!self.data) {
                [stream read:(uint8_t *)&_length maxLength:2];
                self.data = [NSMutableData dataWithLength:self.length];
                self.position = 0;
                NSLog(@"Will read data of length: %d", self.length);
                
            }
            self.position += [stream read:([self.data mutableBytes]+self.position) maxLength:(self.length - self.position)];
            
            if (self.position == self.length) {
                [stream close];
                NSLog(@"We get data: %@", self.data);
                NSDictionary *pbData = [NSJSONSerialization JSONObjectWithData:self.data options:0 error:nil];
                if (pbData) {
                    NSPasteboard *pb = [NSPasteboard generalPasteboard];
                    [pb clearContents];
                    for (NSString *key in pbData) {
                        NSData *data = [[NSData alloc] initWithBase64EncodedString:[pbData objectForKey:key] options:0];
                        [pb setData:data forType:key];
                    }
                }
                self.data = nil;
            }
            break;
            
        default:
            NSLog(@"Some event, %ld", streamEvent);
            break;
    }
}

@end
