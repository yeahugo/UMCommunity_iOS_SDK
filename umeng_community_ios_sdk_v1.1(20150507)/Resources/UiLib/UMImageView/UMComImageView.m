//
//  UMComImageView.m
//  UMCommunity
//
//  Created by Gavin Ye on 5/6/15.
//  Copyright (c) 2015 Umeng. All rights reserved.
//

#import "UMComImageView.h"

@interface UMComImageView ()

@property (nonatomic ,copy) Class imageViewClass;

@end

@implementation UMComImageView

static UMComImageView *_instance = nil;
+ (UMComImageView *)shareInstance {
    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }
    
    return _instance;
}

+ (Class)imageViewClassName
{
    Class returnClass = [self class];
    if ([self shareInstance].imageViewClass) {
        returnClass = [self shareInstance].imageViewClass;
    }
    return returnClass;
}

+ (void)registUMImageView:(Class)imageViewClass
{
    [self shareInstance].imageViewClass = imageViewClass;
}

+ (UIImage *)placeHolderImageGender:(NSInteger )gender
{
    UIImage *placeHolder = nil;
    if (gender == 0) {
        placeHolder = [UIImage imageNamed:@"female"];
    } else{
        placeHolder = [UIImage imageNamed:@"male"];
    }
    return placeHolder;
}


- (void)setImageURL:(NSString *)imageURLString placeHolderImage:(UIImage *)placeHolderImage
{
    NSString *imageUrl = [[NSURL URLWithString:imageURLString] absoluteString];
    if (![imageUrl isEqualToString:self.imageURL
         .absoluteString]) {
        self.image = nil;
    }
    if (imageURLString) {
        [super setImageURL:[NSURL URLWithString:imageURLString]];
        if (!self.isCacheImage) {
            self.placeholderImage = placeHolderImage;
            [self startImageLoad];
        }
    } else {
        self.placeholderImage = placeHolderImage;
    }
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.isAutoStart = NO;
    }
    return self;
}
@end
