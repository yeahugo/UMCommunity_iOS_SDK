//
//  UMComGridViewerController.m
//  UMCommunity
//
//  Created by luyiyuan on 14/9/2.
//  Copyright (c) 2014年 luyiyuan. All rights reserved.
//

#import "UMComGridViewerController.h"
#import "UMImageProgressView.h"
#import "UMComShowToast.h"


#define A_WEEK_SECONDES (60*60*24*7)

@interface UMComGridViewerController ()
@property (nonatomic) NSUInteger curIndex;
@property (strong,nonatomic) UIPageControl *pageControl;
@property (strong,nonatomic) UIScrollView *scrollView;
@property (nonatomic,strong) NSMutableArray *arrayUrl;
@property (nonatomic,strong) NSMutableArray *arrayImageView;
@end

@implementation UMComGridViewerController

- (id)initWithArray:(NSArray *)array index:(NSUInteger)index
{
    self = [super init];
    
    if(self)
    {

        self.arrayUrl = [NSMutableArray arrayWithArray:array];
        self.arrayImageView = [[NSMutableArray alloc] init];
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        self.scrollView.pagingEnabled = YES;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        [self.scrollView setDelegate:self];
        
        for(int i=0;i<9; i++)
        {
 
            UMZoomScrollView *zoomScrollView = [[UMZoomScrollView alloc]initWithFrame:CGRectMake(i*self.view.bounds.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
            UMImageProgressView *iv = [[UMImageProgressView alloc] initWithFrame:CGRectMake(0, 0, zoomScrollView.frame.size.width, zoomScrollView.frame.size.height)];
            iv.isAutoStart = NO;
            [iv setTag:i];
            [iv setCacheSecondes:A_WEEK_SECONDES];
            zoomScrollView.imageView = iv;
            
            [self.arrayImageView addObject:zoomScrollView];
        }
        
        self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 20, self.view.bounds.size.width, 20)];
        
        [self.view addSubview:self.scrollView];
        [self.view addSubview:self.pageControl];
        
        self.view.backgroundColor = [UIColor blackColor];
        
        //添加触控
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)];
        [self.view addGestureRecognizer:tapGesture];
        [self setArray:array index:index];
    }
    
    
    return self;
}

- (void)setArray:(NSArray *)array index:(NSUInteger)index
{
    self.curIndex = index;
    [self.scrollView setContentOffset:CGPointMake(self.view.bounds.size.width * self.curIndex, 0.0f) animated:NO];
    NSUInteger count = [array count];
    
    [self.scrollView setContentSize:CGSizeMake(count*self.view.bounds.size.width, self.view.bounds.size.height)];
    
    for(NSUInteger i=0;i<count; i++)
    {
        NSArray *arr = (NSArray *)array[i];
        UMZoomScrollView *iv = self.arrayImageView[i];
        [iv.imageView setImageURL:[NSURL URLWithString:(NSString *)arr[1]]];

        [iv.imageView setThumImageViewUrl:(NSString *)arr[0]];
        if (!iv.superview) {
            [self.scrollView addSubview:iv];
        }
    }
    for (NSUInteger i=count; i < 9; i++) {
        UMZoomScrollView *iv = self.arrayImageView[i];
        [iv removeFromSuperview];
    }
    
    [self.pageControl setNumberOfPages:count];
    self.pageControl.currentPage = index;
}

- (void)tapImageView:(UITapGestureRecognizer *)tapGesture
{

    [self dismissViewControllerAnimated:YES completion:^{
        for (UMZoomScrollView *zoomView in self.arrayImageView) {
            zoomView.zoomScale = 1.0;
            zoomView.imageView.center = CGPointMake(zoomView.frame.size.width/2, zoomView.frame.size.height/2);
        }
    }];
}

//默认一周（60*60*24*7）
- (void)setCacheSecondes:(NSTimeInterval)secondes
{
    for(UMZoomScrollView *iv in self.arrayImageView)
    {
        [iv setCacheSecondes:secondes];
    }
}

- (void)startDownload
{
    [self.scrollView setContentOffset:CGPointMake(self.view.bounds.size.width * self.curIndex, 0.0f) animated:NO];
    UMZoomScrollView *iv = (UMZoomScrollView *)self.arrayImageView[self.curIndex];
    [iv startDownload];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{

    NSInteger whichPage = scrollView.contentOffset.x / scrollView.frame.size.width;
    self.curIndex = whichPage;
    //更新UIPageControl的当前页
    [self.pageControl setCurrentPage:whichPage];
    
    UMZoomScrollView *iv = (UMZoomScrollView *)self.arrayImageView[self.curIndex];
    [iv startDownload];
}



@end


@implementation UMZoomScrollView
{
    UIActionSheet *actionSheet;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.backgroundColor = [UIColor clearColor];
//        self.minimumZoomScale = 1.0;
//        self.maximumZoomScale = 5.0;
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(saveIamgeToAssest:)];
        longPress.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:longPress];
    }
    return self;
}

- (void)setImageView:(UMImageProgressView *)imageView
{
    _imageView = imageView;
    _imageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);

    _imageView.backgroundColor = [UIColor clearColor];
    if (imageView.isCacheImage) {
        self.minimumZoomScale = 1.0;
        self.maximumZoomScale = 5.0;
    } else{
        self.minimumZoomScale = 1.0;
        self.maximumZoomScale = 1.0;
    }
    [self addSubview:_imageView];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) /2 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) /2 : 0.0;
    self.imageView.center = CGPointMake(scrollView.contentSize.width /2 + offsetX,scrollView.contentSize.height /2 + offsetY);

}

//默认一周（60*60*24*7）
- (void)setCacheSecondes:(NSTimeInterval)secondes
{
    [self.imageView setCacheSecondes:secondes];
}

- (void)startDownload
{
    [self.imageView startImageLoad];
}

- (void)saveIamgeToAssest:(UILongPressGestureRecognizer *)longPress
{
    if (![actionSheet isVisible]) {
        actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:UMComLocalizedString(@"Cancel", @"取消") destructiveButtonTitle:UMComLocalizedString(@"Save image to album", @"保存图片到相册")otherButtonTitles:nil, nil];
        [actionSheet showInView:self];
    }
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        if (self.imageView.image) {
            UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        }
    }

}



// 指定回调方法
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    [UMComShowToast saveIamgeResultNotice:error];
}



@end
