//
//  CHAppDelegate.h
//  Dolia
//
//  Created by Sidney San Martín on 5/3/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CHDoliaListener.h"
#import "CHDoliaBrowser.h"

@interface CHAppDelegate : NSObject <
    NSApplicationDelegate,CHDoliaListenerDelegate,CHDoliaBrowserDelegate,
    NSUserNotificationCenterDelegate
>

@property (assign) IBOutlet NSMenu *statusMenu;
@property (assign) IBOutlet CHDoliaListener *listener;
@property (assign) IBOutlet CHDoliaBrowser *browser;
@property (retain) NSStatusItem *statusItem;

@property (retain) NSMutableDictionary *menuItemsByDestination;
@property (retain) NSMutableDictionary *destinationsByMenuItem;

@property (retain) NSMutableArray *pendingOffers;
@property (retain) NSMutableDictionary *pendingOffersByHash;

- (void)menuItemClicked:(NSMenuItem*)menuItem;

@end
