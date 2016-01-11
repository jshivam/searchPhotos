//
//  ViewController.h
//  googleImages
//
//  Created by shivam jaiswal on 8/11/15.
//  Copyright (c) 2015 iappStreet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZoomViewController.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#define kTagImageView 100

@interface ViewController : UIViewController<UISearchBarDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UINavigationControllerDelegate,UIViewControllerAnimatedTransitioning>
{
    NSMutableArray  *photoTitles;         // Titles of images
    NSMutableArray  *photoSmallImageData; // Image data (thumbnail)
    NSMutableArray  *photoURLsLargeImage; // URL to larger image
    NSMutableArray  *sizeOfLargeImage;
    ZoomViewController *zoomedView;
    
    int pageNumber;
    long int maxImg;
}
@property (nonatomic,weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic,weak) IBOutlet UISearchBar *imageSearch;
@property (nonatomic) NSInteger currentPage;
CGRect AVMakeRectWithAspectRatioInsideRect(CGSize aspectRatio, CGRect boundingRect) NS_AVAILABLE(10_7, 4_0);
@end



/*
 Key:
 068f45ad84858ffe9ac3e92c3b456f43
 
 Secret:
 5b7ea9fcab617fcb
 */