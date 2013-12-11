//
//  GeoPoint+CD.m
//  Geographic Proximity Alarm
//
//  Created by Matthew Schurr on 11/5/13.
//  Copyright (c) 2013 Schurr Solutions. All rights reserved.
//

#import "GeoPoint+CD.h"
#import "Alarm+CD.h"

@implementation GeoPoint (CD)

+ (GeoPoint *) createGeoPointForAlarm: (Alarm *) alarm
{
    GeoPoint *geopoint = [NSEntityDescription insertNewObjectForEntityForName: @"GeoPoint" inManagedObjectContext: alarm.managedObjectContext];
    geopoint.alarm = alarm;
    return geopoint;
}

@end
