//
//  CHClipsieListener.h
//  Clipsie
//
//  Created by Sidney San Martín on 5/3/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHClipsieOffer.h"

@protocol CHClipsieListenerDelegate <NSObject>

- (NSManagedObjectContext *)managedObjectContextForOffer;

@optional
- (void)gotOffer:(CHClipsieOffer*)offer;

@end

@interface CHClipsieListener : NSObject <NSNetServiceDelegate, NSStreamDelegate>

@property (retain) NSNetService *service;
@property NSObject<CHClipsieListenerDelegate> *delegate;

- (void)start;
- (void)stop;

@end
