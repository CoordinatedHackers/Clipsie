//
//  CHDoliaOffer.h
//  Dolia
//
//  Created by Sidney San Martín on 5/7/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHDoliaOffer : NSObject

- (void)accept;
- (NSString *)preview; // Maybe make me a readonly property?

@end

@interface CHDoliaClipboardOffer : CHDoliaOffer

@property (retain) NSDictionary *data;

- (id)initWithData:(NSDictionary *)data;

@end