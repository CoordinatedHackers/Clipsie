//
//  SSDoliaStatusMenuController.m
//  Dolia
//
//  Created by Sidney San Martín on 5/31/12.
//  Copyright (c) 2012 Sam and Sidney All rights reserved.
//

#import "SSDoliaStatusMenuController.h"

@implementation SSDoliaStatusMenuController

@synthesize statusItem, menu;

- (SSDoliaStatusMenuController*)init
{
	self = [super init];
	self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:24];
	[NSBundle loadNibNamed:@"DoliaStatusMenu" owner:self];
	return self;
}

- (void)awakeFromNib
{
	NSLog(@"Status menu controller is awake");
	NSImage *statusImage =
	[[NSImage alloc] initWithContentsOfFile:
		[[NSBundle mainBundle] pathForImageResource:@"statusIcon"]
	];
	[statusImage setTemplate:YES];
	[self.statusItem setImage:statusImage];
	[self.statusItem setMenu:self.menu];
	[self.statusItem setHighlightMode:YES];
}

- (void)dealloc
{
	NSLog(@"GOING AWAY, THIS ISN’T IMPLEMENTED");
}

@end
