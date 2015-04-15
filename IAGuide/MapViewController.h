//
//  MapViewController.h
//  IASchoolGuide
//
//  Created by Omar Alejel on 8/21/14.
//  Copyright (c) 2014 Omar Alejel. All rights reserved.
// The map view controller that allows users to search for room locatons and their schedules

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController <MKMapViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate>

- (void)showRoomLocationWithRoomNumber:(NSNumber *)number;

@end
