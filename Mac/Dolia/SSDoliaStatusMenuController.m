//
//  SSDoliaStatusMenuController.m
//  Dolia
//
//  Created by Sidney San Martín on 5/31/12.
//  Copyright (c) 2012 Sam and Sidney All rights reserved.
//

#import "SSDoliaStatusMenuController.h"
#import "SSDoliaSendWindowController.h"
#import "SSDoliaStatusItemView.h"

@implementation SSDoliaStatusMenuController

@synthesize statusItem, menu, servicesDictionary;

- (SSDoliaStatusMenuController*)init
{
	self = [super init];
	//Use CFDictionary because NSNetService can't be copied (a requirement to be a key in NSDictionarys)
	self.servicesDictionary = (__bridge_transfer NSMutableDictionary *)CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:24];
	[NSBundle loadNibNamed:@"DoliaStatusMenu" owner:self];
	return self;
}

- (void)awakeFromNib
{
	NSLog(@"Status menu controller is awake");
	[self.statusItem setMenu:self.menu];
	[self.statusItem setHighlightMode:YES];
	[self.statusItem setView:[[SSDoliaStatusItemView alloc] initWithStatusItem:self.statusItem]];
}

- (void)addNewFoundComputer:(NSNetService *)computer
{
	//[self.menu addItemWithTitle:computerName action:@selector(printSomeStuff:) keyEquivalent:@""];
	
	NSMenuItem *menuItem = [NSMenuItem new];
	
	//Use CFDictionary method to set value to avoid copying issue
	CFDictionarySetValue((__bridge CFMutableDictionaryRef)self.servicesDictionary, (__bridge void *)computer, (__bridge void *)menuItem);

	[menuItem setTitle:[computer name]];
	[menuItem setAction:@selector(printSomeStuff:)];
	[menuItem setTarget:self];
	[menuItem setEnabled:YES];
	[self.menu insertItem:menuItem atIndex:0];
}

- (void)removeFoundComputer:(NSNetService *)computer
{
	//[self.menu addItemWithTitle:computerName action:@selector(printSomeStuff:) keyEquivalent:@""];
	
	NSMenuItem *menuItem = [self.servicesDictionary objectForKey:computer];
	[self.servicesDictionary removeObjectForKey:computer];
	
	[self.menu removeItem:menuItem];
}


-(void)printSomeStuff:(NSString *)stuff
{
	(void)[[SSDoliaSendWindowController alloc] initWithObjectToSend:@"HELLO WORLD"];
	[NSApp activateIgnoringOtherApps:YES];
	NSLog(@"Print some stuff: %@", stuff);
	NSLog(@"This is running");
}

- (void)dealloc
{
	NSLog(@"GOING AWAY, THIS ISN’T IMPLEMENTED");
}

@end
