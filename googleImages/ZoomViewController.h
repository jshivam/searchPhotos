//
//  ZoomViewController.h
//  googleImages
//
//  Created by shivam jaiswal on 8/14/15.
//  Copyright (c) 2015 iappStreet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZoomViewController : UIViewController<UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIViewControllerAnimatedTransitioning>{
}

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (nonatomic,strong) NSArray *arr_LargeURL;
@property (nonatomic,strong) NSArray *arr_SmallURL;
@property (nonatomic,strong) NSArray *arr_imageName;
@property (nonatomic,strong) NSArray *arr_LargeImgSize;
@property (nonatomic,strong) UICollectionView *cv;
@property (nonatomic,strong) NSIndexPath *indexPathOfCollectionView;
@property (nonatomic) NSInteger row;
@property (nonatomic) CGPoint centerOfCell;



@end
