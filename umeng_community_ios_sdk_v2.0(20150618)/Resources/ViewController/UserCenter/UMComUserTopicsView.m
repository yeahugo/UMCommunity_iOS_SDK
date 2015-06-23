//
//  UMComUserTopicsView.m
//  UMCommunity
//
//  Created by luyiyuan on 14/10/21.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import "UMComUserTopicsView.h"
#import "UMComTopic.h"
#import "UMComUserTopicLabel.h"
#import "UMComLabel.h"

//static inline CGSize getSizeOfText(NSString *)
//static inline CGRect getFrameForWidth(CGFloat curLine)
//{
//    
//}

@interface UMComUserTopicsView ()
@property (nonatomic,strong) NSMutableArray *labelArray;
@property (nonatomic,strong) NSMutableArray *sizeArray;
@property (nonatomic) CGFloat curLine;
@property (nonatomic) CGFloat curLineLeftWidth;
@property (nonatomic,strong) UMComLabel *tipLabel;

@property (nonatomic,copy) TopicTapHandle tapHandle;
@end

@implementation UMComUserTopicsView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)init
{
    self = [super init];
    
    if(self){
        

        
    }
    
    return self;
}



- (CGRect)getFrameForSize:(CGSize)size
{
    if((size.width) > self.curLineLeftWidth){
        self.curLine++;
        self.curLineLeftWidth = self.bounds.size.width;
        
        if(self.curLine>4){
            return CGRectZero;
        }
        return [self getFrameForSize:size];
    }
    

    
    CGRect frame = CGRectMake(self.bounds.size.width - self.curLineLeftWidth,
                              self.curLine *(size.height + 6),
                              size.width,
                              size.height);
    self.curLineLeftWidth -= (size.width + 5);
    
    return frame;
    
}


- (void)setTopicsData:(NSArray *)data
{
    if(self.labelArray){
        for(UIView *view in self.labelArray){
            [view removeFromSuperview];
        }
        [self.labelArray removeAllObjects];
    }
    else{
        self.labelArray = [NSMutableArray array];
    }
    
    if(self.sizeArray){
        [self.sizeArray removeAllObjects];
    }else{
        self.sizeArray = [NSMutableArray array];
    }
    
    self.curLine = 0;
    self.curLineLeftWidth = self.bounds.size.width;
    
    //先排序，将小主题提至前方
    
//    NSArray *array = [data sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//        
//        if([obj1.name length]>[obj2.name length]){
//            return NSOrderedDescending;
//        }
//        else if([obj1.name length]<[obj2.name length]){
//            return NSOrderedAscending;
//        }
//        else{
//            return NSOrderedSame;
//        }
//        
//    }];
    
//    for(UMComTopic *topic in data){
//        [self.sizeArray addObject:]
//    }
    
    
    for(int i=0;i<[data count];i++){
        UMComTopic *topic = data[i];
        UMComUserTopicLabel *label = [[UMComUserTopicLabel alloc] initWithText:topic maxWidth:self.bounds.size.width];

        [label setTopicTapHandle:^(UMComTopic *topic) {
            if(self.tapHandle){
                self.tapHandle(topic);
            }
        }];
        CGRect frame = [self getFrameForSize:label.frame.size];
        if(CGRectEqualToRect(frame, CGRectZero)){
            break;
        }

        label.frame = frame;

        [self addSubview:label];
    }
}

- (void)setTipText:(NSString *)tipText
{
    if(!self.tipLabel){
        self.tipLabel = [[UMComLabel alloc] initWithFont:UMComFontNotoSansDemiWithSafeSize(15)];
    }
    [self addSubview:self.tipLabel];
    
    if(tipText){
        [self.tipLabel setText:tipText];
        self.tipLabel.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    }
}

- (void)setTopicTapHandle:(TopicTapHandle)tapHandle
{
    self.tapHandle = tapHandle;
}

@end
