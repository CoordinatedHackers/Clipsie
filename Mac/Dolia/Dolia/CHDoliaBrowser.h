//
//  CHDoliaBrowser.h
//  Dolia
//
//  Created by Sidney San Martín on 5/3/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHDoliaDestination.h"

@protocol CHDoliaBrowserDelegate <NSObject>

- (void)foundDestination:(CHDoliaDestination*)destination moreComing:(BOOL)moreComing;
- (void)lostDestination:(CHDoliaDestination*)destination moreComing:(BOOL)moreComing;

@end

@interface CHDoliaBrowser : NSObject <NSNetServiceBrowserDelegate>

@property (retain) NSNetServiceBrowser *browser;
@property (assign) id<CHDoliaBrowserDelegate> delegate;
@property (retain) NSMutableDictionary *destinations;

@end
