//
//  OutlineOverlay.h
//  IAGuide
//
//  Created by Omar Alejel on 10/6/14.
//  Copyright (c) 2014 Omar Alejel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface OutlineOverlay : NSObject <MKOverlay>

- (MKMapRect)boundingMapRect;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@end
