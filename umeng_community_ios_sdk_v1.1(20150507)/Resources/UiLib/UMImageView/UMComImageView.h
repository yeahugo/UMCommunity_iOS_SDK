//
//  UMComImageView.h
//  UMCommunity
//
//  Created by Gavin Ye on 5/6/15.
//  Copyright (c) 2015 Umeng. All rights reserved.
//

#import "UMImageView.h"

@interface UMComImageView : UMImageView

+ (Class)imageViewClassName;

+ (void)registUMImageView:(Class)imageViewClass;

+ (UIImage *)placeHolderImageGender:(NSInteger )gender;

- (void)setImageURL:(NSString *)imageURLString placeHolderImage:(UIImage *)placeHolderImage;
@end
