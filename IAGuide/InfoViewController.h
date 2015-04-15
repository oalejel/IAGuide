//
//  InfoViewController.h
//  IAGuide
//
//  Created by Omar Alejel on 11/6/14.
//  Copyright (c) 2014 Omar Alejel. All rights reserved.
// This View Controller manages the schedule tableView that shows class schedule data

#import <UIKit/UIKit.h>

@interface InfoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>//check if these can be made more public

- (instancetype)initWithRoomNumber:(int)number;
- (instancetype)initWithTeacherCode:(int)teacherCode;//for teacher searches

@property (nonatomic) int roomNumber;
@property (nonatomic) NSArray *classesInfo;

@end
