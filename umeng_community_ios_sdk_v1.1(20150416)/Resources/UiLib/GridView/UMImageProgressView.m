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
        self.progressView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2+40);
        [self addSubview:self.progressView];
        self.progressView.progress = 0.0f;
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
     self.thumImageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2-40);
    self.progressView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2+40);
//    self.thumImageView.hidden = YES;
//    if(!self.isCacheImage)
//    {
//        if (self.image) {
//            self.thumImageView.hidden = YES;
//            self.progressView.hidden = YES;
//        }else{
//            self.thumImageView.hidden = NO;
//            self.progressView.hidden = NO;
//        }
//
//    }else{
//        self.thumImageView.hidden = YES;
//    }
    
    if ([self ifNeedShowThumImage]) {
        self.thumImageView.hidden = NO;
        self.progressView.hidden = NO;
    }else{
        self.thumImageView.hidden = YES;
        self.progressView.hidden = YES;
    }
}

- (BOOL)ifNeedShowThumImage
{
    if(!self.isCacheImage)
    {
        if (self.image) {
            return NO;
        }else{
            return YES;
        }
        
    }else{
        return NO;
    }
}

- (void)cancelImageLoad
{
    [super cancelImageLoad];
    self.progressView.hidden = YES;
}

- (void)imageViewLoadedImageSizePercent:(float)percent imageView:(UMImageView*)imageView
{
    self.progressView.progress = percent;
    
    [self.progressView setNeedsDisplay];
}

- (void)resetSizeWithURLImage:(UMImageView *)imageView
{
    self.thumImageView.hidden = YES;
    CGSize viewSize = [UIScreen mainScreen].bounds.size;
    CGSize imageSize = imageView.image.size;
    int height = viewSize.width * imageSize.height / imageSize.width;
    imageView.frame = CGRectMake(0,viewSize.height/2-height/2, viewSize.width, height);
}

- (void)imageViewLoadedImage:(UMImageView*)imageView
{
    self.progressView.hidden = YES;
    self.thumImageView.hidden = YES;
    [self resetSizeWithURLImage:imageView];
    
    UIScrollView * zoomView = (UIScrollView *)self.superview;
    zoomView.maximumZoomScale = 5;
}

- (void)imageViewFailedToLoadImage:(UMImageView*)imageView error:(NSError*)error
{
    UIScrollView * zoomView = (UIScrollView *)self.superview;
    zoomView.maximumZoomScale = 1;
    self.progressView.hidden = YES;
    [UMComShowToast fetchFeedFail:error];
}


- (void)setThumImageViewUrl:(NSString *)urlString
{
    if ([self ifNeedShowThumImage]) {
        if (self.thumImageView == nil) {
            UMImageView *thumImageView = [[UMImageView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
            thumImageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2-40);
            thumImageView.hidden = YES;
            [self addSubview:thumImageView];
            self.thumImageView = thumImageView;
            self.progressView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2+40);
        }else{
            self.thumImageView.hidden = NO;
            self.progressView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2+40);
        }
        [self.thumImageView setImageURL:[NSURL URLWithString:urlString]];
        [self.thumImageView startImageLoad];
    }else{
        self.thumImageView.hidden = YES;
    }
}

@end
