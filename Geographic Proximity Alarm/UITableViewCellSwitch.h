//
//  UITableViewCellSwitch.h
//  Geographic Proximity Alarm
//
//  Created by Matthew Schurr on 11/5/13.
//  Copyright (c) 2013 Schurr Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Alarm.h"

@interface UITableViewCellSwitch : UISwitch
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) Alarm *alarm;
@end
