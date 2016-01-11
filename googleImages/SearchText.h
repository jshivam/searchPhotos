//
//  SearchText.h
//  googleImages
//
//  Created by shivam jaiswal on 9/3/15.
//  Copyright (c) 2015 iappStreet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class URLS;

@interface SearchText : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSSet *searchUrl;
@end

@interface SearchText (CoreDataGeneratedAccessors)

- (void)addSearchUrlObject:(URLS *)value;
- (void)removeSearchUrlObject:(URLS *)value;
- (void)addSearchUrl:(NSSet *)values;
- (void)removeSearchUrl:(NSSet *)values;

@end
