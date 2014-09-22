//
//  LocationsSliderView.m
//  IASchoolGuide
//
//  Created by Omar Alejel on 8/21/14.
//  Copyright (c) 2014 Omar Alejel. All rights reserved.
//

#import "LocationsSliderView.h"

@interface LocationsSliderView ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, weak) UIViewController *owner;


@end

@implementation LocationsSliderView

- (IBAction)moveUp:(id)sender
{
    
}

- (IBAction)moveDown:(id)sender
{
    
}

- (instancetype)initWithFrame:(CGRect)frame
{
    @throw [NSException exceptionWithName:@"Wrong intializer"
                                   reason:@"Use the designated initalizer"
                                 userInfo:nil];
    
    return nil;
}

- (instancetype)initWithOwner:(UIViewController *)owner frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    self.owner = owner;
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
