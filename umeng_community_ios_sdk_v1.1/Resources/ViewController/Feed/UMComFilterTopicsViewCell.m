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

@interface UMComFilterTopicsViewCell()
@property (nonatomic,strong) UMComTopic *topic;
@end

@implementation UMComFilterTopicsViewCell

- (void)awakeFromNib {
    // Initialization code
    self.butFocuse.titleLabel.font = UMComFontNotoSansDemiWithSafeSize(15);
    self.labelName.textColor = [UMComTools colorWithHexString:FontColorBlue];
    self.isRecommendTopic = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
//
//// 自绘分割线
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
    
    self.labelName.font = UMComFontNotoSansDemiWithSafeSize(16);
    self.labelDesc.font = UMComFontNotoSansDemiWithSafeSize(15);
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
   
//CGRect recommendFrame = CGRectMake(self.butFocuse.frame.origin.x+2.5, self.butFocuse.frame.origin.y+1.5, self.butFocuse.frame.size.width-5, self.butFocuse.frame.size.height-3);
 
    if(focused){
     
        if (self.isRecommendTopic == NO) {
            [self setButFocuseWithFocus:focused];
        }else{
            
            [self.butFocuse setTitle:UMComLocalizedString(@"has_been_followed" ,@"已关注") forState:UIControlStateNormal];
            [self.butFocuse setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.butFocuse.backgroundColor = [UMComTools colorWithHexString:ViewGrayColor];
//            self.butFocuse.frame = recommendFrame;
        }

        [self.topic setValue:@1 forKey:@"is_focused"];
    }else{
        if (self.isRecommendTopic == NO) {
            [self setButFocuseWithFocus:focused];
        }else{
            [self.butFocuse setTitle:UMComLocalizedString(@"follow" ,@"关注") forState:UIControlStateNormal];
            [self.butFocuse setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.butFocuse.backgroundColor = [UMComTools colorWithHexString:ViewGreenBgColor];
//            self.butFocuse.frame = recommendFrame;

        }

    }
}


- (void)setButFocuseWithFocus:(BOOL)isFocus
{
    CALayer * downButtonLayer = [self.butFocuse layer];
    [downButtonLayer setBorderWidth:1.0];
    if (isFocus){
        UIColor *bcolor = [UIColor colorWithRed:15.0/255.0 green:121.0/255.0 blue:254.0/255.0 alpha:1];
        [downButtonLayer setBorderColor:[bcolor CGColor]];
        [self.butFocuse setTitleColor:bcolor forState:UIControlStateNormal];
        [self.butFocuse setTitle:UMComLocalizedString(@"Has_Focused",@"取消关注") forState:UIControlStateNormal];
    }else{
        [downButtonLayer setBorderColor:[[UIColor grayColor] CGColor]];
        [self.butFocuse setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
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
            [UMComShowToast fetchFeedFail:error];
        }
    }];
}
@end
