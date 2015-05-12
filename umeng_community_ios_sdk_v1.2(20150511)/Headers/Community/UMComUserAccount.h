//
//  UMComUserAccount.h
//  UMCommunity
//
//  Created by Gavin Ye on 8/27/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 使用第三方登录方法后得到的登录数据构造此类
 
 */
@interface UMComUserAccount : NSObject

/**
 required sns平台名，例如sina
 
 */
@property (nonatomic, copy) NSString * snsPlatformName;

/**
 required, sns平台的用户id
 
 */
@property (nonatomic, copy) NSString * usid;

/**
 required, sns平台的用户昵称
 
 */
@property (nonatomic, copy) NSString * name;

/**
 sns平台的token
 
 */
@property (nonatomic, copy) NSString * token;

/**
 用户头像的链接地址
 
 */
@property (nonatomic, copy) NSString * icon_url;

/**
 用户年龄
 
 */
@property (nonatomic, strong) NSNumber * age;

/**
 用户性别,1代表男性，0代表女性
 
 */
@property (nonatomic, strong) NSNumber * gender;

/**
 用户自定义字段
 
 */
@property (nonatomic, copy) NSString * custom;

@end
