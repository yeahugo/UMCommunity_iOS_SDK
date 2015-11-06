//
//  UMComAlbum+UMComManagedObject.h
//  UMCommunity
//
//  Created by umeng on 15/7/7.
//  Copyright (c) 2015年 Umeng. All rights reserved.
//

#import "UMComAlbum.h"

void printAlbum();

@interface ImageUrlList : NSValueTransformer

@end


@interface Cover : NSValueTransformer

@end

@interface UMComAlbum (UMComManagedObject)

//返回UMComImageModel对象数组
- (NSArray *)imageModels;

@end
