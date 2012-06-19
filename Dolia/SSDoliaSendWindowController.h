//
//  SSDoliaSendWindowController.h
//  Dolia
//
//  Created by Sam Epstein on 6/16/12.
//  Copyright (c) 2012 Sam and Sidney. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SSDoliaSendWindowController : NSWindowController {
    id _objectToSend;
}
@property (retain) id delegate;

- (id)initWithObjectToSend:(id)objectToSend;
- (IBAction)send:(id)sender;

@end
