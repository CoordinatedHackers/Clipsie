//
//  CHDoliaOffer.m
//  Dolia
//
//  Created by Sidney San Martín on 5/7/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

#import "CHDoliaOffer.h"

__attribute__((noreturn)) static void raiseUnimplementedException(const char *method) {
    [[NSException exceptionWithName:[NSString stringWithFormat:@"%s called on base CHDoliaOffer", method]
                             reason:@"Subclasses of CHDoliaOffer must implement this method"
                           userInfo:nil] raise];
    __builtin_unreachable();
}

@implementation CHDoliaOffer

@dynamic received;

+ (instancetype)offerInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    return [NSEntityDescription insertNewObjectForEntityForName:self.entityName inManagedObjectContext:managedObjectContext];
}

+ (CHDoliaOffer *)deserializeWithData:(NSData *)data managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSString *type = json[@"type"];

    if ([type isEqualToString:@"text"]) {
        CHDoliaTextOffer *offer = [CHDoliaTextOffer offerInManagedObjectContext:managedObjectContext];
        offer.string = json[@"content"];
        return offer;
    } else if ([type isEqualToString:@"url"]) {
        CHDoliaURLOffer *offer = [CHDoliaURLOffer offerInManagedObjectContext:managedObjectContext];
        offer.url = json[@"url"];
        return offer;
    } else if ([type isEqualToString:@"file"]) {
        // TODO: actually implement this
        CHDoliaFileOffer *offer = [CHDoliaFileOffer offerInManagedObjectContext:managedObjectContext];
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

@implementation CHDoliaTextOffer

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

@implementation CHDoliaURLOffer

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

@implementation CHDoliaFileOffer

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