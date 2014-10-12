//
//  CHClipsieOffer.h
//  Clipsie
//
//  Created by Sidney San Martín on 5/7/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CHClipsieOffer : NSManagedObject

+ (instancetype)offerInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (CHClipsieOffer *)deserializeWithData:(NSData *)data managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSString *)entityName;

@property NSDate *received;

@property (readonly) NSString *type;
@property (readonly) NSDictionary *json;
@property (readonly) NSString *preview;
@property (readonly) NSData *data;

- (void)accept;

@end

@interface CHClipsieTextOffer : CHClipsieOffer

@property NSString *string;

@end

@interface CHClipsieURLOffer : CHClipsieOffer

@property NSString *url;

@end

@interface CHClipsieFileOffer : CHClipsieOffer

@property (retain) NSURL *file;
@property NSString *filename; // FIXME: sending more than one file?
@property NSData *content;

@end
