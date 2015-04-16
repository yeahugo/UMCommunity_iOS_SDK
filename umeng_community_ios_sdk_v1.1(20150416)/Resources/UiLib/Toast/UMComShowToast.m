//
//  UMComShowToast.m
//  UMCommunity
//
//  Created by Gavin Ye on 1/21/15.
//  Copyright (c) 2015 Umeng. All rights reserved.
//

#import "UMComShowToast.h"
#import "UMComiToast.h"
#import "UMComLoginManager.h"

@implementation UMComShowToast

+ (void)createFeedSuccess
{
    [self fetchFailWithNoticeMessage:UMComLocalizedString(@"Create_Feed_Success",@"消息发送成功")];
}

+ (void)registerError:(NSError*)error
{
    if (error.code == kUserNameTooLong) {
        [self fetchFailWithNoticeMessage:UMComLocalizedString(@"Name_Too_Long", @"用户名必须在2-20字符间")];
    } else if (error.code == kUserNameSensitive){
        [self fetchFailWithNoticeMessage:UMComLocalizedString(@"Name_Error", @"用户名含有敏感词")];
    } else if (error.code == kUserNameRepeat){
        [self fetchFailWithNoticeMessage:UMComLocalizedString(@"Name_Repeat", @"用户名重复")];
    } else if (error.code == kUserNameWrongCharater){
        [self fetchFailWithNoticeMessage:UMComLocalizedString(@"Name_Wrong", @"用户名包含错误字符")];
    }
}

+ (void)notSupportPlatform
{
    [self fetchFailWithNoticeMessage:UMComLocalizedString(@"Not Support Platform", @"暂不支持该平台登录")];
}

+ (void)createFeedFail:(NSError *)error
{
    if (![self handleError:error] && error){
        [[self class] fetchFailWithNoticeMessage:UMComLocalizedString(@"Create_Feed_Fail",@"消息发送失败")];
    }
}

+ (void)showNotInstall
{
    [[self class] fetchFailWithNoticeMessage:UMComLocalizedString(@"Not_Install",@"抱歉，您没有安装微信客户端")];
}

+ (void)showNoMore{
    [[self class] fetchFailWithNoticeMessage:UMComLocalizedString(@"Not_Install",@"已加载全部数据")];
}

+ (void)loginFail:(NSError *)error
{
    if (![self handleError:error] && error){
        [[self class] fetchFailWithNoticeMessage:UMComLocalizedString(@"Login_Fail",@"登录失败")];
    }
}

+ (void)createCommentFail:(NSError *)error
{
    if (![self handleError:error] && error){
        [[self class] fetchFailWithNoticeMessage:UMComLocalizedString(@"Create_Comment_Fail",@"发送评论失败")];
    }
}

+ (void)updateProfileFail:(NSError *)error
{
    if (![self handleError:error] && error) {
        [[self class] fetchFailWithNoticeMessage:UMComLocalizedString(@"Sensitive words",@"用户名包含敏感词，更新失败")];
    }
}

+ (void)spamSuccess:(NSError *)error
{
    if (![self handleError:error]){
        if (error) {
            [[self class] fetchFailWithNoticeMessage:UMComLocalizedString(@"Spam_Fail",@"举报消息失败")];
        } else if(!error) {
            [[self class] fetchFailWithNoticeMessage:UMComLocalizedString(@"Spam_Success",@"举报消息成功")];
        }
    }
}

+ (void)deleteSuccess:(NSError *)error
{
    if (![self handleError:error]){
        if (error) {
            [[self class] fetchFailWithNoticeMessage:UMComLocalizedString(@"Delete_Fail",@"删除消息失败")];
        } else if(!error) {
            [[self class] fetchFailWithNoticeMessage:UMComLocalizedString(@"Delete_Success",@"删除消息成功")];
        }
    }
}

+ (BOOL)handleError:(NSError *)error
{
    BOOL handleResult = NO;
    if (error.code == 10011) {
        [[self class] fetchFailWithNoticeMessage:UMComLocalizedString(@"User unusable",@"对不起，你已经被禁言")];
        handleResult = YES;
    } else if ([error.domain isEqualToString:NSURLErrorDomain]){
        [[self class] fetchFailWithNoticeMessage:UMComLocalizedString(@"Network request failed",@"网络请求失败")];
        handleResult = YES;
    }
    return handleResult;
}

+ (void)fetchFeedFail:(NSError *)error
{
    if (![self handleError:error] && error) {
        [[self class] fetchFailWithNoticeMessage:UMComLocalizedString(@"Fetch_Feeds_Fail",@"获取消息失败")];
    }
}

+ (void)createLikeFail:(NSError *)error
{
    if (![self handleError:error] && error) {
        [[self class] fetchFailWithNoticeMessage:UMComLocalizedString(@"Add_Like_Fail",@"点赞失败")];
    }
}

+ (void)deleteLikeFail:(NSError *)error
{
    if (![self handleError:error] && error) {
        [[self class] fetchFailWithNoticeMessage:UMComLocalizedString(@"Delete_Like_Fail",@"取消点赞失败")];
    }
}

+ (void)fetchMoreFeedFail:(NSError *)error
{
    if (![self handleError:error] && error) {
    }
}

+ (void)fetchFailWithNoticeMessage:(NSString *)message
{
    [[UMComiToastSettings getSharedSettings] setGravity:UMSocialiToastPositionBottom];
    [[UMComiToast makeText:message] show];
}


+ (void)dealWithFeedFailWithErrorCode:(NSInteger)code
{
    switch (code) {
        case 20001:
            [[self class] fetchFailWithNoticeMessage:UMComLocalizedString(@"feed is unavailable",@"该内容已被删除")];
            break;
        case 20002:
            [[self class] fetchFailWithNoticeMessage:UMComLocalizedString(@"feed is not exsit",@"内容不存在")];
            break;
        case 20003:
            [[self class] fetchFailWithNoticeMessage:UMComLocalizedString(@"feed has been liked",@"已经赞过了")];
            break;
        case 20004:
            [[self class] fetchFailWithNoticeMessage:UMComLocalizedString(@"feed related uid is invalid",@"消息相关的用户无法访问")];
            break;
        case 20005:
            [[self class] fetchFailWithNoticeMessage:UMComLocalizedString(@"feed can\'t be reposted",@"消息不能重复发送")];
            break;
        case 20006:
            [[self class] fetchFailWithNoticeMessage:UMComLocalizedString(@"feed related topic id is invalid",@"该消息相关的话题无效")];
            break;
        default:
            break;
    }
}


+ (void)showMoreCommentFail:(NSError *)error
{
    if (![self handleError:error] && error) {
        [[self class] fetchFailWithNoticeMessage:UMComLocalizedString(@"Show_more_comments_failt",@"请求更多评论失败")];
    }
}

+ (void)fetchTopcsFail:(NSError *)error
{
    if (![self handleError:error] && error) {
        [[self class] fetchFailWithNoticeMessage:UMComLocalizedString(@"Topics search fail",@"请求话题失败")];
    }
}


+ (void)fetchLocationsFail:(NSError *)error
{
    if (![self handleError:error] && error) {
        [[self class] fetchFailWithNoticeMessage:UMComLocalizedString(@"Locations search fail",@"获取地址失败")];
    }
}

+ (void)fetchFriendsFail:(NSError *)error
{
    if (![self handleError:error] && error) {
        [[self class] fetchFailWithNoticeMessage:UMComLocalizedString(@"Locations search fail",@"获取好友列表失败")];
    }
}


+ (void)saveIamgeResultNotice:(NSError *)error
{
    NSString *msg = nil ;
    if(error != NULL){
        msg = UMComLocalizedString(@"Image save fail!",@"保存图片失败");
    }else{
        msg = UMComLocalizedString(@"Image save succeed!",@"保存图片成功");;
    }
    [[self class] fetchFailWithNoticeMessage:msg];
}

+ (void)focusUserFail:(NSError *)error
{
    if (![self handleError:error] && error) {
        if (error.code == 10007) {
            [[self class] fetchFailWithNoticeMessage:UMComLocalizedString(@"User has been followed",@"该用户已被关注")];
        }else{
          [[self class] fetchFailWithNoticeMessage:UMComLocalizedString(@"Operation fail",@"操作失败")];
        }
    }
}

+ (void)fetchRecommendUserFail:(NSError *)error
{
    if (![self handleError:error] && error) {
        [[self class] fetchFailWithNoticeMessage:UMComLocalizedString(@"Recommend user search fail",@"请求推荐用户失败")];
    }
}


@end
