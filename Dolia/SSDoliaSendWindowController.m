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

//MAYBE make an init method that just throws an error?
- (id)initWithObjectToSend:(id)objectToSend
{
    if ((self = [super initWithWindowNibName:@"SSDoliaSendWindow"]) && objectToSend) {
        _objectToSend = objectToSend;
        self.selfReference = self;
		self.delegate = [NSApp delegate];
        [[self window] setLevel:NSFloatingWindowLevel];
		[[self window] makeKeyAndOrderFront:self];
    }

    return self;
}

- (IBAction)send:(id)sender
{
    NSLog(@"I made it so");
}

- (void)windowDidLoad
{
	[super windowDidLoad];

	// Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)windowWillClose:(NSNotification *)notification
{
	self.selfReference = nil;
}

//TODO: Convience method for initWithDelegate
@end
