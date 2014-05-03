//
//  SSDoliaStatusMenuController.h
//  Dolia
//
//  Created by Sidney San Martín on 5/31/12.
//  Copyright (c) 2012 Sam and Sidney All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSDoliaStatusMenuController : NSObject {
	NSStatusItem *statusItem;
	IBOutlet NSMenu *menu;
}

-(void)addNewFoundComputer:(NSNetService *)computer;
-(void)removeFoundComputer:(NSNetService *)computer;
-(void)printSomeStuff:(NSString *)stuff;

@property(retain) NSStatusItem *statusItem;
@property(retain) IBOutlet NSMenu *menu;
@property(retain) NSMutableDictionary *servicesDictionary;

@end
