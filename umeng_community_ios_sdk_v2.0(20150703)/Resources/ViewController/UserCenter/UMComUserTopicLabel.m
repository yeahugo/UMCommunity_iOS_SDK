//
//  UMComUserTopicLabel.m
//  UMCommunity
//
//  Created by luyiyuan on 14/10/21.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import "UMComUserTopicLabel.h"
#import "UMComLabel.h"
#import "UMComTopic.h"

@interface UMComUserTopicLabelRect : UIView

@end

@implementation UMComUserTopicLabelRect

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    self.backgroundColor = [UIColor clearColor];
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(ctx, [[UMComTools colorWithHexString:FontColorGray] CGColor]);
    CGContextSetLineWidth(ctx, 1.0);
    CGContextAddRect(ctx,rect);

    CGContextStrokePath(ctx);
}

@end


@interface UMComUserTopicLabel()

@property (nonatomic,copy) TopicTapHandle tapHandle;
@property (nonatomic,strong) UMComTopic *topic;
@end

@implementation UMComUserTopicLabel

- (id)initWithText:(UMComTopic *)topic maxWidth:(CGFloat)maxWidth
{
    NSString *string = [NSString stringWithFormat:@"#%@#",topic.name];

    CGSize size = [string sizeWithFont:UMComFontNotoSansLightWithSafeSize(12)];
        
    CGRect frame = CGRectMake(0, 0, (size.width+20) > maxWidth? maxWidth:(size.width+20), 22);
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.topic = topic;
        
        UMComUserTopicLabelRect *view = [[UMComUserTopicLabelRect alloc] initWithFrame:self.bounds];

        [self addSubview:view];
        
        UMComLabel *label = [[UMComLabel alloc] initWithText:string font:UMComFontNotoSansLightWithSafeSize(12)];

        label.textColor = [UMComTools colorWithHexString:FontColorBlue];
        //fix #279 by djx
        if (label.frame.size.width >= self.frame.size.width) {
            label.frame = CGRectMake(10, label.frame.origin.y, self.frame.size.width-20, label.frame.size.height);
        }
        label.center = self.center;
        label.textAlignment = NSTextAlignmentLeft;
        
        [self addSubview:label];

        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
        tapGes.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tapGes];
    }
    
    return self;
}

- (void)handleTap:(UITapGestureRecognizer *)tapGes
{
    if(self.tapHandle){
        self.tapHandle(self.topic);
    }
}

- (void)setTopicTapHandle:(void(^)(UMComTopic *topic))tapHandle
{
    self.tapHandle = tapHandle;
}

@end
