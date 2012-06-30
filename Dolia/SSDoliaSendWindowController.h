//
//  SSDoliaSendWindowController.h
//  Dolia
//
//  Created by Sam Epstein on 6/16/12.
//  Copyright (c) 2012 Sam and Sidney. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NSNetService;

@protocol SSDoliaSendWindowDelegate

- (void)offerItem:(id)item toUser:(NSNetService *)user;

@end

@interface SSDoliaSendWindowController : NSWindowController {
    id _objectToSend;
	IBOutlet NSArrayController* _recipientController;
}
@property (retain) id<SSDoliaSendWindowDelegate> delegate;

- (id)initWithObjectToSend:(id)objectToSend;
- (IBAction)send:(id)sender;

@end
