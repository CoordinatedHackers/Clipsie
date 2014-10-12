//
//  CHClipsieOffer.m
//  Clipsie
//
//  Created by Sidney San Martín on 5/7/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

#import "CHClipsieOffer.h"

__attribute__((noreturn)) static void raiseUnimplementedException(const char *method) {
    [[NSException exceptionWithName:[NSString stringWithFormat:@"%s called on base CHClipsieOffer", method]
                             reason:@"Subclasses of CHClipsieOffer must implement this method"
                           userInfo:nil] raise];
    __builtin_unreachable();
}

@implementation CHClipsieOffer

@dynamic received;

+ (instancetype)offerInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    return [NSEntityDescription insertNewObjectForEntityForName:self.entityName inManagedObjectContext:managedObjectContext];
}

+ (CHClipsieOffer *)deserializeWithData:(NSData *)data managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSString *type = json[@"type"];

    if ([type isEqualToString:@"text"]) {
        CHClipsieTextOffer *offer = [CHClipsieTextOffer offerInManagedObjectContext:managedObjectContext];
        offer.string = json[@"content"];
        return offer;
    } else if ([type isEqualToString:@"url"]) {
        CHClipsieURLOffer *offer = [CHClipsieURLOffer offerInManagedObjectContext:managedObjectContext];
        offer.url = json[@"url"];
        return offer;
    } else if ([type isEqualToString:@"file"]) {
        // TODO: actually implement this
        CHClipsieFileOffer *offer = [CHClipsieFileOffer offerInManagedObjectContext:managedObjectContext];
        offer.filename = json[@"filename"];
        return offer;
    } else {
        NSLog(@"Unknown Type: %@", type);
        return nil;
    }
}

- (id)type { raiseUnimplementedException(__PRETTY_FUNCTION__); }
- (NSDictionary *)json { raiseUnimplementedException(__PRETTY_FUNCTION__); }
- (NSString *)preview { raiseUnimplementedException(__PRETTY_FUNCTION__); }
- (void)accept { raiseUnimplementedException(__PRETTY_FUNCTION__); }

- (NSDictionary *)jsonPlus:(NSDictionary *)extra
{
    NSMutableDictionary *ret = [@{ @"type": self.type } mutableCopy];
    [ret addEntriesFromDictionary:extra];
    return ret;
}

- (NSData *)data
{
    return [NSJSONSerialization dataWithJSONObject:self.json options:0 error:nil];
}

+ (NSString *)entityName { raiseUnimplementedException(__PRETTY_FUNCTION__); }

@end

@implementation CHClipsieTextOffer

@dynamic string;

- (NSString *)type { return @"text"; }

- (NSDictionary *)json
{
    return [super jsonPlus:@{
        @"content": self.string
    }];
}

- (NSString *)preview { return self.string; }

+ (NSString *)entityName { return @"TextOffer"; }

@end

@implementation CHClipsieURLOffer

@dynamic url;

- (NSString *)type { return @"url"; }

- (NSDictionary *)json
{
    return [super jsonPlus:@{
        @"url": self.url
    }];
}

- (NSString *)preview { return self.url; }

+ (NSString *)entityName { return @"URLOffer"; }

@end

@implementation CHClipsieFileOffer

@synthesize file;
@dynamic filename;
@dynamic content;

- (NSURL *)file
{
    return file;
}
- (void)setFile:(NSURL *)newFile
{
    file = newFile;
    
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingFromURL:file error:nil];
    self.content = [handle availableData];
    
    NSString *filename;
    if ([file getResourceValue:&filename forKey:NSURLNameKey error:nil]) {
        self.filename = filename;
    } else {
        NSLog(@"Bad news bears, couldn't get filename for %@", file);
    }
}

- (NSString *)type { return @"file"; }

- (NSDictionary *)json
{
    return [super jsonPlus:@{
        @"filename": self.filename,
        @"content": [self.content base64EncodedStringWithOptions:0]
    }];
}

- (NSString *)preview { return self.filename; }

+ (NSString *)entityName { return @"FileOffer"; }

@end
