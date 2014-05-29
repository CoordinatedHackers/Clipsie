//
//  CHAppDelegate.m
//  Dolia
//
//  Created by Sidney San Martín on 5/3/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

#import "CHAppDelegate.h"

@interface CHDoliaOfferAndNotification : NSObject

@property (retain) CHDoliaOffer *offer;
@property (retain) NSUserNotification *notification;

@end

@implementation CHDoliaOfferAndNotification

@end

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
    self.pendingOffers = [NSMutableArray new];
    self.pendingOffersByHash = [NSMutableDictionary new];
    
    NSUserNotificationCenter *nc = [NSUserNotificationCenter defaultUserNotificationCenter];
    nc.delegate = self;
    [nc removeAllDeliveredNotifications];
}

- (void)gotOffer:(CHDoliaOffer *)offer
{
    
    NSUserNotification *notification = [NSUserNotification new];
    
    CHDoliaOfferAndNotification *offerAndNotification = [CHDoliaOfferAndNotification new];
    offerAndNotification.offer = offer;
    offerAndNotification.notification = notification;
    
    if ([self.pendingOffers count] >= 5) {
        CHDoliaOfferAndNotification *offerToDestroy = [self.pendingOffers objectAtIndex:0];
        [self.pendingOffers removeObjectAtIndex:0];
        [self.pendingOffersByHash removeObjectForKey:offerToDestroy];
        [[NSUserNotificationCenter defaultUserNotificationCenter] removeDeliveredNotification:offerToDestroy.notification];
    }
    
    NSNumber *key = [NSNumber numberWithUnsignedInteger:[offer hash]];
    
    [self.pendingOffers addObject:offerAndNotification];
    [self.pendingOffersByHash setObject:offerAndNotification forKey:key];

    notification.title = @"Incoming clipboard!";
    notification.informativeText = offer.preview;
    notification.hasActionButton = YES;
    notification.actionButtonTitle = @"Accept";
    notification.otherButtonTitle = @"Ignore";
    notification.userInfo = @{@"key": key};
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    [offer accept];
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
        // Once, ever, I've seen -[NSPasteboard dataForType:] return nil for a type.
        // It might be that there was actually some content in there, but I lost that
        // clipboard and haven't been able to reproduce it. For now, just check for data.
        NSData *data = [pb dataForType:type];
        if (!data) {
            NSLog(@"Pasteboard type \"%@\" had no data, skipping", type);
            continue;
        }
        [pasteboardContents setObject:[data base64EncodedStringWithOptions:0] forKey:type];
    }
    
    NSDictionary *offerData = @{@"type": @"clipboard", @"data": pasteboardContents};
    NSData *pbData = [NSJSONSerialization dataWithJSONObject:offerData options:0 error:nil];
    [destination offerData:pbData];
    
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
    NSNumber *key = [notification.userInfo objectForKey:@"key"];
    CHDoliaOfferAndNotification *offerAndNotification = [self.pendingOffersByHash objectForKey:key];
    if (notification.activationType == NSUserNotificationActivationTypeActionButtonClicked) {
        [offerAndNotification.offer accept];
    } else {
        NSLog(@"Clicked");
    }
}

@end
