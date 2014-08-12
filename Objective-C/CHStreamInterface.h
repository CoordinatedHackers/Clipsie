//
//  CHStreamReader.h
//  Dolia
//
//  Created by Sidney San Martín on 5/19/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHStreamInterface : NSObject

@property CHStreamInterface *holdSelf;

@end

@interface CHStreamReader : CHStreamInterface <NSStreamDelegate>

+ (void)readFromStream:(NSInputStream *)stream withCompletionBlock:(void (^)(NSData *))block;

@property (retain) NSMutableData *data;
@property (retain) NSInputStream *stream;
@property (nonatomic, copy) void (^completionBlock)(NSData *);
@property NSUInteger length;
@property NSUInteger position;

@end

@interface CHStreamWriter : CHStreamInterface <NSStreamDelegate>

+ (void)writeData:(NSData *)data toStream:(NSOutputStream *)stream withCompletionBlock:(void (^)())block;

@property (retain) NSData *data;
@property (retain) NSOutputStream *stream;
@property (nonatomic, copy) void (^completionBlock)();
@property NSUInteger position;

@end
