//
//  CHDoliaOffer.m
//  Dolia
//
//  Created by Sidney San Martín on 5/7/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

#import "CHDoliaOffer.h"

@implementation CHDoliaOffer

- (void)accept {}
- (NSString *)preview { return nil; }

@end

@implementation CHDoliaClipboardOffer

- (id)initWithData:(NSDictionary *)data
{
    if ((self = [self init])) {
        self.data = data;
    }
    return self;
}

- (void)accept
{
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    [pb clearContents];
    for (NSString *key in self.data) {
        NSData *data = [[NSData alloc] initWithBase64EncodedString:[self.data objectForKey:key] options:0];
        [pb setData:data forType:key];
    }
}

- (NSString *)preview
{
    NSString *encodedPreview;
    if ((encodedPreview = [self.data objectForKey:NSPasteboardTypeString])) {
        NSString *decodedPreview = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:encodedPreview options:0] encoding:NSUTF8StringEncoding];
        NSRange truncatedRange = [decodedPreview rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, MIN(50, [decodedPreview length]))];
        if (truncatedRange.length < [decodedPreview length]) {
            return [[decodedPreview substringWithRange:truncatedRange] stringByAppendingString:@"…"];
        } else {
            return decodedPreview;
        }
    }
    return nil;
}

@end