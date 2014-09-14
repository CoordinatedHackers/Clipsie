//
//  CHDoliaOffer.h
//  Dolia
//
//  Created by Sidney San Martín on 5/7/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CHDoliaOffer : NSManagedObject

+ (instancetype)offerInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (CHDoliaOffer *)deserializeWithData:(NSData *)data managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSString *)entityName;

@property NSDate *received;

@property (readonly) NSString *type;
@property (readonly) NSDictionary *json;
@property (readonly) NSString *preview;
@property (readonly) NSData *data;

- (void)accept;

@end

@interface CHDoliaTextOffer : CHDoliaOffer

@property NSString *string;

@end

@interface CHDoliaURLOffer : CHDoliaOffer

@property NSURL *url;

@end

@interface CHDoliaFileOffer : CHDoliaOffer

@property (retain) NSURL *file;
@property NSString *filename; // FIXME: sending more than one file?
@property NSData *content;

@end