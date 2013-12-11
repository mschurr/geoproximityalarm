//
//  MapRegionSelectionViewController.h
//  Geographic Proximity Alarm
//
//  Created by Matthew Schurr on 11/4/13.
//  Copyright (c) 2013 Schurr Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Alarm+CD.h"

@interface MapRegionSelectionViewController : UIViewController <MKMapViewDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *titleButton;
@property (strong, nonatomic) Alarm *alarm;
@property (nonatomic) BOOL isReminder;
- (void) editAlarm: (Alarm *) alarm;
- (void) editReminder: (Alarm *) alarm;
- (void) addAlarm;
- (void) addReminder;
@end
