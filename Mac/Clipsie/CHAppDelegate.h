//
//  CHAppDelegate.h
//  Clipsie
//
//  Created by Sidney San Martín on 5/3/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CHClipsieListener.h"
#import "CHClipsieBrowser.h"

@interface CHAppDelegate : NSObject <
    NSApplicationDelegate,CHClipsieListenerDelegate,CHClipsieBrowserDelegate,
    NSUserNotificationCenterDelegate
>

@property (assign) IBOutlet NSMenu *statusMenu;
@property (assign) IBOutlet CHClipsieListener *listener;
@property (assign) IBOutlet CHClipsieBrowser *browser;
@property (assign) IBOutlet NSArrayController *inboxArrayController;
@property (assign) IBOutlet NSMenuItem *inboxTitleMenuItem;

@property (retain) NSManagedObjectContext *managedObjectContext;

@property (retain) NSStatusItem *statusItem;

@property (retain) NSMutableDictionary *menuItemsByDestination;
@property (retain) NSMutableDictionary *destinationsByMenuItem;

@property (retain) NSMutableArray *pendingOffers;
@property (retain) NSMutableDictionary *pendingOffersByHash;
@property (retain) NSMutableArray *inboxMenuItems;


- (NSManagedObjectContext *)managedObjectContextForOffer;

- (BOOL)isInboxEmpty;

// When we data bind any property of a menu item, it becomes enabled, unless we bind its enabled property.
@property (assign, readonly) BOOL no;

@end
