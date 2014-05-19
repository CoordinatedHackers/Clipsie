//
//  CHAppDelegate.m
//  Dolia
//
//  Created by Sidney San Martín on 5/3/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

#import "CHAppDelegate.h"

@implementation CHAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:24];
	[self.statusItem setMenu:self.statusMenu];
	[self.statusItem setHighlightMode:YES];
    [self.statusItem setImage:[NSImage imageNamed:@"status-menu"]];
    [self.statusItem setAlternateImage:[NSImage imageNamed:@"status-menu-inverted"]];
    
    self.listener.delegate = self;
    self.browser.delegate = self;
    
    self.menuItemsByDestination = [NSMutableDictionary new];
    self.destinationsByMenuItem = [NSMutableDictionary new];
}

- (void)gotOffer:(CHDoliaOffer *)offer
{
}

- (void)foundDestination:(CHDoliaDestination *)destination moreComing:(BOOL)moreComing
{
    NSMenuItem *menuItem = [NSMenuItem new];
    
    // Hax hax hax
    [self.menuItemsByDestination setObject:menuItem forKey:[NSValue valueWithPointer:(__bridge void *)(destination)]];
    [self.destinationsByMenuItem setObject:destination forKey:[NSValue valueWithPointer:(__bridge void *)(menuItem)]];
    
    [menuItem setTitle:destination.name];
    menuItem.target = self;
    menuItem.action = @selector(menuItemClicked:);
    [self.statusMenu insertItem:menuItem atIndex:0];
}

- (void)lostDestination:(CHDoliaDestination *)destination moreComing:(BOOL)moreComing
{
    NSValue *key = [NSValue valueWithPointer:(__bridge void *)(destination)];
    NSMenuItem *menuItem = [self.menuItemsByDestination objectForKey:key];
    [self.menuItemsByDestination removeObjectForKey:key];
    [self.destinationsByMenuItem removeObjectForKey:[NSValue valueWithPointer:(__bridge const void *)(menuItem)]];
    
    [self.statusMenu removeItem:menuItem];
}

- (void)menuItemClicked:(NSMenuItem*)menuItem
{
    CHDoliaDestination *destination = [self.destinationsByMenuItem objectForKey:[NSValue valueWithPointer:(__bridge const void *)(menuItem)]];
    
    NSMutableDictionary *pasteboardContents = [NSMutableDictionary new];
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    
    for (NSString *type in pb.types) {
        [pasteboardContents setObject:[[pb dataForType:type] base64EncodedStringWithOptions:0] forKey:type];
    }
    
    NSData *pbData = [NSJSONSerialization dataWithJSONObject:pasteboardContents options:0 error:nil];
    
    
    NSMutableData *offerData = [NSMutableData dataWithLength:2];
    *(uint64_t *)[offerData mutableBytes] = pbData.length;
    [offerData appendData:pbData];
    
    [destination offerData:offerData];
    
}

@end