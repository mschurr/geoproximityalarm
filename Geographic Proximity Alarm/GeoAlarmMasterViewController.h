//
//  GeoAlarmMasterViewController.h
//  Geographic Proximity Alarm
//
//  Created by Matthew Schurr on 10/16/13.
//  Copyright (c) 2013 Schurr Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDatabase.h"

@interface GeoAlarmMasterViewController : UITableViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
- (void) databaseIsReady: (CoreDatabase *) database;

@end
