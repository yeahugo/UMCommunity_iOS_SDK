//
//  UMComForumAllTopicTableViewCell.m
//  UMCommunity
//
//  Created by 张军华 on 15/12/7.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComForum_AllTopicTableViewCell.h"
#import "UMComImageView.h"
#import "UMComTools.h"

static const int g_UMComForum_AllTopicTableViewCell_imgoffset = 30;//偏移的距离

@implementation UMComForum_AllTopicTableViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellSize:(CGSize)size
{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier cellSize:size]) {
        
        self.iconBgImageView = [[UIImageView alloc]initWithFrame:self.topicIcon.frame];
        self.iconBgImageView.image = UMComImageWithImageName(@"um_topic_list_forum");
        [self.iconBgImageView addSubview:self.topicIcon];
        
        [self.contentView addSubview:self.iconBgImageView];
        CGFloat topicIconEdge = 5;
        self.topicIcon.frame = CGRectMake(topicIconEdge, topicIconEdge, self.topicIcon.frame.size.width - topicIconEdge*2, self.topicIcon.frame.size.height - topicIconEdge*2);
        
        //设置头像的为圆角
        if (self.topicIcon) {
            self.topicIcon.layer.cornerRadius = 6;
        }
        
        //设置主题
        if (self.topicNameLabel) {
            self.topicNameLabel.numberOfLines = 1;
            self.topicNameLabel.textAlignment = NSTextAlignmentLeft;
            self.topicNameLabel.font = UMComFontNotoSansLightWithSafeSize(18);
            
            CGRect orgFrame = self.topicNameLabel.frame;
            orgFrame.size.width += g_UMComForum_AllTopicTableViewCell_imgoffset;
            self.topicNameLabel.frame = orgFrame;
        }
        
        //设置主题详细
        if (self.topicDetailLabel) {
            self.topicDetailLabel.numberOfLines = 1;
            self.topicDetailLabel.textAlignment = NSTextAlignmentLeft;
            self.topicDetailLabel.font = UMComFontNotoSansLightWithSafeSize(14);
            self.topicDetailLabel.textColor = UMComColorWithColorValueString(@"#8f8f8f");
            
            CGRect orgFrame = self.topicDetailLabel.frame;
            orgFrame.size.width += g_UMComForum_AllTopicTableViewCell_imgoffset;
            self.topicDetailLabel.frame = orgFrame;
        }
        
        //设置关注按钮
        if (self.button) {
            [self.button setImage:UMComImageWithImageName(@"um_arrow_forum") forState:UIControlStateNormal];
            CGRect orgFrame = self.button.frame;
            orgFrame.origin.y = size.height/2 - orgFrame.size.height/2;
            orgFrame.origin.x += g_UMComForum_AllTopicTableViewCell_imgoffset;//偏移30以达到和系统的效果
            self.button.frame = orgFrame;
        }
    }
    
    return self;
}

@end
