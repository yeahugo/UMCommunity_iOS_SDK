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

@interface UMComFilterTopicsViewCell()
@property (nonatomic,strong) UMComTopic *topic;
@end

@implementation UMComFilterTopicsViewCell

- (void)awakeFromNib {
    // Initialization code
//    self.butFocuse.titleLabel.font = UMComFontNotoSansDemiWithSafeSize(13);
    self.labelName.textColor = [UMComTools colorWithHexString:FontColorBlue];
    self.isRecommendTopic = NO;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didClickOnTopic)];
    [self addGestureRecognizer:tap];
    self.topicIcon = [[[UMComImageView imageViewClassName] alloc]initWithFrame:CGRectMake(10, 0, 35, 35)];
    self.topicIcon.layer.cornerRadius = self.topicIcon.frame.size.width/2;
    self.topicIcon.clipsToBounds = YES;
    [self.contentView addSubview:self.topicIcon];
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
//    self.labelName.font = UMComFontNotoSansDemiWithSafeSize(16);
//    self.labelDesc.font = UMComFontNotoSansDemiWithSafeSize(15);
    self.topicIcon.center = CGPointMake(self.topicIcon.center.x, self.contentView.frame.size.height/2);
    [self.topicIcon setImageURL:topic.icon_url placeHolderImage:[UIImage imageNamed:@"um_topic_icon"]];
    if ([topic isKindOfClass:[UMComTopic class]]) {
        self.topic = topic;
        if(self.topic.name){
            self.labelName.text = [NSString stringWithFormat:@"#%@#",self.topic.name];
        }else{
            self.labelName.text = @"";
        }
        if (self.topic.descriptor) {
            self.labelDesc.text = [self.topic.descriptor length] == 0 ? UMComLocalizedString(@"Topic_No_Desc", @"该话题没有描述"): self.topic.descriptor;
        }
        for (UMComTopic *topicItem in [UMComSession sharedInstance].focus_topics) {
            if ([self.topic.name  isEqualToString:topicItem.name]) {
                [topicItem setValue:@1 forKey:@"is_focused"];
                [self.topic setValue:@1 forKey:@"is_focused"];
                break;
            }
        }
        [self setFocused:[topic isFocus]];
        if ([topic isFocus]) {
            BOOL isInclude = NO;
            [self.topic setValue:@1 forKey:@"is_focused"];
            for (UMComTopic *topicItem in [UMComSession sharedInstance].focus_topics) {
                if ([self.topic.name  isEqualToString:topicItem.name]) {
                    isInclude = YES;
                    [topicItem setValue:@1 forKey:@"is_focused"];
                    break;
                }
            }
            if (isInclude == NO) {
                [[UMComSession sharedInstance].focus_topics addObject:self.topic];
            }
        }

    }
}


- (void)setFocused:(BOOL)focused
{
    if(focused){
        UIColor *bcolor = [UIColor colorWithRed:15.0/255.0 green:121.0/255.0 blue:254.0/255.0 alpha:1];
        [self.butFocuse setTitleColor:bcolor forState:UIControlStateNormal];
        [self.butFocuse setTitle:UMComLocalizedString(@"has_been_followed" ,@"取消关注") forState:UIControlStateNormal];
        self.butFocuse.backgroundColor = [UMComTools colorWithHexString:ViewGrayColor];
        [self setTopicIsFocused:@1];

    }else{
        [self setTopicIsFocused:@0];
        [self.butFocuse setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.butFocuse setTitle:UMComLocalizedString(@"follow" ,@"关注") forState:UIControlStateNormal];
        self.butFocuse.backgroundColor = [UMComTools colorWithHexString:ViewGreenBgColor];
    }
}

- (void)setTopicIsFocused:(NSNumber *)isFocusedNum
{
    if (!self.topic.isDeleted) {
        [self.topic setValue:isFocusedNum forKey:@"is_focused"];
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
    __weak UMComFilterTopicsViewCell *weakSelf = self;
    BOOL isFocus = [self.topic isFocus];
    [self.topic setFocused:!isFocus block:^(NSError * error) {
        if (!error) {
            [weakSelf setFocused:[weakSelf.topic isFocus]];
        } else {
            [UMComShowToast focusTopicFail:error];
        }
    }];
}
@end
