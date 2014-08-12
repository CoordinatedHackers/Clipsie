//
//  CHDoliaOffer.m
//  Dolia
//
//  Created by Sidney San Martín on 5/7/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

#import "CHDoliaOffer.h"

@implementation CHDoliaOffer


+ (CHDoliaOffer *)deserializeWithData:(NSData *)data
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSString *type = json[@"type"];

    if (![json[@"content"] length]) {
        return nil;
    }

    if ([type isEqualToString:@"text"]) {
        return [[CHDoliaTextOffer alloc] initWithString:json[@"content"]];
    } else if ([type isEqualToString:@"url"]) {
        return [[CHDoliaURLOffer alloc] initWithURL:[NSURL URLWithString:json[@"content"]]];
    } else if ([type isEqualToString:@"file"]) {
        //FIXME actually implement this
        return [[CHDoliaTextOffer alloc] initWithString:json[@"filename"]];
    } else {
        NSLog(@"Unknown Type: %@", type);
        return nil;
    }
}

- (NSData *)getData
{
    NSDictionary *json = @{@"type": self.type,
                           @"content": self.content};
    return [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
}

- (void)accept {}
- (NSString *)preview
{
    return (NSString *)self.content;
}

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

- (NSString *)preview
{
    return self.filename;
}

@end