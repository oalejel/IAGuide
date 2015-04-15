//
//  LocationStore.h
//  IAGuide
//
//  Created by Omar Alejel on 9/21/14.
//  Copyright (c) 2014 Omar Alejel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Location;//swift location file

@interface LocationStore : NSObject

@property (nonatomic, readonly) NSDictionary *allItems;

+ (instancetype)sharedStore; //returns the same instance all the time
- (Location *)locationForRoomNumber:(NSNumber *)roomNumber;
- (void)clearDataForMemoryWarning;

@end
