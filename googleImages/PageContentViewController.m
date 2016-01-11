//
//  PageContentViewController.m
//  googleImages
//
//  Created by shivam jaiswal on 8/14/15.
//  Copyright (c) 2015 iappStreet. All rights reserved.
//

#import "PageContentViewController.h"
#import <UIImageView+AFNetworking.h>
#import "Reachability.h"
#define kDefaultUrl_Medium @"http://www.tpeedhispants.com/wp-content/uploads/2014/08/Flickr-Icon.png"

@interface PageContentViewController ()

@end

@implementation PageContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *dummyImage = [UIImage imageNamed:@"download.jpg"];
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    NSURL *imageURL;
    NSURL *dummyUrl;

    if (networkStatus == NotReachable) {
        imageURL= (NSURL*)_imageFile;
        dummyUrl = (NSURL*)_smallImageUrl;

    }else{
        imageURL= [NSURL URLWithString:_imageFile];
        dummyUrl = [NSURL URLWithString:_smallImageUrl];
    }
    
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:imageURL];
    
   [_largeImageView setImageWithURL:dummyUrl placeholderImage:nil];
    

    
    [_activityIndicator setHidden:NO];
    [_activityIndicator startAnimating];
    
    
    
    [_largeImageView setImageWithURLRequest:imageRequest
                      placeholderImage:nil
                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         [_activityIndicator setHidden:YES];
         [_activityIndicator stopAnimating];
         _largeImageView.image = image;
         
     }
                               failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
     {
         if (_largeImageView.image.size.width == 0) {
             
             NSLog(@"zero size");
             _largeImageView.image = dummyImage;

         }
         
         
         [_activityIndicator setHidden:YES];
         [_activityIndicator stopAnimating];
     }];
    
//    UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width,10)];
//    lbl.backgroundColor = [UIColor orangeColor];
//    [self.view addSubview:lbl];
//    lbl.center = _largeImageView.center;
//    
}

-(void)viewWillAppear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
 
 
}
*/
- (IBAction)onBack:(id)sender {
    
}

@end
