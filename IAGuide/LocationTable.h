//
//  LocationTable.h
//  IAGuide
//
//  Created by Omar Alejel on 12/13/14.
//  Copyright (c) 2014 Omar Alejel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MapViewController.h"

@interface LocationTable : UITableView <UITableViewDataSource, UITableViewDelegate>

- (instancetype)initWithTableviewFrame:(CGRect)frame homeController:(MapViewController *)hc;
- (void)reloadTableWithTeacherFilter:(BOOL)filterByTeacher;
- (void)reloadTableWithFilterString:(NSString *)string;

@end
