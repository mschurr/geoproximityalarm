//
//  RemoteImageViewController.h
//  Shutterbug
//
//  Created by Matthew Schurr on 10/13/13.
//  Copyright (c) 2013 Schurr Solutions. All rights reserved.
//

#import "ImageViewController.h"
#import <UIKit/UIKit.h>

@interface RemoteImageViewController : ImageViewController

@property (strong, nonatomic) NSURL *imageURL;

@end
