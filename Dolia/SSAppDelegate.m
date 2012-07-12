//
//  SSAppDelegate.m
//  Dolia
//
//  Created by Sidney San Martín on 5/31/12.
//  Copyright (c) 2012 Sam and Sidney. All rights reserved.
//

#import "SSAppDelegate.h"
#import "SSDoliaHTTPConnection.h"
#import "SSDoliaSendWindowController.h"
#import "HTTPServer.h"

#import <netinet/in.h>
#import <sys/socket.h>

#import "DDLog.h"
#import "DDTTYLogger.h"

@interface SSAppDelegate ()

@property (retain) NSMutableDictionary *offers;

@end

@implementation SSAppDelegate

@synthesize statusMenu, listeningPort, service, browser, foundServices, offers;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	self.offers = [NSMutableDictionary dictionary];
	self.statusMenu = [SSDoliaStatusMenuController new];
	self.foundServices = [NSMutableSet new];

    
    // Configure our logging framework.
	// To keep things simple and fast, we're just going to log to the Xcode console.
	[DDLog addLogger:[DDTTYLogger sharedInstance]];

    _httpServer = [HTTPServer new];
    [_httpServer setType:@"_dolia._tcp."];
    [_httpServer setPort:12345];
    [_httpServer setConnectionClass:[SSDoliaHTTPConnection class]];
    
    NSError *error;
    [_httpServer start:&error];
    
	//Search for other Dolia instances
	self.browser = [NSNetServiceBrowser new];
	[self.browser setDelegate:self];
	[self.browser searchForServicesOfType:@"_dolia._tcp" inDomain:@"local."];

}

- (void)offerItems:(NSArray*)items
{
	for (id item in items) {
		(void)[[SSDoliaSendWindowController alloc] initWithObjectToSend:item];
	}
	[NSApp activateIgnoringOtherApps:YES];
}

- (void)offerItem:(id)item toUser:(NSNetService *)user
{
	CFUUIDRef uuid = CFUUIDCreate(NULL);
	[self.offers setObject:item forKey:[@"/" stringByAppendingString:(__bridge_transfer NSString*)CFUUIDCreateString(NULL, uuid)]];
	NSLog(@"Now offering: %@", self.offers);
}

- (void)receiveItem:(NSString *)id fromClient:(NSString *)address onPort:(NSString *)port metadata:(NSDictionary *)metadata
{
	NSLog(@"DERP");
}

#pragma mark(NSNetServiceBrowserDelegate Methods)

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
	NSLog(@"Added: %@", aNetService);

	[self willChangeValueForKey:@"foundServices"];
	[self.foundServices addObject:aNetService];
	[self didChangeValueForKey:@"foundServices"];

	NSLog(@"foundServices: %@", self.foundServices);
	[self.statusMenu addNewFoundComputer:aNetService];
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
	NSLog(@"Removed: %@", aNetService);

	[self willChangeValueForKey:@"foundServices"];
	[self.foundServices removeObject:aNetService];
	[self didChangeValueForKey:@"foundServices"];

	[self.statusMenu removeFoundComputer:aNetService];

}

@end
