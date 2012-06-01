//
//  SSDoliaStatusMenuController.h
//  Dolia
//
//  Created by Sidney San Martín on 5/31/12.
//  Copyright (c) 2012 Sam and Sidney All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSDoliaStatusMenuController : NSObject {
	NSStatusItem *statusItem;
	IBOutlet NSMenu *menu;
	
}

@property(retain) NSStatusItem *statusItem;
@property(retain) IBOutlet NSMenu *menu;

@end
