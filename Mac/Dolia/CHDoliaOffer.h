//
//  CHDoliaOffer.h
//  Dolia
//
//  Created by Sidney San Martín on 5/7/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHDoliaOffer : NSObject

+ (CHDoliaOffer *)offerWithClipboard;
+ (CHDoliaOffer *)deserializeWithData:(NSData *)data;

@property (readonly, getter = getData) NSData *data;
@property NSString *type;
@property NSObject *content;

- (void)accept;
- (NSString *)preview; // Maybe make me a readonly property?

@end

@interface CHDoliaTextOffer : CHDoliaOffer

@property NSString *content;
- (instancetype)initWithString:(NSString *)string;

@end

@interface CHDoliaURLOffer : CHDoliaOffer

@property NSString *content;
- (instancetype)initWithURL:(NSURL *)url;

@end

@interface CHDoliaFileOffer : CHDoliaOffer

@property NSString *content;
@property NSString *filename; // FIXME: sending more than one file?
- (instancetype)initWithURL:(NSURL *)url;
- (NSData *)getData;

- (NSString *)preview; // Maybe make me a readonly property?

@end