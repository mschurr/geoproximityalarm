//
//  NetworkActivityManager.m
//  Shutterbug
//
//  Created by Matthew Schurr on 10/13/13.
//  Copyright (c) 2013 Schurr Solutions. All rights reserved.
//

#import "NetworkActivityManager.h"

@interface NetworkActivityManager()

@property (strong, atomic) NSNumber *access;

@end

@implementation NetworkActivityManager

- (id) init
{
    self = [super init];
    
    if(self) {
        self.access = [[NSNumber alloc] initWithUnsignedInt: 0];
    }
    
    return self;
}

+ (NetworkActivityManager *) standardNetworkActivityManager
{
    static NetworkActivityManager *manager = nil;
    
    if(!manager) {
        manager = [[NetworkActivityManager alloc] init];
    }
    
    return manager;
}

- (void) registerNetworkActivity
{
    self.access = [[NSNumber alloc] initWithUnsignedInteger: [self.access unsignedIntegerValue] + 1];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void) unregisterNetworkActivity;
{
    if([self.access unsignedIntegerValue] > 0)
        self.access = [[NSNumber alloc] initWithUnsignedInteger: [self.access unsignedIntegerValue] - 1];
    
    if([self.access unsignedIntegerValue] == 0)
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
