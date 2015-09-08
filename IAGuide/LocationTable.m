//
//  LocationTable.m
//  IAGuide
//
//  Created by Omar Alejel on 12/13/14.
//  Copyright (c) 2014 Omar Alejel. All rights reserved.
//

#import "LocationTable.h"
#import "LocationStore.h"
#import "InfoViewController.h"

@interface LocationTable ()

@property (nonatomic) BOOL searchByTeacher;
@property (nonatomic) MapViewController *homeController;
@property (nonatomic) NSArray *roomNumbers;
@property (nonatomic) NSArray *teacherNames;
@property (nonatomic) NSString *teacherFilterString;

@end

@implementation LocationTable

#pragma Mark - Initializers

- (instancetype)initWithTableviewFrame:(CGRect)frame homeController:(MapViewController *)hc
{
    self = [super initWithFrame:frame style:UITableViewStylePlain];
    if (self) {
        [self registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        //customize look
        self.backgroundView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        self.separatorColor = [UIColor darkGrayColor];
        self.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
        //make sure delegate and data source methods are called
        self.delegate = self;
        self.dataSource = self;
        
        self.homeController = hc; //pointer to owner viewcontroller to call
        
        self.roomNumbers = [[[LocationStore sharedStore] allItems] allKeys];
        //sort the roomnumber array by room number
        self.roomNumbers = [self.roomNumbers sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            if ([obj1 intValue] == 999) {
                return NSOrderedAscending;
            } else if ([obj2 intValue] == 999) {
                return NSOrderedDescending;
            }
            if ([obj1 intValue] > [obj2 intValue]) {
                return NSOrderedDescending;
            } else {
                return NSOrderedAscending;
            }
        }];
    }
    
    return self;
}

- (instancetype)init //dont call/invoke/use this, call the above one
{
    @throw [NSException exceptionWithName:@"dont use locationtable's init method" reason:@"use other init" userInfo:nil];
}

#pragma mark - Tableview Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchByTeacher) {
        return [self.teacherNames count] / 2; //change this
    } else {
        return [[[LocationStore sharedStore] allItems] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.backgroundView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
        
    if (self.searchByTeacher) {
        NSString *name = self.teacherNames[(indexPath.row * 2) + 1];
        cell.textLabel.text = name;
    } else {
        int cellRoomNumber = [[self.roomNumbers objectAtIndex:indexPath.row] intValue];
        if (cellRoomNumber != 999) {
            cell.textLabel.text = [NSString stringWithFormat:@"Room %d", cellRoomNumber];
        } else {
            cell.textLabel.text = @"ISC";
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.searchByTeacher) {
        int teacherCode = (int)indexPath.row + 1;
        InfoViewController *ivc = [[InfoViewController alloc] initWithTeacherCode:teacherCode];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        ivc.navigationItem.title = cell.textLabel.text;
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:ivc];
        nvc.navigationBar.barTintColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.9 alpha:1.0];
        nvc.navigationBar.tintColor = [UIColor whiteColor];
        NSDictionary *attrib = @{ NSForegroundColorAttributeName : [UIColor whiteColor] };
        nvc.navigationBar.titleTextAttributes = attrib;
        [self.homeController presentViewController:nvc animated:YES completion:^{
            [self deselectRowAtIndexPath:indexPath animated:NO];
        }];
    } else {
        [self.homeController showRoomLocationWithRoomNumber:[self.roomNumbers objectAtIndex:indexPath.row]];
        [self deselectRowAtIndexPath:indexPath animated:YES];
    }
    
}

- (void)reloadTableWithTeacherFilter:(BOOL)filterByTeacher
{
    if (!self.teacherNames) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Teachers" ofType:@"plist"];
        self.teacherNames = [NSArray arrayWithContentsOfFile:path];
    }
    
    self.searchByTeacher = filterByTeacher;
    //now cell for row will see the filter change
    //do stuff
    [self reloadData];
}

- (void)reloadTableWithFilterString:(NSString *)string
{
    
}

@end
