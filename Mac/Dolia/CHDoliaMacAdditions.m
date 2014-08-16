//
//  CHDoliaMacAdditions.m
//  Dolia
//
//  Created by Sidney San Martín on 7/2/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

#import "CHDoliaMacAdditions.h"

@implementation CHDoliaOffer (CHDoliaMacAdditions)

+ (CHDoliaOffer *)offerWithClipboard
{
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    
    NSArray *pasteboardObjects = [pb readObjectsForClasses:@[[NSURL class], [NSString class]] options:nil];
    
    if (!pasteboardObjects.count) {
        return nil;
    }
    
    id pbItem = pasteboardObjects[0];
    
    if ([pbItem isKindOfClass:[NSURL class]]) {
        if ([pbItem isFileReferenceURL]) {
            return [[CHDoliaFileOffer alloc] initWithURL:(NSURL *)pbItem];
        }
        return [[CHDoliaURLOffer alloc] initWithURL:(NSURL *)pbItem];
    }
    
    NSRegularExpression *urlRegex = [NSRegularExpression regularExpressionWithPattern:@"https?:.*" options:NSRegularExpressionCaseInsensitive error:nil];
    
    if ([urlRegex numberOfMatchesInString:pbItem options:0 range:NSMakeRange(0, [pbItem length])]) {
        NSURL *url = [NSURL URLWithString:pbItem];
        if (url) {
            return [[CHDoliaURLOffer alloc] initWithURL:url];
        }
    }
    
    return [[CHDoliaTextOffer alloc] initWithString:pbItem];
}

@end

@implementation CHDoliaTextOffer (CHDoliaMacAdditions)

- (void)accept
{
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    [pb clearContents];
    [pb writeObjects:@[self.string]];
}

@end

@implementation CHDoliaURLOffer (CHDoliaMacAdditions)

- (void)accept
{
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    [pb clearContents];
    [pb writeObjects:@[self.url]];
}

@end