//
//  UMComSyntaxHighlightTextStorage.h
//  UMCommunity
//
//  Created by luyiyuan on 14/9/24.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    UMComContentTypeNormal,
    UMComContentTypeFriend,
    UMComContentTypeTopic
} UMComContentType;

#define UMComContentKey @"contentType"
#define UMComContent @"contentText"

@interface UMComSyntaxHighlightTextStorage : NSTextStorage

@property (nonatomic, copy) void (^updateBlock)(NSArray *matches,NSString *key);

@property (nonatomic, strong) NSArray *chectWords;

- (void)update;


@end
