//
//  LocationStore.m
//  IAGuide
//
//  Created by Omar Alejel on 9/21/14.
//  Copyright (c) 2014 Omar Alejel. All rights reserved.
//

#import "LocationStore.h"

@interface LocationStore ()

@property (nonatomic, strong) NSArray *privateItems;
@property (nonatomic, strong) NSArray *allItems;

@end

@implementation LocationStore



+(NSArray *)sharedStore
{
    return [[self alloc] initPrivate];
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"incorrect initializer" reason:@"dont use init" userInfo:nil];
}

- (void)initPrivate
{
    self = [super init];
    
    self.privateItems = [[NSArray alloc] init];
}

@end
