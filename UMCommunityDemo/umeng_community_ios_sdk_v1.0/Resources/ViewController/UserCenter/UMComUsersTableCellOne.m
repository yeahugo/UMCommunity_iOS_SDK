//
//  UMComUsersTableCellOne.m
//  UMCommunity
//
//  Created by luyiyuan on 14/10/16.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import "UMComUsersTableCellOne.h"
#import "UMImageView.h"
#import "UMComUser.h"
#import "UMComLabel.h"

@interface UMComUsersTableCellOne ()
@property (nonatomic,strong) UMImageView *imageView;
@property (nonatomic,strong) UMComLabel *labelName;
@end

@implementation UMComUsersTableCellOne

+(CGSize)staticSize{
    return CGSizeMake(35,55);
}


- (void)setWithData:(id)data
{
    [super setWithData:data];
    
    if(![data isKindOfClass:[UMComUser class]]){
        return;
    }
    
    UMComUser *user = (UMComUser *)data;
   
    NSString *iconURL = ![[user.icon_url valueForKey:@"240"] isKindOfClass:[NSNull class]] ? [user.icon_url valueForKey:@"240"]:nil;
    NSURL *url = [NSURL URLWithString:iconURL];
    if ([user.gender intValue] == 0) {
        [self.imageView setImageURL:url placeholderImage:[UIImage imageNamed:@"female"]];
    } else{
        [self.imageView setImageURL:url placeholderImage:[UIImage imageNamed:@"male"]];
    }
    [self.imageView startImageLoad];
    self.imageView.layer.cornerRadius = self.imageView.frame.size.width/2;
    self.imageView.clipsToBounds = YES;
    [self.labelName setText:user.name];
    self.labelName.frame = CGRectMake(self.labelName.frame.origin.x, self.labelName.frame.origin.y, [UIScreen mainScreen].bounds.size.width/4-8, self.labelName.frame.size.height);
    [self.labelName setCenter:CGPointMake(self.imageView.center.x, self.imageView.center.y + self.imageView.bounds.size.height*5/6)];

}

- (void)setUpSubViews
{
    self.imageView = [[UMImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    self.imageView.layer.cornerRadius = self.imageView.frame.size.width/2;
    self.imageView.layer.masksToBounds = YES;
    self.labelName = [[UMComLabel alloc] initWithText:@"用户名" font:UMComFontNotoSansDemiWithSafeSize(13)];
    self.labelName.textAlignment = NSTextAlignmentCenter;
    CGPoint center = self.labelName.center;
    self.labelName.frame = CGRectMake(self.labelName.frame.origin.x, self.labelName.frame.origin.y, [UIScreen mainScreen].bounds.size.width/4-8, self.labelName.frame.size.height);
    self.labelName.center = center;
    self.labelName.lineBreakMode = NSLineBreakByTruncatingTail;
    [self addSubview:self.labelName];
    [self addSubview:self.imageView];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self setUpSubViews];
    }
    
    return self;
}

- (id)init
{
    self = [super init];
    
    if(self){
        [self setUpSubViews];
    }
    
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
