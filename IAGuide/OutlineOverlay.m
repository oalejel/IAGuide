//
//  OutlineOverlay.m
//  IAGuide
//
//  Created by Omar Alejel on 10/6/14.
//  Copyright (c) 2014 Omar Alejel. All rights reserved.
//

#import "OutlineOverlay.h"

@implementation OutlineOverlay

- (MKMapRect)boundingMapRect
{
    MKMapRect mapRect = MKMapRectMake(42.602947,-83.225602, 10, 10);
    
    return mapRect;
}

- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake(42.603363, -83.226143);
}

@end
