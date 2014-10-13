//
//  CHAppDelegate.m
//  Clipsie
//
//  Created by Sidney San Martín on 5/3/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

#import "CHAppDelegate.h"
#import "CHClipsieMacAdditions.h"
#import "NSString+CHAdditions.h"

@interface CHClipsieOfferAndNotification : NSObject

@property (retain) CHClipsieOffer *offer;
@property (retain) NSUserNotification *notification;

@end

@implementation CHClipsieOfferAndNotification

@end

@implementation CHAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:24];
	[self.statusItem setMenu:self.statusMenu];
	[self.statusItem setHighlightMode:YES];
    [self.statusItem setImage:[NSImage imageNamed:@"status-menu"]];
    [self.statusItem setAlternateImage:[NSImage imageNamed:@"status-menu-inverted"]];
    
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"Clipsie" withExtension:@"momd"]];
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    NSError *err;
    
    NSURL *applicationSupportDirectory = [[[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] firstObject] URLByAppendingPathComponent:@"Clipsie"];
    [[NSFileManager defaultManager] createDirectoryAtURL:applicationSupportDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    
    [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                             configuration:nil
                                                       URL:[applicationSupportDirectory URLByAppendingPathComponent:@"Clipsie.sqlite"]
                                                   options:nil
                                                     error:&err];
    if (err != nil) {
        NSLog(@"%@", err);
    }
    
    self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    self.managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextWillSaveNotification
                                                      object:self.managedObjectContext
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      NSFetchRequest *fetchRequest = [self.managedObjectContext.persistentStoreCoordinator.managedObjectModel fetchRequestTemplateForName:@"AllOffers"];
                                                      NSMutableArray *allOffers = [[self.managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
                                                      while ([allOffers count] > 5) {
                                                          [self.managedObjectContext deleteObject:[allOffers lastObject]];
                                                          [allOffers removeLastObject];
                                                      }
                                                  }];
    
    [self.inboxArrayController addObserver:self forKeyPath:@"arrangedObjects" options:0 context:nil];
    
    self.inboxMenuItems = [NSMutableArray new];
    
    self.listener.delegate = self;
    [self.listener start];
    
    self.browser.delegate = self;
    [self.browser start];
    
    self.menuItemsByDestination = [NSMutableDictionary new];
    
    NSUserNotificationCenter *nc = [NSUserNotificationCenter defaultUserNotificationCenter];
    nc.delegate = self;
}

- (BOOL)isInboxEmpty
{
    return ((NSArray *)self.inboxArrayController.arrangedObjects).count == 0;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self willChangeValueForKey:@"isInboxEmpty"];
    [self didChangeValueForKey:@"isInboxEmpty"];
    
    for (NSMenuItem *menuItem in self.inboxMenuItems) {
        [self.statusMenu removeItem:menuItem];
    }
    [self.inboxMenuItems removeAllObjects];
    
    for (CHClipsieOffer *offer in self.inboxArrayController.arrangedObjects) {
        NSMenuItem *offerMenuItem = [NSMenuItem new];
        offerMenuItem.representedObject = offer;
        offerMenuItem.title = [offer.preview truncate:20 overflow:@"…"];
        offerMenuItem.target = self;
        offerMenuItem.action = @selector(offerMenuItemClicked:);
        [self.inboxMenuItems addObject:offerMenuItem];
        [self.statusMenu insertItem:offerMenuItem atIndex:[self.statusMenu indexOfItem:self.inboxTitleMenuItem] + 1];
    }
}

- (void)gotOffer:(CHClipsieOffer *)offer
{
    NSUserNotification *notification = [NSUserNotification new];
    
    CHClipsieOfferAndNotification *offerAndNotification = [CHClipsieOfferAndNotification new];
    offerAndNotification.offer = offer;
    offerAndNotification.notification = notification;
    
    notification.title = @"Incoming clipboard!";
    notification.informativeText = [NSString stringWithFormat:@"Click to copy “%@”", [offer.preview truncate:20 overflow:@"…"]];
    notification.hasActionButton = YES;
    notification.actionButtonTitle = @"Accept";
    notification.otherButtonTitle = @"Ignore";
    notification.userInfo = @{@"id": offer.objectID.URIRepresentation.absoluteString};
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

- (void)foundDestination:(CHClipsieDestination *)destination moreComing:(BOOL)moreComing
{
    NSMenuItem *menuItem = [NSMenuItem new];
    menuItem.representedObject = destination;
    
    // Hax hax hax
    [self.menuItemsByDestination setObject:menuItem forKey:[NSValue valueWithPointer:(__bridge void *)(destination)]];
    
    [menuItem setTitle:destination.name];
    menuItem.target = self;
    menuItem.action = @selector(sendMenuItemClicked:);
    [self.statusMenu insertItem:menuItem atIndex:0];
}

- (void)lostDestination:(CHClipsieDestination *)destination moreComing:(BOOL)moreComing
{
    NSValue *key = [NSValue valueWithPointer:(__bridge void *)(destination)];
    NSMenuItem *menuItem = [self.menuItemsByDestination objectForKey:key];
    [self.menuItemsByDestination removeObjectForKey:key];
    
    [self.statusMenu removeItem:menuItem];
}

- (void)offerMenuItemClicked:(NSMenuItem*)menuItem
{
    [((CHClipsieOffer *)menuItem.representedObject) accept];
}

- (void)sendMenuItemClicked:(NSMenuItem*)menuItem
{
    CHClipsieDestination *destination = menuItem.representedObject;

    NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext new];
    managedObjectContext.parentContext = self.managedObjectContext;
    [destination sendOffer:[CHClipsieOffer offerWithClipboardWithManagedObjectContext:managedObjectContext]];
    
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
    NSManagedObjectID *objectID = [self.managedObjectContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:[NSURL URLWithString:notification.userInfo[@"id"]]];
    CHClipsieOffer *offer = (CHClipsieOffer *)[self.managedObjectContext objectWithID:objectID];
    [offer accept];
}

- (NSManagedObjectContext *)managedObjectContextForOffer {
    return self.managedObjectContext;
}

@end
