//
//  UMComForumTopicTableViewCell.h
//  UMCommunity
//
//  Created by umeng on 15/11/26.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>


#define UMCom_Forum_Topic_Edge_Left 10 //图片与cell左边缘的距离
#define UMCom_Forum_Topic_Icon_Width 45
#define UMCom_Forum_Topic_Edge_Right 15
#define UMCom_Forum_Topic_Button_Height 35
#define UMCom_Forum_Topic_Button_Width 2.5*UMCom_Forum_Topic_Button_Height



#define UMCom_Forum_Topic_Name_Font 16
#define UMCom_Forum_Topic_Description_Font 12
#define UMCom_Forum_Topic_Focuse_Font 13

#define UMCom_Forum_Topic_Name_TextColor  @"#333333"
#define UMCom_Forum_Topic_Description_TextColor @"#A5A5A5"
#define UMCom_Forum_Topic_Focused_TextColor @"#FF9D0F"
#define UMCom_Forum_Topic_DisFocused_TextColor @"#CACACA"

#define UMCom_Forum_Topic_Cell_SpaceColor @"#EEEFF3"

@class UMComImageView, UMComTopic;

@interface UMComForumTopicTableViewCell : UITableViewCell

@property (nonatomic,strong) UMComImageView *topicIcon;

@property (nonatomic, strong) UILabel *topicNameLabel;

@property (nonatomic, strong) UILabel *topicDetailLabel;

@property (nonatomic, strong) UIButton *button;

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, copy) void (^clickOnButton)(UMComForumTopicTableViewCell *cell);

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellSize:(CGSize)size;

- (void)reloadWithIconUrl:(NSString *)urlString
                topicName:(NSString *)topicName
              topicDetail:(NSString *)topicDetail;

- (void)reloadWithTopic:(UMComTopic *)topic;

@end
