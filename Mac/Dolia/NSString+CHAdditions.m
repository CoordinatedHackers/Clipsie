//
//  NSString+CHAdditions.m
//  Dolia
//
//  Created by Sidney San Martín on 8/17/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

#import "NSString+CHAdditions.h"

@implementation NSString (CHAdditions)

- (NSString *)truncate: (NSUInteger)length overflow:(NSString *)overflow
{
    // http://stackoverflow.com/a/2953277/84745
    NSRange range = [self rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, MIN(self.length, length))];
    if (range.length < self.length) {
        return [[self substringWithRange:range] stringByAppendingString:overflow];
    } else {
        return self;
    }

}

@end
