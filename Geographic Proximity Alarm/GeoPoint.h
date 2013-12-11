//
//  GeoPoint.h
//  Geographic Proximity Alarm
//
//  Created by Matthew Schurr on 11/9/13.
//  Copyright (c) 2013 Schurr Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Alarm;

@interface GeoPoint : NSManagedObject

@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * radius;
@property (nonatomic, retain) Alarm *alarm;

@end
