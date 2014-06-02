//
//  CHDoliaOffer.m
//  Dolia
//
//  Created by Sidney San Martín on 5/7/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

#import "CHDoliaOffer.h"

@implementation CHDoliaOffer

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

- (NSData *)getData
{
    NSDictionary *json = @{@"type": self.type,
                           @"content": self.content};
    return [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
}

- (void)accept {}
- (NSString *)preview { return nil; }

@end

@implementation CHDoliaTextOffer

- (instancetype) initWithString:(NSString *)string
{
    if (self = [self init]){
        self.type = @"text";
        self.content = string;
    }
    return self;
}

@end

@implementation CHDoliaURLOffer

- (instancetype) initWithURL:(NSURL *)url
{
    if (self = [self init]){
        self.type = @"url";
        self.content = [url absoluteString];
    }
    return self;
}

@end

@implementation CHDoliaFileOffer

- (instancetype) initWithURL:(NSURL *)url
{
    if (self = [self init]){
        self.type = @"file";
        
        NSFileHandle *handle = [NSFileHandle fileHandleForReadingFromURL:url error:nil];
        self.content = [[handle availableData] base64EncodedStringWithOptions:0];
        
        NSString *filename;
        if ([url getResourceValue:&filename forKey:NSURLNameKey error:nil]) {
            self.filename = filename;
        } else {
            NSLog(@"Bad news bears, couldn't get filename for %@", url);
        }
        NSLog(@"Data: %@", [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:self.content options:0] encoding:NSUTF8StringEncoding]);
    }
    return self;
}

- (NSData *)getData
{
    NSDictionary *json = @{@"type": self.type,
                           @"filename": self.filename,
                           @"content": self.content};
    return [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
}

@end