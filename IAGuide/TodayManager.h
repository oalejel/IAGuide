//
//  CurrentClassManager.h
//  IAGuide
//
//  Created by Omar Alejel on 12/20/14.
//  Copyright (c) 2014 Omar Alejel. All rights reserved.
//
//contains info on whether it is an a day or whether there is a break, etc.

#import <Foundation/Foundation.h>
@class ClassBlockViewContainer;

//enum for what type of lunch it should present
enum DayType {
    Standard,
    Late,
    Half,
    NoSchool
} typeOfDay;

@interface TodayManager : NSObject

+ (instancetype)sharedClassManager;
- (BOOL)todayIsAnADay:(NSDate *)date;
- (int)findCurrentClassForFirstLunch:(BOOL)firstLunch;
- (int)dayTypeForDate:(NSDate *)date;

- (BOOL)noSchool;
- (BOOL)halfDay;
- (BOOL)lateStart;
- (void)resetForNewDate;

@property (nonatomic, weak) ClassBlockViewContainer *delegate;//this will recieve notifications for change in class

@end
