//
//  CHDoliaDestination.h
//  Dolia
//
//  Created by Sidney San Martín on 5/7/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHStreamWriter.h"

@interface CHDoliaDestination : NSObject

@property (retain) NSNetService *service;
@property (retain) NSInputStream *inputStream;
@property (retain) NSOutputStream *outputStream;
@property (retain) CHStreamWriter *writer; // Fuckin' hax

- (id)initWithService:(NSNetService*)service;
- (NSString *)name;
- (void)offerData:(NSData *)data;

@end
