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

+ (CHDoliaOffer *)deserializeWithData:(NSData *)data
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSString *type = json[@"type"];

    if ([type isEqualToString:@"text"]) {
        return [[CHDoliaTextOffer alloc] initWithString:json[@"content"]];
    } else if ([type isEqualToString:@"url"]) {
        return [[CHDoliaURLOffer alloc] initWithURL:[NSURL URLWithString:json[@"url"]]];
    } else if ([type isEqualToString:@"file"]) {
        // TODO: actually implement this
        return [[CHDoliaTextOffer alloc] initWithString:json[@"filename"]];
    } else {
        NSLog(@"Unknown Type: %@", type);
        return nil;
    }
}

+ (CHDoliaOffer *)offerFromManagedObject:(NSManagedObject *)managedObject
{
    return [CHDoliaOffer new];
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

- (NSString *)entityName { raiseUnimplementedException(__PRETTY_FUNCTION__); }

- (void)saveToManagedObject:(NSManagedObject *)managedObject
{
    [managedObject setValue:self.received forKey:@"received"];
}

- (BOOL)savetoManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError **)error
{
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:self.entityName inManagedObjectContext:managedObjectContext];
    [self saveToManagedObject:managedObject];
    return [managedObjectContext save:error];
}

@end

@implementation CHDoliaTextOffer

- (instancetype) initWithString:(NSString *)string
{
    if (self = [self init]){
        self.string = string;
    }
    return self;
}

- (NSString *)type { return @"text"; }

- (NSDictionary *)json
{
    return [super jsonPlus:@{
        @"content": self.string
    }];
}

- (NSString *)preview { return self.string; }

- (NSString *)entityName { return @"TextOffer"; }

- (void)saveToManagedObject:(NSManagedObject *)managedObject
{
    [super saveToManagedObject:managedObject];
    [managedObject setValue:self.string forKey:@"string"];
}

@end

@implementation CHDoliaURLOffer

- (instancetype) initWithURL:(NSURL *)url
{
    if (self = [self init]){
        self.url = url;
    }
    return self;
}

- (NSString *)type { return @"url"; }

- (NSDictionary *)json
{
    return [super jsonPlus:@{
        @"url": [self.url absoluteString]
    }];
}

- (NSString *)preview { return [self.url absoluteString]; }

- (NSString *)entityName { return @"URLOffer"; }

- (void)saveToManagedObject:(NSManagedObject *)managedObject
{
    [super saveToManagedObject:managedObject];
    [managedObject setValue:self.url forKey:@"url"];
}

@end

@implementation CHDoliaFileOffer

- (instancetype) initWithURL:(NSURL *)url
{
    if (self = [self init]){
        NSFileHandle *handle = [NSFileHandle fileHandleForReadingFromURL:url error:nil];
        self.content = [handle availableData];
        
        NSString *filename;
        if ([url getResourceValue:&filename forKey:NSURLNameKey error:nil]) {
            self.filename = filename;
        } else {
            NSLog(@"Bad news bears, couldn't get filename for %@", url);
        }
    }
    return self;
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

- (NSString *)entityName { return @"FileOffer"; }

- (void)saveToManagedObject:(NSManagedObject *)managedObject
{
    [super saveToManagedObject:managedObject];
    [managedObject setValue:self.filename forKey:@"filename"];
    [managedObject setValue:self.content forKey:@"content"];
}

@end