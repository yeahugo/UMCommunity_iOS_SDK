//
//  UMComEditViewController.h
//  UMCommunity
//
//  Created by Gavin Ye on 9/2/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMComEditViewModel.h"
#import "UMComViewController.h"

@class UMComImageView, UMComAddedImageView;
@class UMComFeedEntity;

@interface UMComEditViewController : UMComViewController
<UIImagePickerControllerDelegate,UITextViewDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) UMComEditViewModel *editViewModel;

@property (nonatomic, weak) IBOutlet UIView *locationBackgroundView;

@property (nonatomic, weak) IBOutlet UIView *editToolView;

@property (nonatomic, weak) IBOutlet UILabel *locationLabel;

@property (nonatomic, weak) IBOutlet UITextView *fakeTextView;

@property (nonatomic, strong) IBOutlet UIImageView * forwardFeedBackground;

@property (nonatomic, weak) IBOutlet UITextView *fakeForwardTextView;

@property (nonatomic, weak) IBOutlet UIButton *topicButton;

@property (nonatomic, weak) IBOutlet UIButton *imagesButton;

@property (nonatomic, weak) IBOutlet UIButton *locationButton;

@property (nonatomic, weak) IBOutlet UIButton *atFriendButton;

@property (nonatomic, weak) IBOutlet UIButton *takePhotoButton;

@property (nonatomic, strong) UMComImageView * forwardImage;

@property (strong, nonatomic) UMComAddedImageView *addedImageView;

@property (weak, nonatomic) IBOutlet UIImageView *topicNoticeBgView;

//- (id)initWithDraftFeed:(UMComFeedEntity *)draftFeed;

- (id)initWithForwardFeed:(UMComFeed *)forwardFeed;

- (id)initWithTopic:(UMComTopic *)topic;

- (IBAction)showTopicPicker:(id)sender;

- (IBAction)showImagePicker:(id)sender;

- (IBAction)showLocationPicker:(id)sender;

- (IBAction)showAtFriend:(id)sender;

- (IBAction)takePhoto:(id)sender;

- (void)postContent;

@end
