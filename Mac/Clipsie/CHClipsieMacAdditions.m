//
//  CHClipsieMacAdditions.m
//  Clipsie
//
//  Created by Sidney San Martín on 7/2/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

#import "CHClipsieMacAdditions.h"

@implementation CHClipsieOffer (CHClipsieMacAdditions)

+ (CHClipsieOffer *)offerWithClipboardWithManagedObjectContext:(NSManagedObjectContext *)context
{
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    
    NSArray *pasteboardObjects = [pb readObjectsForClasses:@[[NSURL class], [NSString class]] options:nil];
    
    if (!pasteboardObjects.count) {
        return nil;
    }
    
    id pbItem = pasteboardObjects[0];
    
    if ([pbItem isKindOfClass:[NSURL class]]) {
        if ([pbItem isFileReferenceURL]) {
            CHClipsieFileOffer *offer = [CHClipsieFileOffer offerInManagedObjectContext:context];
            offer.file = pbItem;
            return offer;
        }
        CHClipsieURLOffer *offer = [CHClipsieURLOffer offerInManagedObjectContext:context];
        offer.url = pbItem;
        return offer;
    }
    
    NSRegularExpression *urlRegex = [NSRegularExpression regularExpressionWithPattern:@"https?:.*" options:NSRegularExpressionCaseInsensitive error:nil];
    
    if ([urlRegex numberOfMatchesInString:pbItem options:0 range:NSMakeRange(0, [pbItem length])]) {
        NSURL *url = [NSURL URLWithString:pbItem];
        if (url) {
            CHClipsieURLOffer *offer = [CHClipsieURLOffer offerInManagedObjectContext:context];
            offer.url = pbItem;
            return offer;
        }
    }
    
    CHClipsieTextOffer *offer = [CHClipsieTextOffer offerInManagedObjectContext:context];
    offer.string = pbItem;
    return offer;
}

@end

@implementation CHClipsieTextOffer (CHClipsieMacAdditions)

- (void)accept
{
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    [pb clearContents];
    [pb writeObjects:@[self.string]];
}

@end

@implementation CHClipsieURLOffer (CHClipsieMacAdditions)

- (void)accept
{
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    [pb clearContents];
    [pb writeObjects:@[self.url]];
}

@end
