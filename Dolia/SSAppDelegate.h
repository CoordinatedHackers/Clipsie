//
//  SSAppDelegate.h
//  Dolia
//
//  Created by Sidney San Martín on 5/31/12.
//  Copyright (c) 2012 Sam and Sidney. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SSDoliaStatusMenuController.h"

@interface SSAppDelegate : NSObject <NSApplicationDelegate, NSNetServiceDelegate, NSNetServiceBrowserDelegate>

@property (retain) SSDoliaStatusMenuController *statusMenu;
@property (retain) NSSocketPort *listeningPort;
@property (retain) NSNetService *service;
@property (retain) NSNetServiceBrowser *browser;
@property (retain) NSMutableSet *foundServices;

@end
