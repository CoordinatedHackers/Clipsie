//
//  SSAppDelegate.m
//  Dolia
//
//  Created by Sidney San Martín on 5/31/12.
//  Copyright (c) 2012 Sam and Sidney. All rights reserved.
//

#import "SSAppDelegate.h"

@implementation SSAppDelegate

@synthesize statusMenu;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	self.statusMenu = [SSDoliaStatusMenuController new];
}

@end
