//
//  ViewController.m
//  googleImages
//
//  Created by shivam jaiswal on 8/11/15.
//  Copyright (c) 2015 iappStreet. All rights reserved.
//

#import "ViewController.h"
#import "FlickrPhotoCell.h"
#import "Reachability.h"
#import <AFNetworking/AFNetworking.h>
#import <UIImageView+AFNetworking.h>
#import "ZoomViewController.h"
#import "MHUIImageViewContentViewAnimation.h"
#import <AVFoundation/AVBase.h>
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "URLS.h"
#import "SearchText.h"
#define kFlickrAPIKey @"c0c4078489a478572c549bbdb87769fe"

#define kDefaultUrl_Thumbnail @"http://www.composite.net/media/1567b663-e0f2-4f76-aab0-c0c74c995774/BnQ-hQ/Packages/Package%20Icons/Composite.Media.ImageGallery.Flickr.png?mw=75&mh=75"
#define kDefaultUrl_Medium @"http://www.tpeedhispants.com/wp-content/uploads/2014/08/Flickr-Icon.png"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageSearch.placeholder = @"search here";
    self.imageSearch.returnKeyType = UIReturnKeyDone;
    self.imageSearch.keyboardType = UIKeyboardTypeNamePhonePad;
   
    // Initialize our arrays
    photoTitles = [[NSMutableArray alloc] init];
    photoSmallImageData = [[NSMutableArray alloc] init];
    photoURLsLargeImage = [[NSMutableArray alloc] init];
    sizeOfLargeImage = [[NSMutableArray alloc]init];
    pageNumber = 1;
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Searchbar Delegates

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}

-(BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if ([text isEqualToString:@" "]) {
        return NO;
    }
    else {
        return YES;
    }

}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    [photoSmallImageData removeAllObjects];
    [photoURLsLargeImage removeAllObjects];
    [photoTitles removeAllObjects];
    [sizeOfLargeImage removeAllObjects];
    pageNumber = 1;


    if (networkStatus == NotReachable)
    {
        NSLog(@"There IS NO internet connection");
        NSMutableArray * urlArray = [self fetchingUrlFromDb:searchBar.text];

        if ([urlArray count] == 0) {
            UIAlertView *alrt = [[UIAlertView alloc]initWithTitle:@"Please Connect to the Internet" message:@"No matches found!!" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
            [alrt show];
        }
        
        for (int i = 0; i < [urlArray count]; i++)
        {
            NSManagedObject *saveUrl = [urlArray objectAtIndex:i];
            NSString *urlStr = [saveUrl valueForKey:@"largeUrls"];
            NSURL * url = [NSURL URLWithString:urlStr];
            [photoURLsLargeImage addObject:url];
            
            NSString *thumbUrlStr = [saveUrl valueForKey:@"smallUrls"];
            NSURL * thumburl = [NSURL URLWithString:thumbUrlStr];
            [photoSmallImageData addObject:thumburl];
        }
        
        [self.collectionView reloadData];
    }
    else
    {
        NSLog(@"Available connection");
        [self searchFlickrPhotos:searchBar.text];
    }

    [searchBar resignFirstResponder];
}

#pragma mark - Flickr

-(void)searchFlickrPhotos:(NSString *)text
{
    //setup by AFNetwork
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&text=%@&per_page=20&extras=url_t,url_m&page=%d&format=json&nojsoncallback=1", kFlickrAPIKey, text,pageNumber++]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             CGFloat total = [[[responseObject objectForKey:@"photos"]objectForKey:@"total"]floatValue];
             NSArray *flickrPhotos = [[responseObject objectForKey:@"photos"] objectForKey:@"photo"];
             [self addDataToArray:flickrPhotos];
             [self createNewEntity:text];

             maxImg = total;
             [self.collectionView reloadData];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error AFNet: %@", error.localizedDescription);
     }];
}

-(void) addDataToArray :(NSArray*) flickrPhotos
{
    for (NSDictionary *photo in flickrPhotos)
    {
        NSString *title = [photo objectForKey:@"title"];
        [photoTitles addObject:(title.length > 0 ? title : @"Untitled")];

        NSString *photoURLString = [photo objectForKey:@"url_t"];
        if (photoURLString == nil) {
            photoURLString = kDefaultUrl_Thumbnail;
        }
        
        [photoSmallImageData addObject:photoURLString];
        
        photoURLString = [photo objectForKey:@"url_m"];
        
        if (photoURLString == nil) {
            photoURLString = kDefaultUrl_Medium;
        }
        
        [photoURLsLargeImage addObject:photoURLString];
        
        CGSize size = CGSizeMake([[photo objectForKey:@"width_m"] floatValue], [[photo objectForKey:@"height_m"]floatValue]);
        NSValue *sizeObj = [NSValue valueWithCGSize:size];
        [sizeOfLargeImage addObject:sizeObj];
        
    }
}


#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [photoSmallImageData count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];

    
    FlickrPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FlickrCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor lightGrayColor];

    if ([photoSmallImageData count] == 0)
    {
        return nil;
    }
    
    if (networkStatus == NotReachable) {
        
        [[cell imageView]setImageWithURL:[photoSmallImageData objectAtIndex:indexPath.row]];

    }else {
        
        [[cell imageView]setImageWithURL:[NSURL URLWithString:[photoSmallImageData objectAtIndex:indexPath.row]] placeholderImage:[UIImage imageNamed:@"download.jpg"]];

    }

    [cell.imageView setTag:kTagImageView];
    if (indexPath.row == [photoSmallImageData count]-1 && pageNumber< maxImg )
    {
        [self searchFlickrPhotos:self.imageSearch.text];
    }

    return cell;
}

#pragma mark  UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [collectionView layoutAttributesForItemAtIndexPath:indexPath];
    CGRect cellRect = attributes.frame;
    CGRect cellFrameInSuperview = [collectionView convertRect:cellRect toView:[collectionView superview]];
    CGPoint point = CGPointMake(cellFrameInSuperview.origin.x + (cellFrameInSuperview.size.width / 2),
                                cellFrameInSuperview.origin.y + (cellFrameInSuperview.size.height / 2)
                                );
    [self.navigationController setDelegate:self];


    zoomedView = [self.storyboard instantiateViewControllerWithIdentifier:@"zoomStoryBoardIdentifier"];
    [zoomedView setArr_LargeURL:photoURLsLargeImage];
    [zoomedView setArr_SmallURL:photoSmallImageData];
    [zoomedView setArr_imageName:photoTitles];
    [zoomedView setArr_LargeImgSize:sizeOfLargeImage];
    [zoomedView setCv:collectionView];
    [zoomedView setIndexPathOfCollectionView:indexPath];
    [zoomedView setRow:indexPath.row];
    [zoomedView setCenterOfCell:point];
    
    [self.navigationController pushViewController:zoomedView animated:YES];

    
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{

}

#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(75, 75);
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(50, 20, 50, 20);
}

#pragma mark - UINavigationControllerDelegate

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    if (operation == UINavigationControllerOperationPush)
    {
        return zoomedView;
    }
    if (operation == UINavigationControllerOperationPop)
    {
        return self;
    }
    return nil;
}


#pragma mark Coustom Animation

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return .5;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    ZoomViewController *fromViewController = (ZoomViewController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    ViewController *toViewController = (ViewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    UIImageView *imageView =  (UIImageView*)[[[fromViewController.pageViewController.viewControllers firstObject] view]viewWithTag:506];
    
    if (!imageView.image) {
        NSLog(@"NO Image");
        [imageView setImageWithURL:[NSURL URLWithString:kDefaultUrl_Medium]];
    }

    toViewController.currentPage = fromViewController.indexPathOfCollectionView.row;
    MHUIImageViewContentViewAnimation *cellImageSnapshot;
    
    if(orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        cellImageSnapshot = [[MHUIImageViewContentViewAnimation alloc] initWithFrame:CGRectMake(0, 45.5, fromViewController.view.frame.size.width, fromViewController.view.frame.size.height)];
    }
    else if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
    {
        cellImageSnapshot = [[MHUIImageViewContentViewAnimation alloc] initWithFrame:CGRectMake(0, 32, fromViewController.view.frame.size.width, fromViewController.view.frame.size.height - 37 )];
    }
    
    cellImageSnapshot.contentMode = UIViewContentModeScaleAspectFit;
    cellImageSnapshot.image = imageView.image;
    imageView.hidden = YES;
    
    UIImage *image = imageView.image;
    
    
    [cellImageSnapshot setFrame:AVMakeRectWithAspectRatioInsideRect(image.size, cellImageSnapshot.frame)];
    UICollectionViewLayoutAttributes *attributes = [toViewController.collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:toViewController.currentPage inSection:0]];
    CGRect cellRect = attributes.frame;
    CGRect cellFrameInSuperview = [toViewController.collectionView convertRect:cellRect toView:[toViewController.collectionView superview]];
    
    UIImageView *tempImgView = [[UIImageView alloc] initWithFrame:cellFrameInSuperview];
    
    [tempImgView setBackgroundColor:[UIColor whiteColor]];
    [containerView addSubview:tempImgView];
    [containerView addSubview:cellImageSnapshot];
    [containerView insertSubview:toViewController.view belowSubview:fromViewController.view];
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        fromViewController.view.alpha = 0.0;
        
        cellImageSnapshot.frame =cellFrameInSuperview;
    } completion:^(BOOL finished)
     {
         [tempImgView removeFromSuperview];
         [cellImageSnapshot removeFromSuperview];
         imageView.hidden = NO;
         [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
     }];
}

#pragma mark - CoreData

-(void) createNewEntity :(NSString *)entityName
{
    AppDelegate *appDelegate  = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];

    SearchText *searchText = [NSEntityDescription
                                      insertNewObjectForEntityForName:@"SearchText"
                                      inManagedObjectContext:context];
    [searchText setValue:entityName forKey:@"text"];
        
    NSEntityDescription *entityUrlOfText = [NSEntityDescription entityForName:@"URLS" inManagedObjectContext:context];

    for (int i = 0; i < [photoSmallImageData count] ; i++)
    {
        NSManagedObject *newUrl = [[NSManagedObject alloc] initWithEntity:entityUrlOfText insertIntoManagedObjectContext:context];
        [newUrl setValue:[photoURLsLargeImage objectAtIndex:i] forKey:@"largeUrls"];
        [newUrl setValue:[photoSmallImageData objectAtIndex:i] forKey:@"smallUrls"];
        
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }else{
            NSMutableSet *urlOfText = [searchText mutableSetValueForKey:@"urlRelationship"];
            [urlOfText addObject:newUrl];
        }
    }
    [self fetchingUrlFromDb:entityName];
}

-(NSMutableArray *) fetchingUrlFromDb :(NSString *)textSearch
{
    AppDelegate *appDelegate  = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"URLS"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"searchUrl.text LIKE[c] %@",textSearch];
    [fetchRequest setPredicate:predicate];
    NSMutableArray * localArr = [[NSMutableArray alloc] initWithArray:[context executeFetchRequest:fetchRequest error:nil]];
    
    return localArr;
}

@end
