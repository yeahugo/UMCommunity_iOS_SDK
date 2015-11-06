//
//  UMComEditViewModel.h
//  UMCommunity
//
//  Created by Gavin Ye on 9/9/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "UMComFeed.h"

@interface UMComEditViewModel : NSObject

@property (nonatomic, copy) NSString *locationDescription;

@property (nonatomic, strong) NSMutableString *editContent;

@property (nonatomic, strong) NSArray *postImages;

@property (nonatomic, strong) NSMutableArray *topics;

@property (nonatomic, strong) CLLocation *location;

@property (nonatomic, strong) NSMutableArray * followers;

@property (nonatomic, assign) NSRange seletedRange;

- (void)postEditContentWithImages:(NSArray *)images
                         response:(void (^)(id responseObject,NSError *error))response;

- (void)postForwardFeed:(UMComFeed *)forwardFeed
               response:(void (^)(id responseObject,NSError *error))response;
//kvo

- (void)addObserver:(id)observer forkeyPath:(NSString *)keyPath;
- (void)editContentAppendKvoString:(NSString *)appendString;


@end
