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

@end

@interface CHDoliaClipboardOffer : CHDoliaOffer

@property (retain) NSDictionary *data;

- (id)initWithData:(NSDictionary *)data;

@end