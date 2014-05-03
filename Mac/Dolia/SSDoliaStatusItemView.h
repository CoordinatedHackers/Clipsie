//
//  SSDoliaStatusItemView.h
//  Dolia
//
//  Created by Sidney San Martín on 6/17/12.
//  Copyright (c) 2012 Sam and Sidney. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SSDoliaStatusItemView : NSView<NSMenuDelegate> {
	NSStatusItem *_statusItem;
	BOOL menuOpen;
}

- (id)initWithStatusItem:(NSStatusItem *)statusItem;

@end
