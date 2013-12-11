//
//  Alarm+CD.h
//  Geographic Proximity Alarm
//
//  Created by Matthew Schurr on 11/5/13.
//  Copyright (c) 2013 Schurr Solutions. All rights reserved.
//

#import "Alarm.h"
#import <CoreData/CoreData.h>

@interface Alarm (CD)

+ (Alarm *) createAlarmWithIdentifier: (NSString *) identifier
               inManagedObjectContent: (NSManagedObjectContext *) context;

+ (BOOL) alarmExistsWithIdentifier: (NSString *) identifier
            inManagedObjectContext: (NSManagedObjectContext *) context;

+ (NSArray *) activeAlarmsInManagedObjectContext: (NSManagedObjectContext *) context;

@end
