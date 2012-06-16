//
//  SSDoliaSendWindowController.m
//  Dolia
//
//  Created by Sam Epstein on 6/16/12.
//  Copyright (c) 2012 Sam and Sidney. All rights reserved.
//

#import "SSDoliaSendWindowController.h"

@interface SSDoliaSendWindowController ()
@property(strong) SSDoliaSendWindowController *selfReference;
@end

@implementation SSDoliaSendWindowController
@synthesize selfReference,delegate;
- (id)init
{
    self = [super initWithWindowNibName:@"SSDoliaSendWindow"];
    if (self) {
        self.selfReference = self;
        self.delegate = [NSApp delegate];
        NSLog(@"SendWindowController INIT!!");
    }

    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    NSLog(@"Yo WINDOW DONE LOADED!");

    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)windowWillClose:(NSNotification *)notification
{
    self.selfReference = nil;
}

//TODO: Convience method for initWithDelegate
@end
