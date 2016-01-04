//
//  UMComForum_AllTopicTableViewCell.h
//  UMCommunity
//
//  Created by 张军华 on 15/12/7.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComForumTopicTableViewCell.h"

/**
 *  所有的话题的tableview的cell
 */
@interface UMComForum_AllTopicTableViewCell : UMComForumTopicTableViewCell

@property (nonatomic, strong) UIImageView *iconBgImageView;

/**
 *  @brief  重载父类的初始化方法
 *  @parma  style                tableview的cell的样式(UITableViewCellStyleDefault)
 *  @parma  reuseIdentifier      复用字符串
 *  @parma  size                 cell的大小
 *  @return instancetype         UMComForumAllTopicTableViewCell类型cell
 */
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellSize:(CGSize)size;

@end
