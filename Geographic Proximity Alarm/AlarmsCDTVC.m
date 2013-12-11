//
//  AlarmsCDTVC.m
//  Geographic Proximity Alarm
//
//  Created by Matthew Schurr on 11/16/13.
//  Copyright (c) 2013 Schurr Solutions. All rights reserved.
//

#import "AlarmsCDTVC.h"

@interface AlarmsCDTVC ()

@end

@implementation AlarmsCDTVC

- (NSPredicate *) predicate
{
    return [NSPredicate predicateWithFormat: @"alarmIsReminder = %@", [NSNumber numberWithBool: NO]];
}

- (NSString *) defaultText
{
    return @"Welcome to Geographic Proximity Alarm!\n\nThis application allows you to define alarms for geographic regions. When you enter one of the regions you define, an alarm will sound.\n\nTo get started, tap the + symbol in the top right.";
}


@end
