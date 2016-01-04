//
//  UMComForumTopicTableViewCell.m
//  UMCommunity
//
//  Created by umeng on 15/11/26.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComForumTopicTableViewCell.h"
#import "UMComImageView.h"
#import "UMComTools.h"
#import "UMComClickActionDelegate.h"
#import "UMComTopic.h"



@implementation UMComForumTopicTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellSize:(CGSize)size
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.topicIcon = [[[UMComImageView imageViewClassName] alloc] initWithFrame:CGRectMake(UMCom_Forum_Topic_Edge_Left, UMCom_Forum_Topic_Edge_Left, size.height - UMCom_Forum_Topic_Edge_Left*2, size.height - UMCom_Forum_Topic_Edge_Left*2)];
        self.topicIcon.layer.cornerRadius = UMCom_Forum_Topic_Icon_Width/2;
        self.topicIcon.clipsToBounds = YES;
        [self.contentView addSubview:self.topicIcon];
        
        CGFloat buttonWidth = UMCom_Forum_Topic_Button_Width;
        CGFloat imageAndLabelSpace = 10;
        CGFloat buttonHeght = UMCom_Forum_Topic_Button_Height;
        CGFloat labelOriginX = self.topicIcon.frame.size.width+UMCom_Forum_Topic_Edge_Left+imageAndLabelSpace;
        self.topicNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(labelOriginX, 10, size.width-labelOriginX-imageAndLabelSpace*3-buttonWidth, size.height/2)];
        self.topicNameLabel.font = UMComFontNotoSansLightWithSafeSize(UMCom_Forum_Topic_Name_Font);
        self.topicNameLabel.textColor = UMComColorWithColorValueString(UMCom_Forum_Topic_Name_TextColor);
        [self.contentView addSubview:self.topicNameLabel];

        self.topicDetailLabel = [[UILabel alloc]initWithFrame:CGRectMake(labelOriginX, self.topicNameLabel.frame.size.height, self.topicNameLabel.frame.size.width, size.height - self.topicNameLabel.frame.size.height)];
        self.topicDetailLabel.textColor = UMComColorWithColorValueString(UMCom_Forum_Topic_Description_TextColor);
        self.topicDetailLabel.font = UMComFontNotoSansLightWithSafeSize(UMCom_Forum_Topic_Description_Font);
        [self.contentView addSubview:self.topicDetailLabel];

        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        self.button.frame = CGRectMake(size.width-buttonWidth-UMCom_Forum_Topic_Edge_Right, 0, buttonWidth, buttonHeght);
        self.button.titleLabel.font = UMComFontNotoSansLightWithSafeSize(UMCom_Forum_Topic_Focuse_Font);
        self.button.center = CGPointMake(self.button.center.x, size.height/2);

        [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.contentView addSubview:self.button];
        [self.button addTarget:self action:@selector(didClickAtButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
    // Initialization code
}

- (void)didClickAtButton:(id)sender
{
    if (self.clickOnButton) {
        self.clickOnButton(self);
    }
}


- (void)reloadWithIconUrl:(NSString *)urlString
                topicName:(NSString *)topicName
              topicDetail:(NSString *)topicDetail
{
    self.topicNameLabel.text = topicName;
    self.topicDetailLabel.text = topicDetail;
    [self.topicIcon setImageURL:urlString placeHolderImage:UMComImageWithImageName(@"um_topic_icon")];
}

- (void)reloadWithTopic:(UMComTopic *)topic
{
    self.topicNameLabel.text = topic.name;
    self.topicDetailLabel.text = topic.descriptor;
    [self.topicIcon setImageURL:topic.icon_url placeHolderImage:UMComImageWithImageName(@"um_topic_icon")];
    
    UIImage *image = nil;
    NSString *focuseString = nil;
    UIColor *textColor = nil;
    if ([topic.is_focused boolValue]) {
        focuseString = UMComLocalizedString(@"Has_Focused", @"取消关注");
        image = UMComImageWithImageName(@"um_forum_focuse_nomal");
        textColor = UMComColorWithColorValueString(UMCom_Forum_Topic_DisFocused_TextColor);
    }else{
        focuseString = UMComLocalizedString(@"Add_Focused", @"关注");
        image = UMComImageWithImageName(@"um_forum_focuse_highlight");
        textColor = UMComColorWithColorValueString(UMCom_Forum_Topic_Focused_TextColor);
    }
    [self.button setBackgroundImage:image forState:UIControlStateNormal];
    [self.button setTitle:focuseString forState:UIControlStateNormal];
    [self.button setTitleColor:textColor forState:UIControlStateNormal];
}


- (void)drawRect:(CGRect)rect
{
    UIColor *color = UMComColorWithColorValueString(UMCom_Forum_Topic_Cell_SpaceColor);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, rect);
    
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGFloat lineStart = UMCom_Forum_Topic_Edge_Left*2 + UMCom_Forum_Topic_Icon_Width;
    CGContextStrokeRect(context, CGRectMake(lineStart, rect.size.height - TableViewCellSpace, rect.size.width - lineStart, TableViewCellSpace));
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
