//
//  GeoRegion.h
//  Geographic Proximity Alarm
//
//  Created by Matthew Schurr on 11/4/13.
//  Copyright (c) 2013 Schurr Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Alarm, GeoRegionPoint;

@interface GeoRegion : NSManagedObject

@property (nonatomic, retain) Alarm *alarm;
@property (nonatomic, retain) GeoRegionPoint *geoRegionPoints;

@end
