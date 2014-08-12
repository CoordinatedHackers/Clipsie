//
//  CHDoliaBrowser.m
//  Dolia
//
//  Created by Sidney San Martín on 5/3/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

#import "CHDoliaBrowser.h"

@implementation CHDoliaBrowser

- (id)init
{
    if ((self = [super init])) {
        self.browser = [NSNetServiceBrowser new];
        self.destinations = [NSMutableDictionary new];
        [self.browser setDelegate:self];
        [self.browser searchForServicesOfType:@"_dolia._tcp" inDomain:@"local."];
    }
    return self;
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
    CHDoliaDestination *dest = [[CHDoliaDestination alloc] initWithService:aNetService];
    [self.destinations setObject:dest forKey:aNetService.name];
    [self.delegate foundDestination:dest moreComing:moreComing];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
    CHDoliaDestination *dest = [self.destinations objectForKey:aNetService.name];
    [self.destinations removeObjectForKey:aNetService.name];
    if (dest) {
        [self.delegate lostDestination:dest moreComing:moreComing];
    }
}

@end
