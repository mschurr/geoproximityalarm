//
//  NetworkActivityManager.h
//  Shutterbug
//
//  Created by Matthew Schurr on 10/13/13.
//  Copyright (c) 2013 Schurr Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkActivityManager : NSObject

+ (NetworkActivityManager *) standardNetworkActivityManager;

- (void) registerNetworkActivity;
- (void) unregisterNetworkActivity;

@end
