//
//  UMComFeedStyle.h
//  UMCommunity
//
//  Created by Gavin Ye on 4/27/15.
//  Copyright (c) 2015 Umeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UMComMutiStyleTextView.h"

@interface UMComFeedStyle : NSObject

@property (nonatomic, strong) NSArray *commentHeightArray;

@property (nonatomic, strong) UMComMutiStyleTextView * feedStyleView;
@property (nonatomic, strong) UMComMutiStyleTextView * originFeedStyleView;
@property (nonatomic, strong) UMComMutiStyleTextView * likeStyleView;
@property (nonatomic, strong) NSMutableArray *commentStyleView;
@property (nonatomic) float totalHeight;
@property (nonatomic) NSString * likeId;

@end
