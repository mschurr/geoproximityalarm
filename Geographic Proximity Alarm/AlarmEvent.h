//
//  AlarmEvent.h
//  Geographic Proximity Alarm
//
//  Created by Matthew Schurr on 11/6/13.
//  Copyright (c) 2013 Schurr Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Alarm+CD.h"

@interface AlarmEvent : NSObject

+ (AlarmEvent *) standardAlarmEvent;
- (void) showAlertForNotification: (UILocalNotification *) notification;
- (void) alarmStateDidUpdate;

@end
