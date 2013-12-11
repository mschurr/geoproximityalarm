//
//  GeoAlarmAppDelegate.h
//  Geographic Proximity Alarm
//
//  Created by Matthew Schurr on 10/16/13.
//  Copyright (c) 2013 Schurr Solutions. All rights reserved.
//
/*
todo: finish settings tab
todo: use long range location services --> close range, account for CLLocationAccuracy OR region monitoring OR defer updates for time if distance is large
todo: update table view to be like native alarm app

Possible Extensions:
-Search for addresses on map
*/

#import <UIKit/UIKit.h>


@interface GeoAlarmAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
