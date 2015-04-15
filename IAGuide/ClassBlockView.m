//
//  ClassBlockView.m
//  IAGuide
//
//  Created by Omar Alejel on 1/4/15.
//  Copyright (c) 2015 Omar Alejel. All rights reserved.
//

#import "ClassBlockView.h"

@implementation ClassBlockView

//for efficiency's sake, i am accessing textlabels by tag (check the xib file and open object
//inspector to find the tag). Heres how its organized:
//Title tag = 0
//Block1 tag = 1, block2 = 3, block4 = 4, block5 = 5, block6 = 6
//access labels using [self viewForTag:(#)];

- (instancetype)initWithTitles:(NSArray *)titleArray
{
    NSArray *viewArray = [[NSBundle mainBundle] loadNibNamed:@"ClassBlockView" owner:self options:0];
    self = (ClassBlockView *)[viewArray firstObject];
    
    if (titleArray) {
        int currentIndex = 0;
        for (NSString *title in titleArray) {
            UILabel *label = (UILabel *)[self viewWithTag:currentIndex];
            label.text = title;
            currentIndex++;
        }
    }
    
    return self;
}

@end
