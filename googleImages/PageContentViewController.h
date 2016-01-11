//
//  PageContentViewController.h
//  googleImages
//
//  Created by shivam jaiswal on 8/14/15.
//  Copyright (c) 2015 iappStreet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageContentViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *largeImageView;
@property NSUInteger pageIndex;
@property NSString *titleText;
@property NSString *imageFile;
@property NSString *smallImageUrl;
@end
