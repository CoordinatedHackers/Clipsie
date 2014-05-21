//
//  CHStreamReader.m
//  Dolia
//
//  Created by Sidney San Martín on 5/19/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

#import "CHStreamInterface.h"

@implementation CHStreamInterface

- (void)start
{
    self.holdSelf = self;
}

- (void)end
{
    self.holdSelf = nil;
}

@end

@implementation CHStreamReader

+ (void)readFromStream:(NSInputStream *)stream withCompletionBlock:(void (^)(NSData *))block
{
    CHStreamReader *reader = [CHStreamReader new];
    reader.stream = stream;
    reader.completionBlock = block;
    [reader start];
}

- (void)start
{
    [super start];
    self.stream.delegate = self;
    [self.stream open];
    [self.stream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stream:(NSInputStream *)stream handleEvent:(NSStreamEvent)streamEvent
{
    switch (streamEvent) {
        case NSStreamEventHasBytesAvailable:
            if (!self.data) {
                [stream read:(uint8_t *)&_length maxLength:sizeof(_length)];
                self.data = [NSMutableData dataWithLength:self.length];
                self.position = 0;
                NSLog(@"Read length: %llu", self.length);
                
            }
            NSLog(@"Reading up to %llu bytes", self.length - self.position);
            self.position += [stream read:([self.data mutableBytes]+self.position) maxLength:(self.length - self.position)];
            
            if (self.position == self.length) {
                [stream close];
                self.completionBlock(self.data);
                [self end];
                NSLog(@"Done reading");
            }
            break;
            
        default:
            NSLog(@"Some event, %ld", streamEvent);
            break;
    }
}

@end

@implementation CHStreamWriter

+ (void)writeData:(NSData *)data toStream:(NSOutputStream *)stream withCompletionBlock:(void (^)())block
{
    CHStreamWriter *writer = [CHStreamWriter new];
    writer.data = data;
    writer.stream = stream;
    writer.completionBlock = block;
    [writer start];
}

- (void)start
{
    [super start];
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
            if (self.position == 0) {
                uint64_t length = self.data.length;
                NSLog(@"Writing length: %lld", length);
                [self.stream write:(uint8_t*)&length maxLength:sizeof(length)];
            }
            NSLog(@"Writing up to %lu bytes", self.data.length - self.position);
            self.position += [self.stream write:[self.data bytes] + self.position maxLength:(self.data.length - self.position)];
            if (self.position == self.data.length) {
                [self.stream close];
                self.completionBlock(true);
                [self end];
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
