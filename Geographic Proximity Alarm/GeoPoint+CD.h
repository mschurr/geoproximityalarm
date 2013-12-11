//
//  GeoPoint+CD.h
//  Geographic Proximity Alarm
//
//  Created by Matthew Schurr on 11/5/13.
//  Copyright (c) 2013 Schurr Solutions. All rights reserved.
//

#import "GeoPoint.h"

@interface GeoPoint (CD)

+ (GeoPoint *) createGeoPointForAlarm: (Alarm *) alarm;

@end
