//
//  CHStreamWriter.h
//  Dolia
//
//  Created by Sidney San Martín on 5/16/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHStreamWriter : NSObject <NSStreamDelegate>

+ (void)writeData:(NSData *)data toStream:(NSOutputStream *)stream withCompletionBlock:(void (^)(bool))block;

@property (retain) CHStreamWriter *holdSelf;
@property (retain) NSData *data;
@property (retain) NSOutputStream *stream;
@property (nonatomic, copy) void (^completionBlock)(bool);
@property NSUInteger position;

- (id)initWithData:(NSData *)data stream:(NSOutputStream *)stream completionBlock:(void (^)(bool))block;
- (void)write;

@end
