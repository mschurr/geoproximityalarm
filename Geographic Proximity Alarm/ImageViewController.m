//
//  ImageViewController.m
//  Shutterbug
//
//  Created by Matthew Schurr on 10/2/13.
//  Copyright (c) 2013 Schurr Solutions. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController () <UIScrollViewDelegate> 
@property (weak, nonatomic) IBOutlet UIBarButtonItem *titleLabel;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@end

@implementation ImageViewController

- (void) setSplitViewBarButtonItem: (UIBarButtonItem *) splitViewBarButtonItem
{
    UIToolbar *toolbar = self.toolbar;
    NSMutableArray *toolbarItems = [toolbar.items mutableCopy];
    if (_splitViewBarButtonItem)
        [toolbarItems removeObject:_splitViewBarButtonItem];
    if (splitViewBarButtonItem)
        [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
    toolbar.items = toolbarItems;
    _splitViewBarButtonItem = splitViewBarButtonItem;
}

- (void) setTitle:(NSString *)title
{
    [super setTitle: title];
    self.titleLabel.title = title;
}

- (void) setImage: (UIImage *) image
{
    _image = image;
    [self resetImage];
}

- (void) resetImage
{
    if(!self.scrollView || !self.imageView || !self.isViewLoaded || !self.view.window || !self.image)
        return;
    
    self.scrollView.contentSize = CGSizeZero;
    self.imageView.image = nil;
    
    if(!self.image)
        return;
    
    self.scrollView.zoomScale = 1.0; 
    self.scrollView.contentSize = self.image.size;
    self.imageView.image = self.image;
    self.imageView.frame = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
    [self resetZoom];
}

- (UIImageView *) imageView
{
    if(!_imageView)
        _imageView = [[UIImageView alloc] initWithFrame: CGRectZero];
    return _imageView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView addSubview: self.imageView];
    self.scrollView.minimumZoomScale = 0.1;
    self.scrollView.maximumZoomScale = 5.0;
    self.scrollView.delegate = self;
    self.titleLabel.title = self.title;
    self.splitViewBarButtonItem = self.splitViewBarButtonItem;
    [self resetImage];
}

- (UIView *) viewForZoomingInScrollView: (UIScrollView *) scrollView
{
    return self.imageView; 
}

- (void) resetZoom
{
    if(!self.scrollView.bounds.size.width || !self.image.size.width || !self.scrollView.bounds.size.height || !self.image.size.height || !self.scrollView)
        return;
    
    CGFloat viewPortWidth = self.scrollView.bounds.size.width;
    CGFloat imageWidth = self.image.size.width;
    CGFloat zoomScaleW;
    
    if(imageWidth >= 0.0) {
        zoomScaleW = viewPortWidth / imageWidth;
    }
    else {
        return;
    }
    
    CGFloat viewPortHeight = self.scrollView.bounds.size.height;
    CGFloat imageHeight = self.image.size.height;
    CGFloat zoomScaleH;
    if(imageHeight >= 0.0) {
        zoomScaleH = viewPortHeight / imageHeight;
    }
    else {
        return;
    }
    
    if(zoomScaleH < zoomScaleW) {
        [self.scrollView setZoomScale: zoomScaleH animated: YES];
        return;
    }
    [self.scrollView setZoomScale: zoomScaleW animated: YES];
}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self resetZoom];
}


- (void) dealloc
{
    // For some reason, the life cycle of the UIScrollView exceeds the lifetime of the ViewController, which causes app crashes because the delegate is deallocated.
    // A simple fix is to set the delegate to nil when this object is deallocated.
    self.scrollView.delegate = nil;
}

@end
