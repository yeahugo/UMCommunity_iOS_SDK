//
//  UMComAddedImageView.m
//  UMCommunity
//
//  Created by luyiyuan on 14/9/11.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import "UMComAddedImageView.h"
#import "UMComActionPickerAddView.h"
#import "UMComAddedImageCellView.h"

#define IMAGE_WIDTH 73.75

#define YPAD 5

#define TAG_PAD 99

//static inline CGRect getImageViewRect(NSUInteger index,NSUInteger cellPad)
//{
//    return CGRectMake((cellPad+IMAGE_CELL_WIDTH)*(index%3)+cellPad, (cellPad+IMAGE_CELL_WIDTH)*(index/3)+cellPad, IMAGE_CELL_WIDTH, IMAGE_CELL_WIDTH);
//}

static inline CGSize getViewSize(NSUInteger count, float cellPad)
{
    CGSize size;
    
    size.width = count/4 > 0 ? (cellPad+IMAGE_WIDTH) * 4 + cellPad : (cellPad+IMAGE_WIDTH)*(count%4)+cellPad;
    
    size.height = (YPAD+IMAGE_WIDTH)*((count - 1)/4 + 1) + YPAD;
    
    return size;
}

static inline CGRect getRectForIndex(NSUInteger index, float cellPad)
{
    return CGRectMake((cellPad+IMAGE_WIDTH)*(index%4)+cellPad, (YPAD+IMAGE_WIDTH)*(index/4)+YPAD, IMAGE_WIDTH, IMAGE_WIDTH);
}

static float xpad = 0;

@interface UMComAddedImageView()
@property (nonatomic,strong,readwrite) NSMutableArray *arrayImages;
@property (nonatomic,strong) UMComActionPickerAddView *actionView;
@property (nonatomic) float screenWidth;
@end

@implementation UMComAddedImageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithUIImages:(NSArray *)images screenWidth:(float)screenWidth
{
    self = [super init];
    
    if(self)
    {
        self.actionView = [[UMComActionPickerAddView alloc] init];
        //添加触控
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)];
        [self.actionView addGestureRecognizer:tapGesture];
        
        
        self.backgroundColor = [UIColor whiteColor];

        [self addSubview:self.actionView];
        
        self.arrayImages = [NSMutableArray array];
        
        self.screenWidth = screenWidth;
        
        [self addImages:images];
        
        
    }
    
    return self;
}

- (void)setOrign:(CGPoint)orign
{
    [self setFrame:CGRectMake(orign.x, orign.y, self.frame.size.width, self.frame.size.height)];
}

//TODO: 9 count Check
- (void)addImages:(NSArray *)images
{
    if( xpad == 0 ){
        xpad = (self.screenWidth - IMAGE_WIDTH*4)/5;
    }

    
    for(int i = 0;i<[images count];i++)
    {
        UMComAddedImageCellView *iv = [[UMComAddedImageCellView alloc] initWithImage:images[i]];
        
        [iv setIndex:i+[self.arrayImages count] cellPad:xpad];
        
        [iv setHandle:^(UMComAddedImageCellView *iv){
            [iv removeFromSuperview];
            [self deleteImageAtIndex:iv.curIndex];
        }];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImageView:)];
        [iv addGestureRecognizer:tap];
        [self addSubview:iv];
    }
    
    if(([self.arrayImages count]+[images count])<9)
    {
        [self.actionView setFrame:getRectForIndex([self.arrayImages count]+[images count],xpad)];
    }
    
    [self.arrayImages addObjectsFromArray:images];
    
    if (images.count > 0) {
        CGSize size = getViewSize([self.arrayImages count]+1,self.screenWidth);
        self.contentSize = CGSizeMake(self.screenWidth, size.height);
    }
    if (self.imagesChangeFinish) {
        self.imagesChangeFinish();
    }
    
}

- (void)deleteImageAtIndex:(NSInteger)index
{
    
    if(index>=0&&index<[self.arrayImages count])
    {
        NSUInteger preCount = [self.arrayImages count];
        [self.arrayImages removeObjectAtIndex:index];
        
        for(NSInteger i = index;i< preCount;i++)
        {
            UMComAddedImageCellView *iv = (UMComAddedImageCellView *)[self viewWithTag:i+TAG_PAD];
            
            [iv setIndex:i-1 cellPad:xpad];
            
        }
        
        if(([self.arrayImages count])<9)
        {
            [self.actionView setFrame:getRectForIndex([self.arrayImages count],xpad)];
        }
        
        if (self.arrayImages.count > 0) {
            CGSize size = getViewSize([self.arrayImages count]+1,self.screenWidth);
            self.contentSize = CGSizeMake(self.screenWidth, size.height);
        }
        
        if (self.imagesChangeFinish) {
            self.imagesChangeFinish();
        }
        if (self.imagesDeleteFinish) {
            self.imagesDeleteFinish(index);
        }
    }
    
    
}




- (void)tapImageView:(UITapGestureRecognizer *)tapGesture
{
    if (tapGesture.view == self.actionView) {
        if(self.pickerAction)
        {
            self.pickerAction();
        }
    }else{
        if (_actionWithTapImages) {
            _actionWithTapImages();
        }
    }

}


@end
