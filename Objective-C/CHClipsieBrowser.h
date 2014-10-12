//
//  CHClipsieBrowser.h
//  Clipsie
//
//  Created by Sidney San Martín on 5/3/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHClipsieDestination.h"

@protocol CHClipsieBrowserDelegate <NSObject>

- (void)foundDestination:(CHClipsieDestination*)destination moreComing:(BOOL)moreComing;
- (void)lostDestination:(CHClipsieDestination*)destination moreComing:(BOOL)moreComing;

@end

@interface CHClipsieBrowser : NSObject <NSNetServiceBrowserDelegate>

@property (retain) NSNetServiceBrowser *browser;
@property (assign) id<CHClipsieBrowserDelegate> delegate;
@property (retain) NSMutableDictionary *destinations;

- (void)start;
- (void)stop;

@end
