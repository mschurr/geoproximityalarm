//
//  ImageViewController.h
//  Shutterbug
//
//  Created by Matthew Schurr on 10/2/13.
//  Copyright (c) 2013 Schurr Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController

@property (strong, nonatomic) UIImage *image;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
- (void) resetZoom;
@property (strong, nonatomic) UIBarButtonItem *splitViewBarButtonItem;

@end
