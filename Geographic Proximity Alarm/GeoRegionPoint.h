//
//  GeoRegionPoint.h
//  Geographic Proximity Alarm
//
//  Created by Matthew Schurr on 11/4/13.
//  Copyright (c) 2013 Schurr Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GeoRegion;

@interface GeoRegionPoint : NSManagedObject

@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * sortIndex;
@property (nonatomic, retain) GeoRegion *newRelationship;

@end
