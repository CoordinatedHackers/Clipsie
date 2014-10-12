//
//  CHClipsieMacAdditions.h
//  Clipsie
//
//  Created by Sidney San Martín on 7/2/14.
//  Copyright (c) 2014 Coordinated Hackers. All rights reserved.
//

#import "CHClipsieOffer.h"

@interface CHClipsieOffer (CHClipsieMacAdditions)

+ (CHClipsieOffer *)offerWithClipboardWithManagedObjectContext:(NSManagedObjectContext *)context;

@end
