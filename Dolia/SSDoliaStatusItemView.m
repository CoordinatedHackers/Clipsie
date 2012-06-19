//
//  SSDoliaStatusItemView.m
//  Dolia
//
//  Created by Sidney San Martín on 6/17/12.
//  Copyright (c) 2012 Sam and Sidney. All rights reserved.
//
//  Much guidance from Kris Johnson and Rob Keniger:
//  http://undefinedvalue.com/2009/07/07/adding-custom-view-nsstatusitem
//  http://stackoverflow.com/a/6493240/84745

#import "SSDoliaStatusItemView.h"
#import <QuartzCore/QuartzCore.h>

static CIImage *statusImage = nil;

@implementation SSDoliaStatusItemView

+ (void)initialize
{
	statusImage = [CIImage imageWithContentsOfURL:[[NSBundle mainBundle] URLForImageResource:@"dolia"]];
}

- (id)initWithStatusItem:(NSStatusItem *)statusItem
{
	if ((self = [super init])) {
		_statusItem = statusItem;
		// Thank God nothing else wants to be the menu’s delegate.
		[[_statusItem menu] setDelegate:self];
		[self registerForDraggedTypes:[NSArray arrayWithObjects:
			NSFilenamesPboardType,
			NSURLPboardType,
			NSPasteboardTypeString,
			nil
		]];
	}
	return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[_statusItem drawStatusBarBackgroundInRect:dirtyRect withHighlight:menuOpen];
	NSRect imageRect = [statusImage extent];
	NSRect destRect = imageRect;
	destRect.origin.x = dirtyRect.size.width / 2 - imageRect.size.width / 2;
	// With the current image, I think it looks better 1px above center
	destRect.origin.y = dirtyRect.size.height / 2 - imageRect.size.height / 2 + 1;
	CIImage *imageToDraw;
	if (menuOpen) {
		// Man, I thought this was the point of template images
		// http://stackoverflow.com/a/2145064/84745
		CIFilter* filter = [CIFilter filterWithName:@"CIColorInvert"];
		[filter setDefaults];
		[filter setValue:statusImage forKey:@"inputImage"];
		imageToDraw = [filter valueForKey:@"outputImage"];
	} else {
		imageToDraw = statusImage;
	}
	[imageToDraw
		drawInRect:destRect
		fromRect:imageRect
		operation:NSCompositeSourceOver
		fraction:1.0
	];
}

- (void)mouseDown:(NSEvent *)event {
	[_statusItem popUpStatusItemMenu:[_statusItem menu]];
	[self setNeedsDisplay:YES];
}

- (void)rightMouseDown:(NSEvent *)event {
	[self mouseDown:event];
}

- (void)menuWillOpen:(NSMenu *)menu {
	menuOpen = YES;
	[self setNeedsDisplay:YES];
}

- (void)menuDidClose:(NSMenu *)menu {
	menuOpen = NO;
	[self setNeedsDisplay:YES];
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
	return NSDragOperationCopy;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	NSPasteboard *pasteboard = [sender draggingPasteboard];
	NSArray* types = [pasteboard types];
	
	if ([types containsObject:NSFilenamesPboardType]) {
		NSLog(@"Files: %@", [pasteboard propertyListForType:NSFilenamesPboardType]);
	} else if ([types containsObject:NSURLPboardType]) {
		NSLog(@"URL: %@", [pasteboard propertyListForType:NSURLPboardType]);
	} else if ([types containsObject:NSPasteboardTypeString]) {
		NSLog(@"String: %@", [pasteboard propertyListForType:NSPasteboardTypeString]);
	} else {
		return NO;
	}
	return YES;
}

@end
