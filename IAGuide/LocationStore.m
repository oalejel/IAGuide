//
//  LocationStore.m
//  IAGuide
//
//  Created by Omar Alejel on 9/21/14.
//  Copyright (c) 2014 Omar Alejel. All rights reserved.
//

#import "LocationStore.h"


@interface LocationStore ()

@property (nonatomic, strong) NSMutableDictionary *privateItems;

@end

@implementation LocationStore

+ (instancetype)sharedStore
{
    static LocationStore *sharedStore;
    
    if (!sharedStore) {
        sharedStore = [[self alloc] initPrivate];
    }
    
    return sharedStore;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"incorrect initializer"
                                   reason:@"dont use init"
                                 userInfo:nil];
}

- (instancetype)initPrivate
{
    self = [super init];
    
    if (self) {
        _privateItems = [self setupDictionary];
    }
    
    return self;
}

- (NSDictionary *)allItems
{
    return [self.privateItems copy];
}

- (NSMutableDictionary *)setupDictionary
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    //dictionary that only holds data
    NSDictionary *itemDictionary = @{ @101: @[@42.603764, @-83.225914],
                                             @102: @[@42.603641, @-83.225912],
                                      @110: @[@42.603644, @-83.226446]
                                      };
    
    NSLog(@"dictionary looks like: %@", itemDictionary);
    
    for (NSNumber *roomNumber in itemDictionary) {
        NSArray *coordinateArray = itemDictionary[roomNumber];
        NSString *numberString = [NSString stringWithFormat:@"Room %@", roomNumber.stringValue];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([coordinateArray[0] doubleValue], [coordinateArray[1] doubleValue]);
        Location *location = [[Location alloc] initWithTitle:numberString Coordinate:coordinate];
        dictionary[roomNumber] = location;
    }
    
    return dictionary;
}

- (Location *)locationForRoomNumber:(NSNumber *)roomNumber
{
    return [self.privateItems objectForKey:roomNumber];
}

@end
