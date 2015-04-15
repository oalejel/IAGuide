//
//  LocationStore.m
//  IAGuide
//
//  Created by Omar Alejel on 9/21/14.
//  Copyright (c) 2014 Omar Alejel. All rights reserved.
//

#import "LocationStore.h"
#import <MapKit/MapKit.h>
#import "IAGuide-Swift.h"//this will allow swift files to interact with objc

@interface LocationStore ()

@property (nonatomic, strong) NSDictionary *privateItems;

@end

@implementation LocationStore

+ (instancetype)sharedStore
{
    static LocationStore *sharedStore;
    
    if (!sharedStore || !sharedStore.privateItems) {
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

- (NSDictionary *)setupDictionary
{
    //dictionary that only holds data -- ISC is at 999
    NSDictionary *itemDictionary = @{ @101: @[@42.603764, @-83.225914],
                                             @102: @[@42.603641, @-83.225912],
                                      @110: @[@42.603644, @-83.226446], @213: @[@42.603091,@-83.225674],
                                      @211: @[@42.603168, @-83.225678], @209: @[@42.603240, @-83.225682],
                                      @207: @[@42.603403, @-83.225701], @205: @[@42.603512, @-83.225636], @203: @[@42.603605, @-83.225632], @308: @[@42.603244, @-83.226262], @201: @[@42.603617, @-83.225712], @999: @[@42.603147, @-83.225955], @310: @[@42.603127, @-83.226262], @306: @[@42.603348, @-83.226249],
                                      @304: @[@42.603428, @-83.226249], @206: @[@42.603391, @-83.225855], @305: @[@42.603350, @-83.226080], @302: @[@42.603502,@-83.226229], @109: @[@42.603499,@-83.226303], @111: @[@42.603504,@-83.226412], @113: @[@42.603500,@-83.226501], @403: @[@42.603420,@-83.226473], @405: @[@42.603338,@-83.226473], @408: @[@42.603338,@-83.226610], @406: @[@42.603414,@-83.226608], @402: @[@42.603511,@-83.226584], @404: @[@42.603493,@-83.226677], @108: @[@42.603748,@-83.226448], @105: @[@42.603712,@-83.226297], @107: @[@42.603666,@-83.226296], @303: @[@42.603427,@-83.226077], @301: @[@42.603510,@-83.226114], @103:
                                          @[@42.603589,@-83.225909], @104: @[@42.603502,@-83.225983], @106: @[@42.603396,@-83.225966] };
    
    //NSLog(@"dictionary looks like: %@", itemDictionary);
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    for (NSNumber *roomNumber in itemDictionary) {
        NSArray *coordinateArray = itemDictionary[roomNumber];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([coordinateArray[0] doubleValue], [coordinateArray[1] doubleValue]);
        Location *location = [[Location alloc] initWithRoomNumber:roomNumber.integerValue coordinate:coordinate];
        dictionary[roomNumber] = location;
    }
    
    return dictionary;
}

- (Location *)locationForRoomNumber:(NSNumber *)roomNumber
{
    return [self.privateItems objectForKey:roomNumber];
}

- (void)clearDataForMemoryWarning
{
    self.privateItems = nil;
}


@end
