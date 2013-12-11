//
//  Alarm+CD.m
//  Geographic Proximity Alarm
//
//  Created by Matthew Schurr on 11/5/13.
//  Copyright (c) 2013 Schurr Solutions. All rights reserved.
//

#import "Alarm+CD.h"
#import <CoreData/CoreData.h>

@implementation Alarm (CD)

+ (Alarm *) createAlarmWithIdentifier: (NSString *) identifier
               inManagedObjectContent: (NSManagedObjectContext *) context
{
    Alarm *alarm = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: @"Alarm"];
    request.sortDescriptors = @[];
    request.fetchLimit = 1;
    request.predicate = [NSPredicate predicateWithFormat: @"alarmName = %@", identifier];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest: request error: &error];
    
    if(matches && [matches count] == 1) {
        return [matches lastObject];
    }
    
    if(!alarm) {
        alarm = [NSEntityDescription insertNewObjectForEntityForName: @"Alarm"
                                              inManagedObjectContext: context];
        alarm.alarmName = identifier;
        alarm.alarmIsReminder = [NSNumber numberWithBool: NO];
        alarm.alarmText = @"";
    }
    
    return alarm;
}

+ (BOOL) alarmExistsWithIdentifier: (NSString *) identifier
            inManagedObjectContext: (NSManagedObjectContext *) context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: @"Alarm"];
    request.sortDescriptors = @[];
    request.fetchLimit = 1;
    request.predicate = [NSPredicate predicateWithFormat: @"alarmName = %@", identifier];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest: request error: &error];
    
    if(matches && [matches count] == 1)
        return YES;
    return NO;
}

+ (NSArray *) activeAlarmsInManagedObjectContext:(NSManagedObjectContext *)context
{
    if(!context)
        return nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: @"Alarm"];
    request.sortDescriptors = @[];
    request.fetchLimit = 100;
    request.predicate = [NSPredicate predicateWithFormat: @"alarmEnabled = %@", [NSNumber numberWithBool: YES]];
    request.fetchBatchSize = 100;
    NSArray *result = [context executeFetchRequest: request error: nil];
    return result;
}

@end
