//
//  UMComFilterTopicsViewCell.m
//  UMCommunity
//
//  Created by luyiyuan on 14/9/29.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import "UMComFilterTopicsViewCell.h"
#import "UMComTopic.h"
#import "UMComTopic+UMComManagedObject.h"
#import "UMComSession.h"
#import "UMComShowToast.h"
#import "UMComImageView.h"
#import "UMComClickActionDelegate.h"

@interface UMComFilterTopicsViewCell()
@end

@implementation UMComFilterTopicsViewCell

- (void)awakeFromNib {
    // Initialization code
    self.labelName.textColor = [UMComTools colorWithHexString:FontColorBlue];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didClickOnTopic)];
    [self addGestureRecognizer:tap];
    self.topicIcon = [[[UMComImageView imageViewClassName] alloc]initWithFrame:CGRectMake(10, 0, 35, 35)];
    self.topicIcon.layer.cornerRadius = self.topicIcon.frame.size.width/2;
    self.topicIcon.clipsToBounds = YES;
    [self.contentView addSubview:self.topicIcon];
    self.labelName.font = UMComFontNotoSansLightWithSafeSize(15);
    self.labelDesc.font = UMComFontNotoSansLightWithSafeSize(14);
    self.butFocuse.titleLabel.font = UMComFontNotoSansLightWithSafeSize(13);
}


- (void)didClickOnTopic
{
    if (self.clickOnTopic) {
        self.clickOnTopic(self.topic);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

// 自绘分割线
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, rect);
    
    CGContextSetStrokeColorWithColor(context, TableViewSeparatorRGBColor.CGColor);
    CGContextStrokeRect(context, CGRectMake(0, rect.size.height - TableViewCellSpace, rect.size.width, TableViewCellSpace));
}


- (void)setWithTopic:(UMComTopic *)topic
{
    if (topic.isFault || topic.isDeleted) {
        return;
    }
    self.topicIcon.center = CGPointMake(self.topicIcon.center.x, self.contentView.frame.size.height/2);
    [self.topicIcon setImageURL:topic.icon_url placeHolderImage:UMComImageWithImageName(@"um_topic_icon")];
    if ([topic isKindOfClass:[UMComTopic class]]) {
        self.topic = topic;
        if(self.topic.name){
            self.labelName.text = [NSString stringWithFormat:TopicString,self.topic.name];
        }else{
            self.labelName.text = @"";
        }
        if (self.topic.descriptor) {
            self.labelDesc.text = [self.topic.descriptor length] == 0 ? UMComLocalizedString(@"Topic_No_Desc", @"该话题没有描述"): self.topic.descriptor;
        } else {
            self.labelDesc.text = UMComLocalizedString(@"Topic_No_Desc", @"该话题没有描述");
        }
        [self setFocused:[topic.is_focused boolValue]];
    }
}


- (void)setFocused:(BOOL)focused
{
    if(focused){
        UIColor *bcolor = [UIColor colorWithRed:15.0/255.0 green:121.0/255.0 blue:254.0/255.0 alpha:1];
        [self.butFocuse setTitleColor:bcolor forState:UIControlStateNormal];
        [self.butFocuse setTitle:UMComLocalizedString(@"has_been_followed" ,@"取消关注") forState:UIControlStateNormal];
        self.butFocuse.backgroundColor = [UMComTools colorWithHexString:ViewGrayColor];

    }else{
        [self.butFocuse setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.butFocuse setTitle:UMComLocalizedString(@"follow" ,@"关注") forState:UIControlStateNormal];
        self.butFocuse.backgroundColor = [UMComTools colorWithHexString:ViewGreenBgColor];
    }
}

- (void)setButFocuseWithFocus:(BOOL)isFocus
{
    CALayer * downButtonLayer = [self.butFocuse layer];
    [downButtonLayer setBorderWidth:1.0];
    if (isFocus){
        UIColor *bcolor = [UIColor colorWithRed:15.0/255.0 green:121.0/255.0 blue:254.0/255.0 alpha:1];
        [downButtonLayer setBorderColor:[bcolor CGColor]];
        [self.butFocuse setTitle:UMComLocalizedString(@"Has_Focused",@"取消关注") forState:UIControlStateNormal];
    }else{
        [downButtonLayer setBorderColor:[[UIColor grayColor] CGColor]];
        [self.butFocuse setTitle:UMComLocalizedString(@"No_Focused",@"关注") forState:UIControlStateNormal];
    }
}


-(IBAction)actionFocuse:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(customObj:clickOnFollowTopic:)]) {
        [self.delegate customObj:self clickOnFollowTopic:self.topic];
    }
}
@end
