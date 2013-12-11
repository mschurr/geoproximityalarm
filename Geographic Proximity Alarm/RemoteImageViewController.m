//
//  RemoteImageViewController.m
//  Shutterbug
//
//  Created by Matthew Schurr on 10/13/13.
//  Copyright (c) 2013 Schurr Solutions. All rights reserved.
//

#import "RemoteImageViewController.h"
#import "FileCacheManager.h"

@interface RemoteImageViewController ()

@end

@implementation RemoteImageViewController

- (void) setImageURL: (NSURL *) imageURL
{ 
    _imageURL = imageURL;
    [self.activityIndicator startAnimating];
    dispatch_queue_t thread = dispatch_queue_create("loadURL", NULL);
    dispatch_async(thread, ^{
        NSData *imageData = [FileCacheManager waitForDataForURL: imageURL];
        UIImage *image = [[UIImage alloc] initWithData: imageData];
        if(self.imageURL != imageURL)
            return;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(image && self.isViewLoaded && self.view.window) {
                self.image = image;
            }
            [self.activityIndicator stopAnimating];
        });
    });
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    if(!self.image && self.imageURL) {
        [self.activityIndicator startAnimating];
    }
}

@end
