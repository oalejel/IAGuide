//
//  Location.h
//  IAGuide
//
//  Created by Omar Alejel on 9/28/14.
//  Copyright (c) 2014 Omar Alejel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Location : NSObject <MKAnnotation>

- (instancetype)initWithTitle:(NSString *)title Coordinate:(CLLocationCoordinate2D)coordinate;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@end
