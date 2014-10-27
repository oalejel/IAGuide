//
//  LocationStore.h
//  IAGuide
//
//  Created by Omar Alejel on 9/21/14.
//  Copyright (c) 2014 Omar Alejel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Location.h"

@interface LocationStore : NSObject

@property (nonatomic, readonly) NSDictionary *allItems;

+ (instancetype)sharedStore;

- (Location *)locationForRoomNumber:(NSNumber *)roomNumber;

@end
