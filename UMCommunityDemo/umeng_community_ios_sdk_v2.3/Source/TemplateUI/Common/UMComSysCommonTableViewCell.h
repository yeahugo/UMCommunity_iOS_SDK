//
//  UMComSysCommnTableViewCell.h
//  UMCommunity
//
//  Created by umeng on 15/12/27.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>


#define UMCom_SysCommonCell_SubViews_LeftEdge 50
#define UMCom_SysCommonCell_SubViews_RightEdge 10
#define UMCom_SysCommonCell_FeedText_HorizonEdge 2
#define UMCom_SysCommonCell_FeedText_TopEdge 10
#define UMCom_SysCommonCell_FeedText_BottomEdge 3
#define UMCom_SysCommonCell_NameLabel_Height 30
#define UMCom_SysCommonCell_Content_TopEdge 10
#define UMCom_SysCommonCell_Cell_BottomEdge 25

@class UMComMutiStyleTextView, UMComImageView, UMComMutiText, UMComUser, UMComTopic;

@protocol UMComClickActionDelegate;

@interface UMComSysCommonTableViewCell : UITableViewCell

@property (nonatomic, strong) UMComImageView *portrait;

@property (nonatomic, strong) UILabel *userNameLabel;

@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, weak) id<UMComClickActionDelegate> delegate;

@property (nonatomic, strong) UMComMutiStyleTextView *feedTextView;

@property (nonatomic, strong) UIImageView *bgimageView;

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                     cellSize:(CGSize)cellSize;

- (void)reloadCellWithObj:(id)obj
               timeString:(NSString *)timeString
                 mutiText:(UMComMutiText *)commentMutiText
             feedMutiText:(UMComMutiText *)feedMutiText;

- (void)didSelectedUser;

- (void)turnToUserCenterWithUser:(UMComUser *)user;

- (void)turnToTopicViewWithTopic:(UMComTopic *)topic;

- (void)turnToWebViewWithUrlString:(NSString *)urlString;

@end
