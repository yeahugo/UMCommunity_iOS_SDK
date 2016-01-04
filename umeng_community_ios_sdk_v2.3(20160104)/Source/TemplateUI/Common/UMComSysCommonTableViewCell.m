//
//  UMComSysCommnTableViewCell.m
//  UMCommunity
//
//  Created by umeng on 15/12/27.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComSysCommonTableViewCell.h"
#import "UMComComment.h"
#import "UMComUser+UMComManagedObject.h"
#import "UMComImageView.h"
#import "UMComMutiStyleTextView.h"
#import "UMComTools.h"
#import "UMComFeed+UMComManagedObject.h"
#import "UMComClickActionDelegate.h"



@interface UMComSysCommonTableViewCell () <UMComClickActionDelegate>

@property (nonatomic, strong) UMComComment *comment;


@end

@implementation UMComSysCommonTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellSize:(CGSize)cellSize
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGFloat textOriginX = UMCom_SysCommonCell_SubViews_LeftEdge;
        CGFloat textOriginY = UMCom_SysCommonCell_Content_TopEdge;
        self.portrait = [[[UMComImageView imageViewClassName] alloc]initWithFrame:CGRectMake(10, textOriginY, 30, 30)];
        self.portrait.userInteractionEnabled = YES;
        self.portrait.layer.cornerRadius = self.portrait.frame.size.width/2;
        self.portrait.clipsToBounds = YES;
        [self.contentView addSubview:self.portrait];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didSelectedUser)];
        [self.portrait addGestureRecognizer:tap];
        
        self.userNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(textOriginX, textOriginY, cellSize.width-textOriginX-10-120, UMCom_SysCommonCell_NameLabel_Height)];
        self.userNameLabel.font = UMComFontNotoSansLightWithSafeSize(15);
        [self.contentView addSubview:self.userNameLabel];
        
        self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(textOriginX+self.userNameLabel.frame.size.width, textOriginY, 120, UMCom_SysCommonCell_NameLabel_Height)];
        self.timeLabel.textColor = [UMComTools colorWithHexString:FontColorGray];
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        self.timeLabel.font = UMComFontNotoSansLightWithSafeSize(14);
        [self.contentView addSubview:self.timeLabel];
        
        self.bgimageView = [[UIImageView alloc]initWithFrame:CGRectMake(textOriginX, self.userNameLabel.frame.origin.y+self.userNameLabel.frame.size.height, cellSize.width-60, 100)];
        UIImage *resizableImage = [UMComImageWithImageName(@"origin_image_bg") resizableImageWithCapInsets:UIEdgeInsetsMake(20, 50, 0, 0)];
        self.bgimageView.image = resizableImage;
        [self.contentView addSubview:self.bgimageView];
        
        self.feedTextView = [[UMComMutiStyleTextView alloc] initWithFrame:CGRectMake(textOriginX, self.bgimageView.frame.origin.y+10, cellSize.width-60, 80)];
        self.feedTextView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.feedTextView];
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)reloadCellWithObj:(id)obj
               timeString:(NSString *)timeString
                 mutiText:(UMComMutiText *)commentMutiText
             feedMutiText:(UMComMutiText *)feedMutiText
{

}

#pragma mark - action

- (void)didSelectedUser
{
    [self turnToUserCenterWithUser:self.comment.creator];
}

- (void)turnToUserCenterWithUser:(UMComUser *)user
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(customObj:clickOnUser:)]) {
        [self.delegate customObj:self clickOnUser:user];
    }
}

- (void)turnToTopicViewWithTopic:(UMComTopic *)topic
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(customObj:clickOnTopic:)]) {
        [self.delegate customObj:self clickOnTopic:topic];
    }
}

- (void)turnToWebViewWithUrlString:(NSString *)urlString
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(customObj:clickOnURL:)]) {
        [self.delegate customObj:self clickOnURL:urlString];
    }
}

@end
