//
//  GeoAlarmMasterCDTVC.h
//  Geographic Proximity Alarm
//
//  Created by Matthew Schurr on 11/9/13.
//  Copyright (c) 2013 Schurr Solutions. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "CoreDatabase.h"

@interface GeoAlarmMasterCDTVC : CoreDataTableViewController

- (void) databaseIsReady: (CoreDatabase *) database;
@property (strong, nonatomic) NSPredicate *predicate;
@property (strong, nonatomic) NSString *defaultText;
@end
