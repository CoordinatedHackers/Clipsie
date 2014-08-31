//
//  CHDoliaOffer.h
//  Dolia
//
//  Created by Sidney San Martín on 5/7/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CHDoliaOffer : NSObject

+ (CHDoliaOffer *)deserializeWithData:(NSData *)data;
+ (CHDoliaOffer *)offerFromManagedObject:(NSManagedObject *)managedObject;

@property NSDate *received;

@property (readonly) NSString *type;
@property (readonly) NSDictionary *json;
@property (readonly) NSString *preview;
@property (readonly) NSData *data;

@property (readonly) NSString *entityName;
- (void)saveToManagedObject:(NSManagedObject *)managedObject;
- (BOOL)savetoManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError **)error;

- (void)accept;

@end

@interface CHDoliaTextOffer : CHDoliaOffer

@property NSString *string;
- (instancetype)initWithString:(NSString *)string;

@end

@interface CHDoliaURLOffer : CHDoliaOffer

@property NSURL *url;
- (instancetype)initWithURL:(NSURL *)url;

@end

@interface CHDoliaFileOffer : CHDoliaOffer

@property NSString *filename; // FIXME: sending more than one file?
@property NSData *content;

- (instancetype)initWithURL:(NSURL *)url;

@end