//
//  UMComGridViewerController.m
//  UMCommunity
//
//  Created by luyiyuan on 14/9/2.
//  Copyright (c) 2014年 luyiyuan. All rights reserved.
//

#import "UMComGridViewerController.h"
#import "UMImageProgressView.h"


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
        self.scrollView.bounces = YES;
        [self.scrollView setDelegate:self];
        
        for(int i=0;i<9; i++)
        {
            UMImageProgressView *iv = [[UMImageProgressView alloc] initWithFrame:CGRectMake(i*self.view.bounds.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
            
            iv.isAutoStart = NO;
            
            [iv setTag:i];
            [iv setCacheSecondes:A_WEEK_SECONDES];
            
            [self.arrayImageView addObject:iv];
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
    NSUInteger count = [array count];
    
    [self.scrollView setContentSize:CGSizeMake(count*self.view.bounds.size.width, self.view.bounds.size.height)];
    
    for(NSUInteger i=0;i<count; i++)
    {
        NSArray *arr = (NSArray *)array[i];
        UMImageProgressView *iv = self.arrayImageView[i];
        
        [iv setImageURL:[NSURL URLWithString:(NSString *)arr[1]]];
        if (!iv.superview) {
            [self.scrollView addSubview:iv];
        }
    }
    for (NSUInteger i=count; i < 9; i++) {
        UMImageProgressView *iv = self.arrayImageView[i];
        [iv removeFromSuperview];
    }
    
    [self.pageControl setNumberOfPages:count];
    self.pageControl.currentPage = index;
}

- (void)tapImageView:(UITapGestureRecognizer *)tapGesture
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

//默认一周（60*60*24*7）
- (void)setCacheSecondes:(NSTimeInterval)secondes
{
    for(UMImageProgressView *iv in self.arrayImageView)
    {
        [iv setCacheSecondes:secondes];
    }
}

- (void)startDownload
{
    UMImageProgressView *iv = (UMImageProgressView *)self.arrayImageView[self.curIndex];
    [iv startImageLoad];
    [self.scrollView setContentOffset:CGPointMake(self.view.bounds.size.width * self.curIndex, 0.0f) animated:NO];
}


#pragma mark - UMImageViewDelegate
- (void)imageViewLoadedImage:(UMImageView*)imageView
{
    CGSize imageSize = imageView.image.size;
    CGSize viewSize = self.view.frame.size;
    if (imageSize.width > imageSize.height) {
        int height = viewSize.width * imageSize.height / imageSize.width;
        imageView.frame = CGRectMake(0, 0, viewSize.width, height);
    } else if (imageSize.width == imageSize.height){
        int height = viewSize.width;
        imageView.frame = CGRectMake(0, 0, viewSize.width, height);
    }
    imageView.center = CGPointMake(viewSize.width/2, viewSize.height/2);
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger whichPage = scrollView.contentOffset.x / scrollView.frame.size.width;
    self.curIndex = whichPage;
    //更新UIPageControl的当前页
    [self.pageControl setCurrentPage:whichPage];
    
    UMImageProgressView *iv = (UMImageProgressView *)self.arrayImageView[self.curIndex];
    [iv startImageLoad];
}
@end
