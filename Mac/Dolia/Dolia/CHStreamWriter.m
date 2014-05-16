//
//  CHStreamWriter.m
//  Dolia
//
//  Created by Sidney San Martín on 5/16/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

#import "CHStreamWriter.h"

@implementation CHStreamWriter

//+ (void)writeData:(NSData *)data toStream:(NSOutputStream *)stream withCompletionBlock:(void (^)(bool))block
//{
//    CHStreamWriter *writer = [CHStreamWriter new];
//    writer.data = data;
//    writer.stream = stream;
//    writer.completionBlock = ^void (bool worked) {
//        block(worked);
//    };
//    [writer write];
//}
//
- (id)initWithData:(NSData *)data stream:(NSOutputStream *)stream completionBlock:(void (^)(bool))block
{
    if ((self = [super init])) {
        self.data = data;
        self.stream = stream;
        self.completionBlock = block;
    }
    return self;
}

- (void)write
{
    self.stream.delegate = self;
    [self.stream open];
    [self.stream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent
{
    switch (streamEvent) {
        case NSStreamEventOpenCompleted:
            break;
        case NSStreamEventHasSpaceAvailable:
            NSLog(@"SPACE SPACE SPACE");
            self.position += [self.stream write:[self.data bytes] maxLength:(self.data.length - self.position)];
            if (self.position == self.data.length) {
                [self.stream close];
                self.completionBlock(true);
                NSLog(@"DONE SO DONE");
            }
            break;
        case NSStreamEventEndEncountered:
            NSLog(@"END END END");
            break;
        default:
            NSLog(@"A stream event occurred that we don't handle: %lu", streamEvent);
            break;
    }
}

- (void)dealloc
{
    NSLog(@"CHStreamWriter going away");
}

@end
