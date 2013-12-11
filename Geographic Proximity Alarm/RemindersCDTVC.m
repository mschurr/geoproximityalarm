//
//  RemindersCDTVC.m
//  Geographic Proximity Alarm
//
//  Created by Matthew Schurr on 11/16/13.
//  Copyright (c) 2013 Schurr Solutions. All rights reserved.
//

#import "RemindersCDTVC.h"

@interface RemindersCDTVC ()

@end

@implementation RemindersCDTVC

- (NSPredicate *) predicate
{
    return [NSPredicate predicateWithFormat: @"alarmIsReminder = %@", [NSNumber numberWithBool: YES]];
}

- (NSString *) defaultText
{
    return @"You can use this section to define reminders based on geographic location. When you enter one of the regions you define, you will receive a notification.\n\nTo get started, tap the + symbol in the top right.";
}

@end
