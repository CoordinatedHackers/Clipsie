//
//  SSAppDelegate.m
//  Dolia
//
//  Created by Sidney San Martín on 5/31/12.
//  Copyright (c) 2012 Sam and Sidney. All rights reserved.
//

#import "SSAppDelegate.h"
#import <netinet/in.h>
#import <sys/socket.h>

@implementation SSAppDelegate

@synthesize statusMenu, listeningPort, service, browser;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	self.statusMenu = [SSDoliaStatusMenuController new];
    self.listeningPort = [[NSSocketPort alloc] initWithTCPPort:0];

    struct sockaddr *addr;
    UInt16 port;

    addr = (struct sockaddr *)[[self.listeningPort address] bytes];
    if(addr->sa_family == AF_INET)
    {
        port = ntohs(((struct sockaddr_in *)addr)->sin_port);
    }
    else if(addr->sa_family == AF_INET6)
    {
        port = ntohs(((struct sockaddr_in6 *)addr)->sin6_port);
    }
    else
    {
        self.listeningPort = nil;
        NSLog(@"The family is neither IPv4 nor IPv6. Can't handle.");
    }

    if(self.listeningPort)
    {
        self.service = [[NSNetService alloc] initWithDomain:@""
                                                  type:@"_dolia._tcp"
                                                  name:@"" port:port];
        if(self.service)
        {
            [self.service setDelegate:self];
            [self.service publish];
        }
        else
        {
            NSLog(@"An error occurred initializing the NSNetService object.");
        }
    }
    else
    {
        NSLog(@"An error occurred initializing the NSSocketPort object.");
    }

    //Search for other Dolia instances
    self.browser = [NSNetServiceBrowser new];
    [self.browser setDelegate:self];
    [self.browser searchForServicesOfType:@"_dolia._tcp" inDomain:@""];

}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
    NSLog(@"%@", aNetService);
}

@end
