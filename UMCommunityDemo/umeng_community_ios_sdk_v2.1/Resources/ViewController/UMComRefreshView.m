//
//  RefreshTableView.m
//  DJXRefresh
//
//  Created by Founderbn on 14-7-18.
//  Copyright (c) 2014年 Umeng 董剑雄. All rights reserved.
//

#import "UMComRefreshView.h"


typedef enum{
    noLoad = 0,//还未加载
    preLoad = 1,//准备加载
    loading = 2,//正在加载
    finish = 3//完成加载
} LoadState;

@interface UMComRefreshView ()

@property (nonatomic,assign) CGFloat beginPullHeight;/*达到松手即可刷新的高度 默认为65.0f*/

@property (nonatomic,retain) UILabel *dateLable;//显示上次刷新时间

@property (nonatomic,retain) UILabel *statusLable;//显示状态信息

@property (nonatomic,retain) UIImageView *indicateImageView;//显示图片箭头图片

@property (nonatomic,retain) UIActivityIndicatorView *activityIndicatorView;//透明指示器

@property (nonatomic,assign) LoadState  loadState;

@property (nonatomic,strong) NSString    *lastRefreshTime;


- (void)setLoadState:(LoadState)loadState IsPull:(BOOL)isPull;

@end



@implementation UMComRefreshView
{
    UIImageView *loadingView;
    UIImage *upImage;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat defualtHeight = 60;
        CGFloat height = frame.size.height;
        CGFloat width = frame.size.width;
        CGFloat statusLableHeight = defualtHeight /2;
        CGFloat dateLabelHeight = defualtHeight /3;
        CGFloat commonLabelOriginX = 60;
        self.statusLable = [[UILabel alloc]initWithFrame:CGRectMake(commonLabelOriginX, height-defualtHeight+(defualtHeight - statusLableHeight - dateLabelHeight)/2, width-commonLabelOriginX*2, statusLableHeight)];
        self.dateLable = [[UILabel alloc]initWithFrame:CGRectMake(commonLabelOriginX,self.statusLable.frame.size.height+self.statusLable.frame.origin.y, width-commonLabelOriginX*2, dateLabelHeight)];
        self.activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.activityIndicatorView.frame = CGRectMake(10, height-(defualtHeight-(defualtHeight-40)/2), 40, 40);
        self.indicateImageView = [[UIImageView alloc]initWithFrame:CGRectMake(20, height-(defualtHeight-(defualtHeight-40)/2), 15, 35)];
        self.statusLable.backgroundColor = [UIColor clearColor];
        self.dateLable.backgroundColor = [UIColor clearColor];
        self.statusLable.font = [UIFont systemFontOfSize:15];
        self.dateLable.font = [UIFont systemFontOfSize:10];
        self.statusLable.textAlignment = NSTextAlignmentCenter;
        self.dateLable.textAlignment = NSTextAlignmentCenter;
        self.statusLable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        self.dateLable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        self.indicateImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        self.activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:self.dateLable];
        [self addSubview:self.statusLable];
        [self addSubview:self.indicateImageView];
        [self addSubview:self.activityIndicatorView];
        self.backgroundColor = [UIColor clearColor];
        self.startLocation = frame.origin.y;
        self.beginPullHeight = 65;
        self.finishLabel = [[UILabel alloc]init];
        self.finishLabel.textColor = [UIColor darkGrayColor];
        self.finishLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.finishLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.finishLabel];
        self.finishLabel.hidden = YES;
        self.backgroundColor = [UIColor clearColor];
        self.loadState = noLoad;
        self.isPull = YES;
        UIView *lineSpace = [[UIView alloc]initWithFrame:CGRectMake(0, frame.size.height -0.5, self.frame.size.width, 0.5)];
        lineSpace.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        lineSpace.backgroundColor = [UIColor colorWithRed:0.78 green:0.78 blue:0.8 alpha:1];
        [self addSubview:lineSpace];
        self.lineSpace = lineSpace;
    }
    return self;
}

- (void)setIsPull:(BOOL)isPull
{
    _isPull = isPull;
    if (isPull == NO) {
        self.statusLable.frame = CGRectMake(60, 10, self.frame.size.width-120, 40);
        self.activityIndicatorView.frame = CGRectMake(10, 10, 40, 40);
        self.indicateImageView.frame= CGRectMake(20,12, 15, 35);
        self.lineSpace.frame = CGRectMake(0, 0, self.frame.size.width, 0.5);
    }
}


- (void)loadingFinishWithPull:(BOOL)isPull message:(NSString *)messageText
{

}

- (void)loadingErrorWithPull:(BOOL)isPull networkErrorMessage:(NSString *)message
{

}
- (void)loadFinishIndicaterWithMassege:(NSString *)message {
    self.finishLabel.text = message;
    self.finishLabel.frame = CGRectMake(0, -40, self.frame.size.width, 40);
    self.finishLabel.hidden = NO;
    [UIView animateWithDuration:0.5f animations:^{
        self.finishLabel.frame = CGRectMake(0, 0, self.frame.size.width, 40);
    } completion:^(BOOL finished) {
        sleep(1);
        [UIView animateWithDuration:0.3f animations:^{
            self.finishLabel.frame = CGRectMake(0, -40, self.frame.size.width, 40);
        } completion:^(BOOL finished) {
            self.finishLabel.hidden = YES;
        }];
    }];
}

//#pragma mark - UISrollViewDelegate
- (void)refreshScrollViewDidScroll:(UIScrollView *)refreshScrollView
{
    //下拉
    if (refreshScrollView.contentOffset.y < 0 && self.loadState != loading) {
        [self setLoadState:noLoad IsPull:YES];
        if (refreshScrollView.contentOffset.y < -self.beginPullHeight && self.loadState != loading) {
            [self setLoadState:preLoad IsPull:YES];
        }
    }
    //下拉
    else if ([self isBeginScrollBottom:refreshScrollView] && [refreshScrollView isDragging] && self.loadState != loading  && self.loadState != loading) {//
        [self setLoadState:noLoad IsPull:NO];
    }
    if ([self isScrollToBottom:refreshScrollView] && self.loadState != loading && self.loadState != loading) {
        [self setLoadState:preLoad IsPull:NO];
    }
}


- (void)refreshScrollViewDidEndDragging:(UIScrollView *)refreshScrollView
{
    if (self.loadState !=loading && (refreshScrollView.contentOffset.y<-self.beginPullHeight)) {
        [self setLoadState:loading IsPull:YES];
        refreshScrollView.frame = CGRectMake(self.frame.origin.x, self.startLocation+self.beginPullHeight, refreshScrollView.frame.size.width, refreshScrollView.frame.size.height);
       // 执行代理方法
        if (self.refreshDelegate && [self.refreshDelegate respondsToSelector:@selector(refreshData:loadingFinishHandler:)]) {
            [self.refreshDelegate refreshData:self loadingFinishHandler:^(NSError *error) {
                [self setLoadState:finish IsPull:YES];
                [UIView animateWithDuration:0.5 animations:^{
                    refreshScrollView.frame = CGRectMake(self.frame.origin.x, self.startLocation, refreshScrollView.frame.size.width, refreshScrollView.frame.size.height);
                } completion:^(BOOL finished) {
                    [self loadingFinishWithPull:YES message:@"刷新完成"];

                }];
            }];
            [self setLoadState:loading IsPull:YES];
        }
    }
    //上拉加载
    else if ([self isScrollToBottom:refreshScrollView] && self.loadState != loading) {
         //执行代理方法
        if (self.refreshDelegate && [self.refreshDelegate respondsToSelector:@selector(loadMoreData:loadingFinishHandler:)]) {
            [self setLoadState:loading IsPull:NO];
            refreshScrollView.frame = CGRectMake(refreshScrollView.frame.origin.x, -60, refreshScrollView.frame.size.width, refreshScrollView.frame.size.height);
            [self.refreshDelegate loadMoreData:self loadingFinishHandler:^(NSError *error) {
                [self setLoadState:finish IsPull:NO];
                [UIView animateWithDuration:0.5 animations:^{
                    refreshScrollView.frame = CGRectMake(refreshScrollView.frame.origin.x,self.startLocation, refreshScrollView.frame.size.width, refreshScrollView.frame.size.height);
                } completion:^(BOOL finished) {
                     [self loadingFinishWithPull:NO message:@"加载完成"];
                }];
            }];
        }
    }else if (self.loadState != loading){
//        if (refreshScrollView.contentOffset.y < 0) {
//            [self setLoadState:finish IsPull:YES];
//        }else{
//            [self setLoadState:finish IsPull:YES];
//        }
    }
}

- (BOOL)isScrollToBottom:(UIScrollView *)scrollView
{
    if ((scrollView.contentSize.height-scrollView.contentOffset.y<scrollView.bounds.size.height-30)&&(scrollView.contentOffset.y>0)) {
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)isBeginScrollBottom:(UIScrollView *)scrollView
{
    if ((scrollView.contentSize.height-scrollView.contentOffset.y<scrollView.bounds.size.height)&&(scrollView.contentOffset.y>0)) {
        return YES;
    }else{
        return NO;
    }
}


- (void)setLoadState:(LoadState)loadState IsPull:(BOOL)isPull
{
     self.loadState = loadState;
    if (!upImage) {
        upImage = [UIImage imageNamed:@"grayArrow1"];
    }
    UIImage *downImage = [self image:upImage rotation:UIImageOrientationDown];
    switch (loadState) {
        case noLoad:
        {
            self.indicateImageView.hidden = NO;
            self.statusLable.hidden = NO;
            if (isPull) {
                self.dateLable.hidden = NO;
                self.statusLable.text = @"下拉刷新";
                self.indicateImageView.image = upImage;
                if (self.lastRefreshTime) {
                    self.dateLable.text = self.lastRefreshTime;
                }else{
                 
                    self.dateLable.text = [self nowDateString];
                }
                self.lastRefreshTime = [self nowDateString];
            }else{
                self.statusLable.text = @"上拉可以加载更多";
                self.indicateImageView.image = downImage;
            }
        }
            break;
        case preLoad:
        {
            self.indicateImageView.hidden = NO;
            if (isPull) {
                [self setRotation:-2 animated:YES];
                self.statusLable.text = @"松手即可刷新";
            }else{
                [self setRotation:2 animated:YES];
                self.statusLable.text = @"松手即可加载更多";
            }
        }
            break;
        case loading:
        {
            self.statusLable.text = @"正在加载";
            self.indicateImageView.hidden = YES;
            self.indicateImageView.transform = CGAffineTransformIdentity;
            self.activityIndicatorView.hidden = NO;
            [self.activityIndicatorView startAnimating];
        }
            break;
        case finish:
        {
            [self.activityIndicatorView stopAnimating];
            self.activityIndicatorView.hidden = YES;
            if (isPull) {
                self.statusLable.text = @"刷新完成";
            }else{
                self.statusLable.text = @"上拉可加载更多";
            }
            self.indicateImageView.transform = CGAffineTransformIdentity;
            [self performSelector:@selector(hidenVews) withObject:nil afterDelay:0.5];
        }
            break;
        default:
            break;
    }
}

- (void)hidenVews
{
    self.statusLable.hidden = YES;
    self.indicateImageView.hidden = YES;
    self.dateLable.hidden = YES;
    self.activityIndicatorView.hidden = YES;
}


- (NSString *)nowDateString
{
    NSDate *today = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter  alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];//yyyy-MM-dd HH:mm:ss
    NSString *todayTime = [formatter stringFromDate:today];
    if (todayTime) {
        return [NSString stringWithFormat:@"上次下拉刷新时间：%@",todayTime];
    }
    return nil;
}



- (void)setRotation:(NSInteger)rotation animated:(BOOL)animated
{
    if (rotation < -4)
        rotation = 4 - abs((int)rotation);
    if (rotation > 4)
        rotation = rotation - 4;
    if (animated)
    {
        [UIView animateWithDuration:0.1 animations:^{
            CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(rotation * M_PI / 2);
            self.indicateImageView.transform = rotationTransform;
        } completion:^(BOOL finished) {
        }];
    } else
    {
        CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(rotation * M_PI / 2);
        self.indicateImageView.transform = rotationTransform;
    }
}

-(UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation
{
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    switch (orientation) {
        case UIImageOrientationLeft:
            rotate = M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = 0;
            translateY = -rect.size.width;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationRight:
            rotate = 3 * M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = -rect.size.height;
            translateY = 0;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationDown:
            rotate = M_PI;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = -rect.size.width;
            translateY = -rect.size.height;
            break;
        default:
            rotate = 0.0;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = 0;
            translateY = 0;
            break;
    }
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //做CTM变换
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX, translateY);
    CGContextScaleCTM(context, scaleX, scaleY);
    //绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), image.CGImage);
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    return newPic;
}


- (void)startSpin
{
    if (!loadingView) {
        loadingView = [[UIImageView alloc] initWithFrame: CGRectMake(self.frame.size.width/3, self.frame.size.height/4, 30, 30)];
        loadingView.image = [UIImage imageNamed:@"loading"];
        [self addSubview:loadingView];
    }
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    CGRect frame = [loadingView frame];
    loadingView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    loadingView.layer.position = CGPointMake(frame.origin.x + 0.5 * frame.size.width, frame.origin.y + 0.5 * frame.size.height);
    [CATransaction commit];
    //
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanFalse forKey:kCATransactionDisableActions];
    [CATransaction setValue:[NSNumber numberWithFloat:2.0] forKey:kCATransactionAnimationDuration];
    //
    CABasicAnimation *animation;
    animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = [NSNumber numberWithFloat:0.0];
    animation.toValue = [NSNumber numberWithFloat:2 * M_PI];
    animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionLinear];
    animation.delegate = self;
    [loadingView.layer addAnimation:animation forKey:@"rotationAnimation"];
    [CATransaction commit];
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end

