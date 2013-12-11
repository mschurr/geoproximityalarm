//
//  Alarm.h
//  Geographic Proximity Alarm
//
//  Created by Matthew Schurr on 11/16/13.
//  Copyright (c) 2013 Schurr Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GeoPoint;

@interface Alarm : NSManagedObject

@property (nonatomic, retain) NSNumber * alarmEnabled;
@property (nonatomic, retain) NSString * alarmName;
@property (nonatomic, retain) NSNumber * alarmIsReminder;
@property (nonatomic, retain) NSString * alarmText;
@property (nonatomic, retain) NSSet *geoPoints;
@end

@interface Alarm (CoreDataGeneratedAccessors)

- (void)addGeoPointsObject:(GeoPoint *)value;
- (void)removeGeoPointsObject:(GeoPoint *)value;
- (void)addGeoPoints:(NSSet *)values;
- (void)removeGeoPoints:(NSSet *)values;

@end
