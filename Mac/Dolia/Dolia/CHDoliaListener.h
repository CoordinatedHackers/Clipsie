//
//  CHDoliaListener.h
//  Dolia
//
//  Created by Sidney San Martín on 5/3/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHDoliaOffer.h"

@protocol CHDoliaListenerDelegate <NSObject>

- (void)gotOffer:(CHDoliaOffer*)offer;

@end

@interface CHDoliaListener : NSObject <NSNetServiceDelegate, NSStreamDelegate>

@property (retain) NSNetService *service;
@property NSObject<CHDoliaListenerDelegate> *delegate;
@property (retain) NSMutableData *data;
@property uint16_t length;
@property uint16_t position;
- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent;

@end
