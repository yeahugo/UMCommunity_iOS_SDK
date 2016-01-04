//
//  UMComEditViewController.m
//  UMCommunity
//
//  Created by Gavin Ye on 9/2/14.
//  Copyright (c) 2014 Umeng. All rights reserved.
//

#import "UMComEditViewController.h"
#import "UMComLocationListController.h"
#import "UMComFriendTableViewController.h"
#import "UMImagePickerController.h"
#import "UMComEditTopicsViewController.h"
#import "UMComUser.h"
#import "UMComTopic.h"
#import "UMComShowToast.h"
#import "UMUtils.h"
#import "UMComSession.h"
#import "UIViewController+UMComAddition.h"
#import "UMComNavigationController.h"
#import "UMComImageView.h"
#import "UMComAddedImageView.h"
#import "UMComBarButtonItem.h"
#import "UMComFeedEntity.h"
#import <AVFoundation/AVFoundation.h>
#import "UMComHorizonMenuView.h"
#import "UMComEditTextView.h"
#import "UMComMutiStyleTextView.h"
#import "UMComLocationModel.h"
#import "UMComPushRequest.h"
#import "UMComUser+UMComManagedObject.h"
#import "UMComFeed.h"
#import "UMComLocationView.h"
#import "UMComEditForwardView.h"


#define ForwardViewHeight 101
#define EditToolViewHeight 43
#define textFont UMComFontNotoSansLightWithSafeSize(15)
#define MinTextLength 5

@interface UMComEditViewController () <UMComEditTextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic,strong) UMComEditTopicsViewController *topicsViewController;

@property (nonatomic, strong) UMComFeed *forwardFeed;       //转发的feed

@property (nonatomic, strong) NSMutableArray *forwardCheckWords;  //转发时用于校验高亮字体

@property (nonatomic, strong) UMComTopic *topic;

@property (nonatomic, assign) CGFloat visibleViewHeight;

@property (nonatomic, strong) NSMutableArray *originImages;

@property (strong, nonatomic) UMComAddedImageView *addedImageView;

@property (nonatomic, strong) UMComEditTextView *realTextView;

@property (nonatomic, strong) UMComHorizonMenuView *editMenuView;

@property (nonatomic, strong) UIView *imagesBgView;


@property (nonatomic, strong) UMComEditForwardView * forwardFeedBackground;

@property (strong, nonatomic) UIImageView *topicNoticeBgView;

@property (strong, nonatomic) UMComLocationView *locationView;

@property (nonatomic, copy) void (^selectedFeedTypeBlock)(NSNumber *type);

@end

@implementation UMComEditViewController


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.editFeedEntity = [[UMComFeedEntity alloc]init];
    }
    return self;
}

-(id)initWithForwardFeed:(UMComFeed *)forwardFeed
{
    self = [self init];
    if (self) {
        self.forwardFeed = forwardFeed;
    }
    return self;
}

- (id)initWithTopic:(UMComTopic *)topic
{
    self = [self init];
    if (self) {
        self.topic = topic;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    [self.locationView.label setText:self.editFeedEntity.locationDescription];
    [self.realTextView becomeFirstResponder];
    self.editMenuView.frame = CGRectMake(self.editMenuView.frame.origin.x, self.editMenuView.frame.origin.y, self.view.frame.size.width, 50);
    [self createMenuView];
    if (self.forwardFeed) {
        if (!self.forwardFeedBackground) {
            [self showWhenForwordOldFeed];
        }
    }
    [self handleOriginImages:self.editFeedEntity.images];
    
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:self];
    [self.realTextView resignFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.visibleViewHeight = 0;
    [self setTitleViewWithTitle:@"新鲜事"];
    [self topicsAddOneTopic:self.topic];
    //创建textView
    [self createTextView];
    
    if (self.forwardFeed) {
        [self followsAddOneUser:self.forwardFeed.creator];
    }else{
        [self showWhenEditNewFeed];
    }
    self.originImages = [NSMutableArray array];
    
    //设置导航条两端按钮
    UIBarButtonItem *leftButtonItem = [[UMComBarButtonItem alloc] initWithNormalImageName:@"cancelx" target:self action:@selector(onClickClose:)];
    [self.navigationItem setLeftBarButtonItem:leftButtonItem];
    
    UIBarButtonItem *rightButtonItem = [[UMComBarButtonItem alloc] initWithNormalImageName:@"sendx" target:self action:@selector(postContent)];
    [self.navigationItem setRightBarButtonItem:rightButtonItem];
    self.forwardFeedBackground.hidden = YES;
    
    if ([UMComSession sharedInstance].draftFeed) {
        self.editFeedEntity = [UMComSession sharedInstance].draftFeed;
    }
}


-(void)onClickClose:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


#pragma mark - ViewsChange

- (void)createMenuView
{
    if (!self.editMenuView) {
        self.editMenuView = [[UMComHorizonMenuView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
        [self.view addSubview:self.editMenuView];
        __weak typeof(self) weakSelf = self;
        self.editMenuView.selectedAtIndex = ^(UMComHorizonMenuView *menuView, NSInteger index){
            if (index == 0) {
                [weakSelf showTopicPicker:nil];
            }else if (index == 1){
                [weakSelf takePhoto:nil];
            }else if (index == 2){
                [weakSelf showImagePicker:nil];
            }else if (index == 3){
                [weakSelf showLocationPicker:nil];
            }else if (index == 4){
                [weakSelf showAtFriend:nil];
            }
        };
        if (self.forwardFeed) {
            UMComMenuItem *item = [UMComMenuItem itemWithTitle:nil imageName:@"@+x" highLightTitle:nil highLightImageName:@"##+x"];
            item.highLightType = HighLightImage;
            item.itemViewType = menuImageFullNoTitleType;
            [self.editMenuView reloadWithMenuItems:[NSArray arrayWithObjects:item, nil] itemSize:CGSizeMake(30, 30)];
            __weak typeof(self) weakSelf = self;
            self.editMenuView.selectedAtIndex = ^(UMComHorizonMenuView *menuView, NSInteger index){
                if (index == 0) {
                    [weakSelf showAtFriend:nil];
                }
            };
        }else{
            NSArray *menuItems = [NSArray arrayWithObjects:[UMComMenuItem itemWithTitle:nil imageName:@"##+x"],[UMComMenuItem itemWithTitle:nil imageName:@"camera+x"],[UMComMenuItem itemWithTitle:nil imageName:@"photo+x"],[UMComMenuItem itemWithTitle:nil imageName:@"pin+x"],[UMComMenuItem itemWithTitle:nil imageName:@"@+x"], nil];
            for (UMComMenuItem *item in menuItems) {
                item.highLightType = HighLightImage;
                item.itemViewType = menuImageFullNoTitleType;
            }
            [self.editMenuView reloadWithMenuItems:menuItems
                                          itemSize:CGSizeMake(30, 30)];
            self.topicNoticeBgView.frame = CGRectMake(self.editMenuView.itemSize.width/2 + self.editMenuView.itemSpace, self.topicNoticeBgView.frame.origin.y, self.topicNoticeBgView.frame.size.width, self.topicNoticeBgView.frame.size.height);
        }
    }
}

#pragma mark -  UITextView relate method

- (void)createTextView
{
    NSArray *regexArray = [NSArray arrayWithObjects:UserRulerString, TopicRulerString,UrlRelerSring, nil];
    self.realTextView = [[UMComEditTextView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 120) checkWords:[self getCheckWords] regularExStrArray:regexArray];
    self.realTextView.editDelegate = self;
    self.realTextView.maxTextLenght = [UMComSession sharedInstance].maxFeedLength;
    [self.realTextView setFont:textFont];
    __weak typeof(self) weakSekf = self;
    self.realTextView.getCheckWords = ^(){
        return [weakSekf getCheckWords];
    };
    //如果有话题则默认添加话题
    if (self.topic && [UMComSession sharedInstance].isShowTopicName) {
        [self.realTextView setText:[NSString stringWithFormat:TopicString,self.topic.name]];
    }
    self.realTextView.text = self.editFeedEntity.text;
    [self.realTextView updateEditTextView];
    [self.view addSubview:self.realTextView];
    
}


- (NSArray *)getCheckWords
{
    NSMutableArray *checkWodrs = [NSMutableArray array];
    if (self.forwardCheckWords.count > 0) {
        [checkWodrs addObjectsFromArray:self.forwardCheckWords];
    }
    for (UMComTopic *topic in self.editFeedEntity.topics) {
        NSString *topicName = [NSString stringWithFormat:TopicString,topic.name];
        if (![checkWodrs containsObject:topicName]) {
            [checkWodrs addObject:topicName];
        }
    }
    for (UMComUser *user in self.editFeedEntity.atUsers) {
        NSString *userName = [NSString stringWithFormat:UserNameString,user.name];
        if (![checkWodrs containsObject:userName]) {
            [checkWodrs addObject:userName];
        }
    }
    return checkWodrs;
}

- (void)showWhenEditNewFeed
{
    self.topicNoticeBgView = [[UIImageView alloc]initWithFrame: CGRectMake(20, 300, 200, 30)];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(3, 0, self.topicNoticeBgView.frame.size.width, 25)];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.font = textFont;
    label.textColor = [UIColor whiteColor];
    [self.topicNoticeBgView addSubview:label];
    if ([[[[UMComSession sharedInstance] loginUser] gender] integerValue] == 1) {
        label.text = @"大哥啊，添加个话题吧！";
    }else{
        label.text = @"大妹砸，添加个话题吧！";
    }
    self.topicNoticeBgView.image = UMComImageWithImageName(@"add_topic_notice");
    [self.view addSubview:self.topicNoticeBgView];
    
    self.realTextView.placeholderLabel.text = @" 分享新鲜事...";
    [self handleOriginImages:self.editFeedEntity.images];
}

- (void)showWhenForwordOldFeed
{
    UMComFeed *originFeed = self.forwardFeed;
    NSString *feedAndUserNamesText = @" ";
    self.forwardCheckWords = [NSMutableArray array];
    NSArray *tempArray = [self getFeedCheckWordsFromFeed:originFeed];
    for (NSString *checkWord in tempArray) {
        if (![self.forwardCheckWords containsObject:checkWord]) {
            [self.forwardCheckWords addObject:checkWord];
        }
    }
    while (originFeed.origin_feed) {
        feedAndUserNamesText = [feedAndUserNamesText stringByAppendingFormat:@"//@%@：%@ ",originFeed.creator.name,originFeed.text];
        NSArray *tempArray2 = [self getFeedCheckWordsFromFeed:originFeed.origin_feed];
        for (NSString *checkWord in tempArray2) {
            if (![self.forwardCheckWords containsObject:checkWord]) {
                [self.forwardCheckWords addObject:checkWord];
            }
        }
        [self followsAddOneUser:originFeed.creator];
        originFeed = originFeed.origin_feed;
    }
    self.realTextView.placeholderLabel.text = @" 说说你的观点...";
    self.realTextView.text = feedAndUserNamesText;
    self.editFeedEntity.text = feedAndUserNamesText;
    [self.realTextView updateEditTextView];
    
    [self.topicNoticeBgView removeFromSuperview];
    if (!self.forwardFeedBackground) {
        self.forwardFeedBackground = [[UMComEditForwardView alloc]initWithFrame: CGRectMake(0, self.realTextView.frame.size.height, self.view.frame.size.width, 90)];
        [self.view addSubview:self.forwardFeedBackground];
    }
    NSString *nameString = originFeed.creator.name? originFeed.creator.name:@"";
    NSString *feedString = originFeed.text?originFeed.text:@"";
    NSString *showForwardText = [NSString stringWithFormat:@"@%@：%@ ", nameString, feedString];
    NSString *urlString = nil;
    if (originFeed.image_urls && [originFeed.image_urls count] > 0) {
        urlString = [[originFeed.image_urls firstObject] valueForKey:@"small_url_string"];
    }
    [self.forwardFeedBackground reloadViewsWithText:showForwardText checkWords:self.forwardCheckWords urlString:urlString];
}

- (NSArray *)getFeedCheckWordsFromFeed:(UMComFeed *)feed
{
    NSMutableArray *checkWords = [NSMutableArray array];
    NSString *word = [NSString stringWithFormat:UserNameString,feed.creator.name];
    [checkWords addObject:word];
    for (NSString *userName in [feed.related_user.array valueForKeyPath:@"name"]) {
        if ([checkWords containsObject:userName]) {
            [checkWords addObject:[NSString stringWithFormat:UserNameString,userName]];        }
    }
    for (NSString *topicName in [feed.topics.array valueForKeyPath:@"name"]) {
        if (![checkWords containsObject:topicName]) {
            [checkWords addObject:[NSString stringWithFormat:TopicString,topicName]];
        }
    }
    return checkWords;
}


- (void)handleOriginImages:(NSArray *)images{
    
    if (!self.imagesBgView) {
        __weak typeof(self) weakSelf = self;
        self.addedImageView = [[UMComAddedImageView alloc] initWithFrame:CGRectMake(10, 0, self.view.frame.size.width-20, 70)];
        self.addedImageView.itemSize = CGSizeMake(70, 70);
        [self.addedImageView setPickerAction:^{
            [weakSelf setUpPicker];
        }];
        self.addedImageView.imagesChangeFinish = ^(){
            [weakSelf updateImageAddedImageView];
        };
        self.addedImageView.imagesDeleteFinish = ^(NSInteger index){
            [weakSelf.originImages removeObjectAtIndex:index];
        };
        [self.addedImageView addImages:images];
        self.locationView = [[UMComLocationView alloc]initWithFrame:CGRectMake(self.addedImageView.frame.origin.x+self.addedImageView.imageSpace/2, 0, self.view.frame.size.width-self.addedImageView.frame.origin.x-self.addedImageView.imageSpace/2, 25)];
        self.locationView.label.text = @"";
        self.locationView.hidden = YES;
        self.locationView.label.font = UMComFontNotoSansLightWithSafeSize(13);
        
        self.imagesBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, self.addedImageView.frame.size.height + self.locationView.frame.size.height)];
        [self.imagesBgView addSubview:self.addedImageView];
        [self.imagesBgView addSubview:self.locationView];
        [self.view addSubview:self.imagesBgView];
    }
    [self.originImages addObjectsFromArray:images];
    [self.addedImageView addImages:images];
    [self updateImageAddedImageView];
}

- (void)updateImageAddedImageView
{
    
    if (self.locationView.label.text.length > 0) {
        self.locationView.frame = CGRectMake(self.locationView.frame.origin.x, 0, self.locationView.frame.size.width, 25);
        self.locationView.hidden = NO;
    }else{
        self.locationView.frame = CGRectMake(self.locationView.frame.origin.x, 0, self.locationView.frame.size.width, 0);
        self.locationView.hidden = YES;
    }
    if (self.addedImageView.arrayImages.count == 0) {
        self.addedImageView.frame = CGRectMake(self.addedImageView.frame.origin.x, self.locationView.frame.size.height, self.addedImageView.frame.size.width, 0);
        
    }else{
        self.addedImageView.frame = CGRectMake(self.addedImageView.frame.origin.x, self.locationView.frame.size.height, self.addedImageView.frame.size.width, self.addedImageView.frame.size.height);
    }
    CGFloat height = self.addedImageView.frame.size.height + self.locationView.frame.size.height;
    CGFloat originY = self.editMenuView.frame.origin.y - height;
    self.imagesBgView.frame = CGRectMake(self.imagesBgView.frame.origin.x, originY, self.imagesBgView.frame.size.width, height);
    [self viewsFrameChange];
}


- (void)viewsFrameChange
{
    CGRect realTextViewFrame = self.realTextView.frame;
    realTextViewFrame.origin.y = 0;
    if (self.forwardFeed) {
        CGRect fowordBgFrame = self.forwardFeedBackground.frame;
        realTextViewFrame.size.height = self.editMenuView.frame.origin.y - fowordBgFrame.size.height - 2;
        self.realTextView.frame = realTextViewFrame;
        fowordBgFrame.origin.y = realTextViewFrame.origin.y + realTextViewFrame.size.height;
        self.forwardFeedBackground.frame = fowordBgFrame;
    }else{
        self.imagesBgView.hidden = NO;
        if (self.addedImageView.arrayImages.count > 0) {
            realTextViewFrame.size.height = self.editMenuView.frame.origin.y - self.imagesBgView.frame.size.height;
        }else{
            realTextViewFrame.size.height = self.editMenuView.frame.origin.y - 2;
        }
        self.realTextView.frame = realTextViewFrame;
        if (self.editFeedEntity.topics.count == 0) {
            self.topicNoticeBgView.hidden = NO;
            self.topicNoticeBgView.frame = CGRectMake(self.editMenuView.leftMargin+self.editMenuView.itemSpace+self.editMenuView.itemSize.width/2, self.editMenuView.frame.origin.y-self.topicNoticeBgView.frame.size.height, self.topicNoticeBgView.frame.size.width, self.topicNoticeBgView.frame.size.height);
        }
    }
}

-(void)keyboardWillShow:(NSNotification*)notification
{
    CGRect keybordFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float endheight = keybordFrame.size.height;
    self.visibleViewHeight = self.view.frame.size.height - endheight - self.editMenuView.frame.size.height;
    self.editMenuView.frame = CGRectMake(self.editMenuView.frame.origin.x,self.visibleViewHeight, keybordFrame.size.width, self.editMenuView.frame.size.height);
    [self viewsFrameChange];
}

-(void)keyboardDidShow:(NSNotification*)notification
{
    CGRect keybordFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float endheight = keybordFrame.size.height;
    self.visibleViewHeight = self.view.frame.size.height - endheight - self.editMenuView.frame.size.height;
    self.editMenuView.frame = CGRectMake(self.editMenuView.frame.origin.x,self.visibleViewHeight, keybordFrame.size.width, self.editMenuView.frame.size.height);
    [self viewsFrameChange];
    self.forwardFeedBackground.hidden = NO;
}


#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *selectImage = [info valueForKey:@"UIImagePickerControllerOriginalImage"];
    UIImage *tempImage = nil;
    if (selectImage.imageOrientation != UIImageOrientationUp) {
        UIGraphicsBeginImageContext(selectImage.size);
        [selectImage drawInRect:CGRectMake(0, 0, selectImage.size.width, selectImage.size.height)];
        tempImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }else{
        tempImage = selectImage;
    }
    if (self.originImages.count < 9) {
        [self.originImages addObject:tempImage];
        [self handleOriginImages:@[tempImage]];
    }
}

- (void)setUpPicker
{
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == kCLAuthorizationStatusRestricted || author == kCLAuthorizationStatusDenied)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"本应用无访问照片的权限，如需访问，可在设置中修改" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil] show];
        return;
    }
    if([UMImagePickerController isAccessible])
    {
        UMImagePickerController *imagePickerController = [[UMImagePickerController alloc] init];
        imagePickerController.minimumNumberOfSelection = 1;
        imagePickerController.maximumNumberOfSelection = 9 - [self.addedImageView.arrayImages count];
        
        [imagePickerController setFinishHandle:^(BOOL isCanceled,NSArray *assets){
            if(!isCanceled)
            {
                [self dealWithAssets:assets];
            }
        }];
        
        UMComNavigationController *navigationController = [[UMComNavigationController alloc] initWithRootViewController:imagePickerController];
        [self presentViewController:navigationController animated:YES completion:NULL];
    }
}


- (void)dealWithAssets:(NSArray *)assets
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSMutableArray *array = [NSMutableArray array];
        for(ALAsset *asset in assets)
        {
            UIImage *image = [UIImage imageWithCGImage:[asset thumbnail]];
            if (image) {
                [array addObject:image];
            }
            if ([asset defaultRepresentation]) {
                //这里把图片压缩成fullScreenImage分辨率上传，可以修改为fullResolutionImage使用原图上传
                UIImage *originImage = [UIImage
                                        imageWithCGImage:[asset.defaultRepresentation fullScreenImage]
                                        scale:[asset.defaultRepresentation scale]
                                        orientation:UIImageOrientationUp];
                if (originImage) {
                    [self.originImages addObject:originImage];
                }
            } else {
                UIImage *image = [UIImage imageWithCGImage:[asset thumbnail]];
                image = [self compressImage:image];
                if (image) {
                    [self.originImages addObject:image];
                }
            }
            
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleOriginImages:array];
        });
    });
}

- (UIImage *)compressImage:(UIImage *)image
{
    UIImage *resultImage  = image;
    if (resultImage.CGImage) {
        NSData *tempImageData = UIImageJPEGRepresentation(resultImage,0.9);
        if (tempImageData) {
            resultImage = [UIImage imageWithData:tempImageData];
        }
    }
    return image;
}

#pragma mark - EditMenuViewSelected
-(void)showImagePicker:(id)sender
{
    if(self.originImages.count >= 9){
        [[[UIAlertView alloc] initWithTitle:UMComLocalizedString(@"Sorry",@"抱歉") message:UMComLocalizedString(@"Too many images",@"图片最多只能选9张") delegate:nil cancelButtonTitle:UMComLocalizedString(@"OK",@"好") otherButtonTitles:nil] show];
        return;
    }
    [self setUpPicker];
}

-(void)takePhoto:(id)sender
{
    if(self.originImages.count >= 9){
        [[[UIAlertView alloc] initWithTitle:UMComLocalizedString(@"Sorry",@"抱歉") message:UMComLocalizedString(@"Too many images",@"图片最多只能选9张") delegate:nil cancelButtonTitle:UMComLocalizedString(@"OK",@"好") otherButtonTitles:nil] show];
        return;
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        AVAuthorizationStatus authStatus =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted)
        {
            [[[UIAlertView alloc] initWithTitle:nil message:@"本应用无访问相机的权限，如需访问，可在设置中修改" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil] show];
            return;
        }
    }else{
        ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
        if (author == kCLAuthorizationStatusRestricted || author == kCLAuthorizationStatusDenied)
        {
            [[[UIAlertView alloc] initWithTitle:nil message:@"本应用无访问相机的权限，如需访问，可在设置中修改" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil] show];
            return;
        }
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:^{
            
        }];
    }
}

-(void)showLocationPicker:(id)sender
{
    __weak typeof(self) weakSelf = self;
    UMComLocationListController *locationViewController = [[UMComLocationListController alloc] initWithLocationSelectedComplectionBlock:^(UMComLocationModel *locationModel) {
        if (locationModel) {
            weakSelf.editFeedEntity.location = [[CLLocation alloc] initWithLatitude:locationModel.coordinate.latitude longitude:locationModel.coordinate.longitude];
            weakSelf.editFeedEntity.locationDescription = locationModel.name;
            weakSelf.locationView.hidden = NO;
            [weakSelf updateImageAddedImageView];
            [weakSelf.realTextView becomeFirstResponder];
            CGRect locationFrame = weakSelf.locationView.frame;
            locationFrame.size.height = 25;
            weakSelf.locationView.frame = locationFrame;
            weakSelf.locationView.userInteractionEnabled = NO;
            weakSelf.locationView.indicatorView.hidden = YES;
            weakSelf.locationView.backgroundColor = [UIColor clearColor];
            [weakSelf.locationView relayoutChildControlsWithLocation:locationModel.name];
        }
    }];
    [self.navigationController pushViewController:locationViewController animated:YES];
}

-(void)showTopicPicker:(id)sender
{
    if (!self.topicsViewController) {
        //加入话题列表
        __weak typeof(self) weakSelf = self;
        self.topicsViewController = [[UMComEditTopicsViewController alloc] initWithTopicSelectedComplectionBlock:^(UMComTopic *topic) {
            if (topic.topicID) {
                [self topicsAddOneTopic:topic];
            }
            [weakSelf editContentAppendKvoString:[NSString stringWithFormat:TopicString,topic.name]];
        }];
        [self.topicsViewController.view setFrame:CGRectMake(0, self.editMenuView.frame.size.height+self.editMenuView.frame.origin.y,self.view.bounds.size.width, self.view.frame.size.height - self.editMenuView.frame.origin.y - self.editMenuView.frame.size.height)];
        [self.view addSubview:self.topicsViewController.view];
    }
    if ([self.realTextView isFirstResponder]) {
        [self.realTextView resignFirstResponder];
    } else {
        [self.realTextView becomeFirstResponder];
    }
    
}

-(void)showAtFriend:(id)sender
{
    __weak typeof(self) weakSelf = self;
    
    UMComFriendTableViewController *friendViewController = [[UMComFriendTableViewController alloc] initWithUserSelectedComplectionBlock:^(UMComUser *user) {
        [weakSelf followsAddOneUser:user];
        NSString *atFriendStr = @"";
        if (![sender isKindOfClass:[NSString class]]) {
            atFriendStr = @"@";
        }
        [weakSelf editContentAppendKvoString:[NSString stringWithFormat:@"%@%@ ",atFriendStr,user.name]];
    }];
    [self.navigationController pushViewController:friendViewController animated:YES];
}

- (void)editContentAppendKvoString:(NSString *)appendString
{
    NSMutableString *editString = nil;
    if (self.editFeedEntity.text.length > 0) {
        editString = [[NSMutableString alloc] initWithString:self.editFeedEntity.text];
    }else{
        editString = [[NSMutableString alloc]init];
    }
    NSRange tempRange = self.realTextView.selectedRange;
    if (editString.length >= self.realTextView.selectedRange.location) {
        [editString insertString:appendString atIndex:tempRange.location];
    }else{
        [editString appendString:appendString];
    }
    self.realTextView.selectedRange = NSMakeRange(tempRange.location+appendString.length, 0);
    self.editFeedEntity.text = editString;
    [self.realTextView setText:self.editFeedEntity.text];
    [self.realTextView updateEditTextView];
    [self.realTextView becomeFirstResponder];
}

- (void)followsAddOneUser:(UMComUser *)user
{
    NSMutableArray *follows = [NSMutableArray array];
    if (self.editFeedEntity.atUsers) {
        [follows addObjectsFromArray:self.editFeedEntity.atUsers];
    }
    if ([user isKindOfClass:[UMComUser class]]) {
        BOOL isInclude = NO;
        for (NSString *name in [self.editFeedEntity.atUsers valueForKeyPath:@"name"]) {
            if ([name isEqualToString:user.name]) {
                isInclude = YES;
            }
        }
        if (isInclude == NO) {
            [follows addObject:user];
        }
    }
    self.editFeedEntity.atUsers = follows;
}

- (void)topicsAddOneTopic:(UMComTopic *)topic
{
    NSMutableArray *topics = [NSMutableArray array];
    if (self.editFeedEntity.topics) {
        [topics addObjectsFromArray:self.editFeedEntity.topics];
    }
    if ([topic isKindOfClass:[UMComTopic class]]) {
        BOOL isInclude = NO;
        for (NSString *name in [self.editFeedEntity.topics valueForKeyPath:@"name"]) {
            if ([name isEqualToString:topic.name]) {
                isInclude = YES;
            }
        }
        if (isInclude == NO) {
            [topics addObject:topic];
        }
    }
    self.editFeedEntity.topics = topics;
}


#pragma mark - UITextViewDelegate

- (void)editTextViewDidEndEditing:(UMComEditTextView *)textView
{
    self.editFeedEntity.text = textView.text;
}

- (BOOL)editTextView:(UMComEditTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text complection:(void (^)())block
{
    if ([@"@" isEqualToString:text]) {
        [self showAtFriend:text];
        return YES;
    }
    if ([@"#" isEqualToString:text]) {
        if (self.forwardFeed == nil) {
            NSInteger location = textView.selectedRange.location;
            NSMutableString *tempString = [NSMutableString stringWithString:textView.text];
            [tempString insertString:@"#" atIndex:textView.selectedRange.location];
            textView.text = tempString;
            textView.selectedRange = NSMakeRange(location+1, 0);
            [textView resignFirstResponder];
            if (block) {
                block();
            }
            return YES;
        }
    }
    return YES;
}


- (NSArray *)editTextViewDidUpdate:(UMComEditTextView *)textView matchWords:(NSArray *)matchWords
{
    NSArray *checkWords = [self getCheckWords];
    NSMutableArray *array = [NSMutableArray arrayWithArray:checkWords];
    NSMutableArray *userList = [NSMutableArray arrayWithArray:self.editFeedEntity.atUsers];
    NSMutableArray *topicList = [NSMutableArray arrayWithArray:self.editFeedEntity.topics];
    for (NSString *checkWord in checkWords) {
        if (![matchWords containsObject:checkWord]) {
            [array removeObject:checkWord];
            for (UMComUser *user in self.editFeedEntity.atUsers) {
                NSString *userName = [NSString stringWithFormat:UserNameString,user.name];
                if ([userName isEqualToString:checkWord]) {
                    [userList removeObject:user];
                }
            }
            for (UMComTopic *topic in self.editFeedEntity.topics) {
                NSString *topicName = [NSString stringWithFormat:TopicString,topic.name];
                if ([topicName isEqualToString:checkWord]) {
                    [topicList removeObject:topic];
                }
            }
        }
    }
    self.editFeedEntity.atUsers = userList;
    self.editFeedEntity.topics = topicList;
    if (self.editFeedEntity.topics.count > 0) {
        self.topicNoticeBgView.hidden = YES;
    }else{
        self.topicNoticeBgView.hidden = NO;
    }
    self.editFeedEntity.text = textView.text;
    return array;
}

- (BOOL)isString:(NSString *)string
{
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (string.length > 0) {
        return YES;
    }
    return NO;
}

#pragma mark - creatFeed

- (void)postContent
{
    [self.realTextView resignFirstResponder];
    
    self.editFeedEntity.text = self.realTextView.text;
    if (!self.forwardFeed && ![self isString:self.realTextView.text]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:UMComLocalizedString(@"Sorry",@"抱歉") message:UMComLocalizedString(@"Empty_Text",@"文字内容不能为空") delegate:nil cancelButtonTitle:UMComLocalizedString(@"OK",@"好") otherButtonTitles:nil];
        [alertView show];
        [self.realTextView becomeFirstResponder];
        return;
    }
    
    NSString *realTextString = [self.realTextView.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSMutableString *realString = [NSMutableString stringWithString:realTextString];
    if (self.topic) {
        //若需要显示话题用户手动删除话题就不带话题id，如果不需要显示话题就自动加上话题id
        NSString *topicName = [NSString stringWithFormat:TopicString,self.topic.name];
        NSRange range = [self.editFeedEntity.text rangeOfString:topicName];
        if (range.length > 0 && [UMComSession sharedInstance].isShowTopicName) {
            [realString replaceCharactersInRange:range withString:@""];
        }
    }
    if (self.forwardFeed == nil && [self.realTextView getRealTextLength] < MinTextLength) {
        NSString *tooShortNotice = [NSString stringWithFormat:@"发布的内容太少啦，再多写点内容。"];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:UMComLocalizedString(@"Sorry",@"抱歉") message:UMComLocalizedString(@"The content is too long",tooShortNotice) delegate:nil cancelButtonTitle:UMComLocalizedString(@"OK",@"好") otherButtonTitles:nil];
        [alertView show];
        [self.realTextView becomeFirstResponder];
        return;
    }
    
    if (self.realTextView.text && [self.realTextView getRealTextLength] > self.realTextView.maxTextLenght) {
        NSString *tooLongNotice = [NSString stringWithFormat:@"内容过长,超出%d个字符",(int)[self.realTextView getRealTextLength] - (int)self.realTextView.maxTextLenght];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:UMComLocalizedString(@"Sorry",@"抱歉") message:UMComLocalizedString(@"The content is too long",tooLongNotice) delegate:nil cancelButtonTitle:UMComLocalizedString(@"OK",@"好") otherButtonTitles:nil];
        [alertView show];
        [self.realTextView becomeFirstResponder];
        return;
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    __weak typeof(self) weakSelf = self;
    if (!self.forwardFeedBackground) {
        if (self.topic) {
            //若需要显示话题用户手动删除话题就不带话题id，如果不需要显示话题就自动加上话题id
            NSString *topicName = [NSString stringWithFormat:TopicString,self.topic.name];
            NSRange range = [self.editFeedEntity.text rangeOfString:topicName];
            if (range.length > 0 || ![UMComSession sharedInstance].isShowTopicName) {
                [self topicsAddOneTopic:self.topic];
                //                [self.editFeedEntity.topics addObject:self.topic];
            }
        }
        NSMutableArray *postImages = [NSMutableArray array];
        //iCloud共享相册中的图片没有原图
        for (UIImage *image in self.originImages) {
            UIImage *originImage = [self compressImage:image];
            [postImages addObject:originImage];
        }
        [self postEditContentWithImages:postImages response:^(id responseObject, NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [strongSelf dealWhenPostFeedFinish:responseObject error:error];
        }];
    } else {
        [self postForwardFeed:self.forwardFeed response:^(id responseObject, NSError *error) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [weakSelf dealWhenPostFeedFinish:responseObject error:error];
        }];
    }
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


- (void)dealWhenPostFeedFinish:(NSArray *)responseObject error:(NSError *)error
{
    if (error) {
        [UMComShowToast showFetchResultTipWithError:error];
    } else if([responseObject isKindOfClass:[NSArray class]] && responseObject.count > 0) {
        UMComFeed *feed = responseObject.firstObject;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPostFeedResultNotification object:feed];
        [UMComShowToast createFeedSuccess];
        if (self.createFeedSucceed) {
            self.createFeedSucceed(feed);
        }
    }
}


- (void)postEditContentWithImages:(NSArray *)images
                         response:(void (^)(id responseObject,NSError *error))response
{
    __weak typeof(self) weakSelf = self;
    self.editFeedEntity.images = images;
    if ([self isPermission_bulletin]) {
        self.selectedFeedTypeBlock = ^(NSNumber *type){
            [UMComPushRequest postWithFeed:weakSelf.editFeedEntity completion:^(id responseObject, NSError *error) {
                
                if (response) {
                    response(responseObject, error);
                }
                if (error) {
                    //一旦发送失败会保存到草稿箱
                    [UMComSession sharedInstance].draftFeed = weakSelf.editFeedEntity;
                } else {
                    [UMComSession sharedInstance].draftFeed = nil;
                }
            }];
        };
        [self showFeedTypeNotice];
    }else{
        [UMComPushRequest postWithFeed:self.editFeedEntity completion:^(id responeObject,NSError *error) {
            if (error) {
                //一旦发送失败会保存到草稿箱
                [UMComSession sharedInstance].draftFeed = weakSelf.editFeedEntity;
            } else {
                [UMComSession sharedInstance].draftFeed = nil;
            }
            
            if (response) {
                response(responeObject, error);
            }
        }];
    }
}


- (BOOL)isPermission_bulletin
{
    UMComUser *user = [UMComSession sharedInstance].loginUser;
    BOOL isPermission_bulletin = NO;
    if ([[UMComSession sharedInstance].loginUser.atype intValue] == 1 && [user isPermissionBulletin]) {
        isPermission_bulletin = YES;
    }
    return isPermission_bulletin;
}

- (void)showFeedTypeNotice
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:UMComLocalizedString(@"public feed", @"是否需要将本条内容标记为公告？") delegate:self cancelButtonTitle:UMComLocalizedString(@"NO", @"否") otherButtonTitles:UMComLocalizedString(@"YES", @"是"), nil];
    alertView.tag = 10001;
    [alertView show];
}

- (void)showResetFeedTypeNotice
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:UMComLocalizedString(@"no privilege creat feed", @"你没有发公告的权限，是否标记为非公告重新发送？") delegate:self cancelButtonTitle:UMComLocalizedString(@"NO", @"否") otherButtonTitles:UMComLocalizedString(@"YES", @"是"), nil];
    alertView.tag = 10002;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSNumber *type = @0;
    if (alertView.tag == 10001) {
        type = [NSNumber numberWithInteger:buttonIndex];
        if (self.selectedFeedTypeBlock) {
            self.editFeedEntity.type = type;
            self.selectedFeedTypeBlock(type);
        }
    }else{
        if (buttonIndex == 1) {
            if (self.selectedFeedTypeBlock) {
                self.editFeedEntity.type = type;
                self.selectedFeedTypeBlock(type);
            }
        }
    }
    
}

- (void)postForwardFeed:(UMComFeed *)forwardFeed
               response:(void (^)(id responseObject,NSError *error))response
{
    NSMutableArray *atUsers = [NSMutableArray arrayWithCapacity:1];
    for (UMComUser *user in self.editFeedEntity.atUsers) {
        [atUsers addObject:user];
    }
    UMComFeed *originFeed = forwardFeed;
    while (originFeed.origin_feed) {
        if (![atUsers containsObject:originFeed.creator]) {
            [atUsers addObject:originFeed.creator];
        }
        originFeed = originFeed.origin_feed;
    }
    self.editFeedEntity.atUsers = atUsers;
    [UMComPushRequest forwardWithFeed:forwardFeed newFeed:self.editFeedEntity completion:^(id responseObject, NSError *error) {
        if (response) {
            response(responseObject,error);
        }
    }];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
