//
//  Location.m
//  IAGuide
//
//  Created by Omar Alejel on 9/28/14.
//  Copyright (c) 2014 Omar Alejel. All rights reserved.
//

#import "Location.h"

@implementation Location

- (instancetype)initWithTitle:(NSString *)title Coordinate:(CLLocationCoordinate2D)coordinate
{
    self = [super init];
    
    if (self) {
        _coordinate = coordinate;
        _title = title;
    }
    
    return self;
}

//this method is used by the map to change the location
- (void)setCoordinate:(CLLocationCoordinate2D)coordinate
{
    _coordinate = coordinate;
}

@end
