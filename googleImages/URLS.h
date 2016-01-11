//
//  URLS.h
//  googleImages
//
//  Created by shivam jaiswal on 9/3/15.
//  Copyright (c) 2015 iappStreet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SearchText;

@interface URLS : NSManagedObject

@property (nonatomic, retain) NSString * largeUrls;
@property (nonatomic, retain) NSString * smallUrls;
@property (nonatomic, retain) SearchText *searchUrl;

@end
