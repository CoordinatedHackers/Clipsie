//
//  NSString+CHAdditions.h
//  Dolia
//
//  Created by Sidney San Martín on 8/17/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CHAdditions)

- (NSString *)truncate: (NSUInteger)length overflow:(NSString *)overflow;

@end
