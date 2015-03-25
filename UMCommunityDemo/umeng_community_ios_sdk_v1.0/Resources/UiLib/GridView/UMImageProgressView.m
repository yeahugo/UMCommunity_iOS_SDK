//
//  UMImageViewWithProgress.m
//  UMCommunity
//
//  Created by luyiyuan on 14/9/3.
//  Copyright (c) 2014年 luyiyuan. All rights reserved.
//

#import "UMImageProgressView.h"
#import "UMComProgressView.h"
#import "UMComShowToast.h"

@interface UMImageProgressView ()
@property (nonatomic,strong) UMComProgressView *progressView;
@end



@implementation UMImageProgressView



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.progressView = [[UMComProgressView alloc] initWithColor:[UIColor whiteColor]];
        self.progressView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);//self.center;
        [self addSubview:self.progressView];

        self.progressView.progress = 0.0f;
//        self.progressView.hidden = NO;
        
        self.delegate = self;
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) startImageLoad
{
    [super startImageLoad];
    
    if(!self.isCacheImage)
    {
        self.progressView.hidden = NO;
    }
    

}
- (void) cancelImageLoad
{
    [super cancelImageLoad];
    
    self.progressView.hidden = YES;
}

- (void)imageViewLoadedImageSizePercent:(float)percent imageView:(UMImageView*)imageView
{
//    NSLog(@"percent %f",percent);
    self.progressView.progress = percent;
    
    [self.progressView setNeedsDisplay];
}

- (void)resetSizeWithURLImage:(UMImageView *)imageView
{
    CGSize imageSize = imageView.image.size;
    CGSize viewSize = [UIScreen mainScreen].bounds.size;

    int height = viewSize.width * imageSize.height / imageSize.width;
    imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, viewSize.width, height);
    imageView.center = CGPointMake(imageView.center.x, viewSize.height/2);
}

- (void)imageViewLoadedImage:(UMImageView*)imageView
{
    self.progressView.hidden = YES;
    [self resetSizeWithURLImage:imageView];
}
- (void)imageViewFailedToLoadImage:(UMImageView*)imageView error:(NSError*)error
{
    self.progressView.hidden = YES;
    [UMComShowToast fetchFeedFail:error];
}

@end
