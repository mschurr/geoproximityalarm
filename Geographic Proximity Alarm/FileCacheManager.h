//
//  FileCacheManager.h
//  Shutterbug
//
//  Created by Matthew Schurr on 10/13/13.
//  Copyright (c) 2013 Schurr Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FileCacheManager : NSObject

+ (NSData *) waitForDataForURL: (NSURL *) url;

@end
