//
//  UMComPostEditViewController.m
//  UMCommunity
//
//  Created by umeng on 15/11/19.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComPostingViewController.h"
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

//定义新的话题逻辑宏
//#define NewEditTopic
//#ifdef NewEditTopic
//此模板参数为iphone6上得高度参数
const CGFloat g_template_visiableViewHeight = 378.f;//可视区域的高度
const CGFloat g_template_titleTextViewHeight = 47.f;//文本标题高度
const CGFloat g_template_contentTextViewHeight = 191.f;//内容高度
const CGFloat g_template_addImgViewHeight = 98.f;//添加图片高度
const CGFloat g_template_addImgViewSpaceHeight = 30.f;//添加图片上下间隔的总和，上面15下面15
const CGFloat g_template_locationViewHeight = 45.f;//位置高度

const CGFloat g_template_leftMargin = 15.f;//控件的左边距间距

@interface UIViewController (forwardDeclarationForUMComPostingViewController)
- (void)goBack;
@end

//#endif

@interface UMComPostingViewController () <UMComEditTextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>


@property (nonatomic, strong) UMComTopic *topic;

@property (nonatomic, assign) CGFloat visibleViewHeight;

@property (nonatomic, strong) NSMutableArray *originImages;


@property (nonatomic, copy) void (^selectedFeedTypeBlock)(NSNumber *type);


//#ifdef NewEditTopic
@property(nonatomic,readwrite,strong)UMComEditTextView *titleTextView;//标题
@property(nonatomic,readwrite,strong)UMComEditTextView *contentTextView;//内容
@property(nonatomic,readwrite,strong)UMComAddedImageView* addImgView;//增加图片的控件
@property(nonatomic,readwrite,strong) UMComLocationView *locationView;
@property(nonatomic,readwrite,assign) CGRect viewFrameWithInit;//初始化的区域，在弹出相机时，坐标会变化影响addimage的布局
-(void) createTitleTextView;//设置标题控件
-(void) createContentTextView;//设置内容控件
-(void) createTopicNavigationItem;//设置导航栏
-(void) createSeparateLineBelowRect:(CGRect)frame;//设置分割线
-(void) createAddedImageView;//创建选择图片控件
-(void) popActionSheetForAddImageView; //用户点击+添加事件
-(void) createLocationView;
-(void) relayoutChildView;//重新布局子控件
-(void) initPrePostingData;//初始化上次上传不成功的数据
@property(nonatomic,readwrite,assign) BOOL isFristHaveImgData;//此函数用来表明是第一次加载有图片的数据
//#endif

@end

@implementation UMComPostingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.editFeedEntity = [[UMComFeedEntity alloc]init];
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
    [self.titleTextView becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated;
{
    [super viewDidAppear:animated];
    self.viewFrameWithInit = self.view.frame;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:self];
    [self.titleTextView resignFirstResponder];
    [self.contentTextView resignFirstResponder];

}



- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.originImages = [NSMutableArray arrayWithCapacity:9];
    
    [self createTitleTextView];
    [self createContentTextView];
    [self createAddedImageView];
    [self createLocationView];
    
    [self createTopicNavigationItem];
    
    [self initPrePostingData];


}

-(void) initPrePostingData
{
    if ([UMComSession sharedInstance].draftFeed) {
        self.editFeedEntity = [UMComSession sharedInstance].draftFeed;
    }
    
    //简单判断当前用户的操作是否为空来判断当前用户是否已经提交过请求，并且提交请求失败
    if([self.editFeedEntity.uid isEqualToString:@""])
        return;
    
    if (self.editFeedEntity.title) {
        self.titleTextView.text = self.editFeedEntity.title;
        if (self.titleTextView.text.length > 0) {
            self.titleTextView.placeholderLabel.hidden = YES;
        }
    }
    
    if (self.editFeedEntity.text) {
        self.contentTextView.text = self.editFeedEntity.text;
        if (self.contentTextView.text.length > 0) {
            self.contentTextView.placeholderLabel.hidden = YES;
        }
    }
    
    if (self.editFeedEntity.images) {
        self.isFristHaveImgData = YES;
        [self.originImages addObjectsFromArray:self.editFeedEntity.images];
    }
    
    if (self.editFeedEntity.locationDescription) {
        [self.locationView relayoutChildControlsWithLocation:self.editFeedEntity.locationDescription];
    }
    
}



-(void)onClickClose:(id)sender
{
    //如果用户主动点击取消按钮，就直接清空draftFeed保存的内容，防止下次再进入是显示内容
    if([UMComSession sharedInstance].draftFeed)
    {
        [UMComSession sharedInstance].draftFeed = nil;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    [self.navigationController popViewControllerAnimated:YES];
}





- (void)handleOriginImages:(NSArray *)images{
    
    //[self.originImages addObjectsFromArray:images];//zhangjunhua_删除，回调前，已经加入
    [self.addImgView addImages:images];
    CGSize itemSize = self.addImgView.itemSize;
    CGSize contentSize = self.addImgView.contentSize;
    CGPoint offset = self.addImgView.contentOffset;
    //NSLog(@"handleOriginImages:self.addImgView.contentSize=%f,self.addImgView.contentoffset = %f",self.addImgView.contentSize.height,self.addImgView.contentOffset.y);
    if (self.originImages.count >= 4) {
        self.addImgView.contentOffset = CGPointMake(0,self.addImgView.contentSize.height - self.addImgView.bounds.size.height - itemSize.height + itemSize.height /3);
    }
}



- (void)updateImageAddedImageView
{
//    CGRect rect = self.addImgView.frame;
//    int i = 0;
//    i++;
}
- (void)viewsFrameChange
{
    [self relayoutChildView];
}


-(void)keyboardWillShow:(NSNotification*)notification
{
    CGRect keybordFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float endheight = keybordFrame.size.height;
    if (self.viewFrameWithInit.size.height > 0) {
        self.visibleViewHeight = self.viewFrameWithInit.size.height - endheight;;//在调出照相机的时候会隐藏摄像头，导致self.view变化
    }
    else
    {
        self.visibleViewHeight = self.view.frame.size.height - endheight;//在调出照相机的时候会隐藏摄像头，导致self.view变化
    }
    //NSLog(@"keyboardWillShow>>self.visibleViewHeight = %f,self.view = %@",self.visibleViewHeight,self.view);
    [self viewsFrameChange];
}

-(void)keyboardDidShow:(NSNotification*)notification
{
//    CGRect keybordFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    float endheight = keybordFrame.size.height;
//    CGFloat tempVisiableHeight = self.view.frame.size.height - endheight;
//    NSLog(@"keyboardDidShow>>self.visibleViewHeight = %f,tempVisiableHeight= %f,endheight = %f,self.view = %@",self.visibleViewHeight,tempVisiableHeight,endheight,self.view);
    
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
        imagePickerController.maximumNumberOfSelection = 9 - [self.addImgView.arrayImages count];
        
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
            [weakSelf.locationView.label setText:self.editFeedEntity.locationDescription];
            weakSelf.locationView.hidden = NO;
            [weakSelf updateImageAddedImageView];
            [weakSelf.contentTextView becomeFirstResponder];
        }
    }];
    [self.navigationController pushViewController:locationViewController animated:YES];
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

}

- (BOOL)editTextView:(UMComEditTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text complection:(void (^)())block
{
    return YES;

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
    if (!self.titleTextView.text || self.titleTextView.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:UMComLocalizedString(@"Sorry",@"抱歉") message:UMComLocalizedString(@"Empty_TitileText",@"标题内容不能为空") delegate:nil cancelButtonTitle:UMComLocalizedString(@"OK",@"好") otherButtonTitles:nil];
        [alertView show];
        [self.titleTextView becomeFirstResponder];
        return;
    }
    if (self.topic) {
        self.editFeedEntity.topics = @[self.topic];
    }
    self.editFeedEntity.title = self.titleTextView.text;
    self.editFeedEntity.images = self.originImages;

    /**
     *  屏蔽对正文内容的检测
     */
    
    /*
    if (!self.contentTextView.text || self.contentTextView.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:UMComLocalizedString(@"Sorry",@"抱歉") message:UMComLocalizedString(@"Empty_ContentText",@"文字内容不能为空") delegate:nil cancelButtonTitle:UMComLocalizedString(@"OK",@"好") otherButtonTitles:nil];
        [alertView show];
        [self.contentTextView becomeFirstResponder];
        return;
    }
    
    
    if ([self.contentTextView getRealTextLength] < MinTextLength && self.originImages.count == 0) {
        NSString *tooShortNotice = [NSString stringWithFormat:@"发布的内容太少啦，再多写点内容。"];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:UMComLocalizedString(@"Sorry",@"抱歉") message:UMComLocalizedString(@"The content is too long",tooShortNotice) delegate:nil cancelButtonTitle:UMComLocalizedString(@"OK",@"好") otherButtonTitles:nil];
        [alertView show];
        [self.contentTextView becomeFirstResponder];
        return;
    }
    
    if (self.contentTextView.text && [self.contentTextView getRealTextLength] > self.contentTextView.maxTextLenght) {
        NSString *tooLongNotice = [NSString stringWithFormat:@"内容过长,超出%d个字符",(int)[self.contentTextView getRealTextLength] - (int)self.contentTextView.maxTextLenght];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:UMComLocalizedString(@"Sorry",@"抱歉") message:UMComLocalizedString(@"The content is too long",tooLongNotice) delegate:nil cancelButtonTitle:UMComLocalizedString(@"OK",@"好") otherButtonTitles:nil];
        [alertView show];
        [self.contentTextView becomeFirstResponder];
        return;
    }
     */
    
    self.editFeedEntity.text = self.contentTextView.text;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSMutableArray *postImages = [NSMutableArray array];
    //iCloud共享相册中的图片没有原图
    for (UIImage *image in self.originImages) {
        UIImage *originImage = [self compressImage:image];
        [postImages addObject:originImage];
    }
    [self postEditContentWithImages:postImages response:^(id responseObject, NSError *error) {
//        __strong typeof(weakSelf) strongSelf = weakSelf;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self dealWhenPostFeedFinish:responseObject error:error];
    }];
    [self goBack];
}



- (void)dealWhenPostFeedFinish:(NSArray *)responseObject error:(NSError *)error
{
    if (error) {
        [UMComShowToast showFetchResultTipWithError:error];
    } else if([responseObject isKindOfClass:[NSArray class]] && responseObject.count > 0) {
        if (self.postCreatedFinish) {
            self.postCreatedFinish(responseObject.firstObject);
        }
        UMComFeed *feed = responseObject.firstObject;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPostFeedResultNotification object:feed];
        [UMComShowToast createFeedSuccess];
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

//- (void)postForwardFeed:(UMComFeed *)forwardFeed
//               response:(void (^)(id responseObject,NSError *error))response
//{
//    NSMutableArray *atUsers = [NSMutableArray arrayWithCapacity:1];
//    for (UMComUser *user in self.editFeedEntity.atUsers) {
//        [atUsers addObject:user];
//    }
//    UMComFeed *originFeed = forwardFeed;
//    while (originFeed.origin_feed) {
//        if (![atUsers containsObject:originFeed.creator]) {
//            [atUsers addObject:originFeed.creator];
//        }
//        originFeed = originFeed.origin_feed;
//    }
//    self.editFeedEntity.atUsers = atUsers;
//    [UMComPushRequest forwardWithFeed:forwardFeed newFeed:self.editFeedEntity completion:^(id responseObject, NSError *error) {
//        if (response) {
//            response(responseObject,error);
//        }
//    }];
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//#ifdef NewEditTopic
-(void) createTitleTextView
{
    NSArray *regexArray = [NSArray arrayWithObjects:UserRulerString, TopicRulerString,UrlRelerSring, nil];
    self.titleTextView = [[UMComEditTextView alloc]initWithFrame:CGRectMake(g_template_leftMargin, 0, self.view.frame.size.width - g_template_leftMargin, g_template_titleTextViewHeight) checkWords:nil regularExStrArray:regexArray];
    self.titleTextView.editDelegate = self;
    self.titleTextView.maxTextLenght = 30;
    [self.titleTextView setFont:textFont];
    [self.view addSubview:self.titleTextView];
    self.titleTextView.placeholderLabel.text = @"请输入标题呗,限30字";
    self.titleTextView.textAlignment = NSTextAlignmentLeft;
}

-(void) createContentTextView
{
    NSArray *regexArray = [NSArray arrayWithObjects:UserRulerString, TopicRulerString,UrlRelerSring, nil];
    self.contentTextView = [[UMComEditTextView alloc]initWithFrame:CGRectMake(g_template_leftMargin, self.titleTextView.frame.origin.y + self.titleTextView.frame.size.height, self.view.frame.size.width-g_template_leftMargin, g_template_contentTextViewHeight) checkWords:nil regularExStrArray:regexArray];
    self.contentTextView.editDelegate = self;
    self.contentTextView.maxTextLenght = [UMComSession sharedInstance].maxFeedLength;
    [self.contentTextView setFont:textFont];
    [self.view addSubview:self.contentTextView];
    self.contentTextView.placeholderLabel.text = @"请写点什么吧";
    
    UIView* separateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
    separateView.backgroundColor = UMComColorWithColorValueString(@"eeeff3");
    [self.contentTextView addSubview:separateView];
    
}

-(void) createTopicNavigationItem
{
    UMComBarButtonItem *leftButtonItem = [[UMComBarButtonItem alloc] initWithTitle:@"取消"  target:self action:@selector(onClickClose:)];
    [self.navigationItem setLeftBarButtonItem:leftButtonItem];
    leftButtonItem.customButtonView.frame = CGRectMake(0, 0, 35, 35);
    [leftButtonItem.customButtonView setTitleColor:UMComColorWithColorValueString(@"b5b5b5") forState:UIControlStateNormal];
    leftButtonItem.customButtonView.titleLabel.font = UMComFontNotoSansLightWithSafeSize(15);
    
    UMComBarButtonItem* rightButtonItem = [[UMComBarButtonItem alloc] initWithTitle:@"提交" target:self action:@selector(postContent)];
    rightButtonItem.customButtonView.frame = CGRectMake(0, 0, 35, 35);
    [rightButtonItem.customButtonView setTitleColor:UMComColorWithColorValueString(@"008bea") forState:UIControlStateNormal];
    rightButtonItem.customButtonView.titleLabel.font = UMComFontNotoSansLightWithSafeSize(15);
    [self.navigationItem setRightBarButtonItem:rightButtonItem];
    
    //设置中间文本
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:self.navigationController.navigationBar.bounds];
    titleLabel.text = @"发帖";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = UMComFontNotoSansLightWithSafeSize(20);
    titleLabel.textColor =  UMComColorWithColorValueString(@"008bea");
    [self.navigationItem setTitleView:titleLabel];
}

-(void) createSeparateLineBelowRect:(CGRect)frame
{
    UIView* separateView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.origin.y + frame.size.height + 2, self.view.bounds.size.width, 2)];
    
    separateView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:separateView];
}

-(void) createAddedImageView
{
    self.addImgView = [[UMComAddedImageView alloc] initWithFrame:CGRectMake(0, self.contentTextView.frame.origin.y + self.contentTextView.frame.size.height, self.view.bounds.size.width, g_template_addImgViewHeight)];
    [self.view addSubview:self.addImgView];
    self.addImgView.isUsingForumMethod = YES;
    self.addImgView.isAddImgViewShow = YES;
    self.addImgView.isDashWithBorder = YES;
    self.addImgView.deleteViewType = UMComActionDeleteViewType_Rectangle;
    
    //提前算好一行4个图片的高度和宽度，
    int itemSpace = 10;//每个图片的间隔为10像素
    int countPerLine = 4;//每行四个图片
    int itemWidth = (self.addImgView.bounds.size.width - 5 * itemSpace)/countPerLine;
    self.addImgView.itemSize = CGSizeMake(itemWidth, itemWidth);
    
//    //算出每个图片的高度后，必须保证一个完整地图片显示，所以此处需要调整整个addImgView的位置，以保证显示一张完整地图片
//    CGRect orgFrame = self.addImgView.frame;
//    orgFrame.size.height = itemWidth + itemSpace*2 + 2.0;//再加两个像素为了，让用户看到下面也有图片
//    self.addImgView.frame = orgFrame;

    [self.addImgView addImages:[NSArray array]];
    
     __weak typeof(self) weakSelf = self;
    [self.addImgView setPickerAction:^{
        //[weakSelf setUpPicker];
        //[weakSelf takePhoto:nil];
        [weakSelf popActionSheetForAddImageView];
    }];
    self.addImgView.imagesChangeFinish = ^(){
        [weakSelf updateImageAddedImageView];
    };
    self.addImgView.imagesDeleteFinish = ^(NSInteger index){
        [weakSelf.originImages removeObjectAtIndex:index];
    };
    
}

-(void) createLocationView
{
    self.locationView = [[UMComLocationView alloc]initWithFrame:CGRectMake(0, self.addImgView.frame.origin.y + self.addImgView.frame.size.height, self.view.frame.size.width, g_template_locationViewHeight)];
    [self.view addSubview:self.locationView];
    
    UIView* separateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.locationView.bounds.size.width, 1)];
    separateView.backgroundColor = UMComColorWithColorValueString(@"eeeff3");
    [self.locationView addSubview:separateView];
    
    [self.locationView relayoutChildControlsWithLocation:@""];
    
    __weak typeof(self) weakSelf = self;
    self.locationView.locationBlock = ^{
        UMComLocationListController *locationViewController = [[UMComLocationListController alloc] initWithLocationSelectedComplectionBlock:^(UMComLocationModel *locationModel) {
            if (locationModel) {
                weakSelf.editFeedEntity.location = [[CLLocation alloc] initWithLatitude:locationModel.coordinate.latitude longitude:locationModel.coordinate.longitude];
                weakSelf.editFeedEntity.locationDescription = locationModel.name;
                [weakSelf.locationView relayoutChildControlsWithLocation:weakSelf.editFeedEntity.locationDescription];

            }
        }];
        [weakSelf.navigationController pushViewController:locationViewController animated:YES];
    };
    
}

-(void) relayoutChildView
{
    if (self.visibleViewHeight <= 0) {
        return;
    }
    
    //计算标题控件坐标比例
    CGFloat temp_titleTextViewHeight = g_template_titleTextViewHeight*self.visibleViewHeight/g_template_visiableViewHeight;
    CGRect temp_titleTextViewOrgRect = self.titleTextView.frame;
    temp_titleTextViewOrgRect.size.height = (int)temp_titleTextViewHeight;
    self.titleTextView.frame = temp_titleTextViewOrgRect;
    
    //计算内容控件的坐标比例
    CGFloat temp_contentTextViewHeight = g_template_contentTextViewHeight*self.visibleViewHeight/g_template_visiableViewHeight;
    CGRect temp_contentTextViewOrgRect = self.contentTextView.frame;
    temp_contentTextViewOrgRect.size.height = (int)temp_contentTextViewHeight;
    temp_contentTextViewOrgRect.origin.y = temp_titleTextViewOrgRect.origin.y + temp_titleTextViewOrgRect.size.height;
    self.contentTextView.frame = temp_contentTextViewOrgRect;
    
    //计算添加图片的坐标比例
    CGFloat temp_addImgViewHeight = g_template_addImgViewHeight*self.visibleViewHeight/g_template_visiableViewHeight;
    CGRect temp_addImgViewOrgRect = self.addImgView.frame;
    temp_addImgViewOrgRect.size.height = (int)temp_addImgViewHeight;
    temp_addImgViewOrgRect.origin.y = temp_contentTextViewOrgRect.origin.y + temp_contentTextViewOrgRect.size.height;
    self.addImgView.frame = temp_addImgViewOrgRect;
    
    //提前算好一行4个图片的高度和宽度，
    int itemSpace = 10;//每个图片的间隔为10像素
    int countPerLine = 4;//每行四个图片
    int tempspace = g_template_addImgViewSpaceHeight*self.visibleViewHeight/g_template_visiableViewHeight;
    int temp_itemWidth = (self.addImgView.bounds.size.width - 5 * itemSpace)/countPerLine;
    int itemWidth = temp_itemWidth < self.addImgView.frame.size.height ?  temp_itemWidth :  (self.addImgView.frame.size.height -tempspace);
    self.addImgView.itemSize = CGSizeMake(itemWidth, itemWidth);
    if (self.isFristHaveImgData) {
        self.isFristHaveImgData = YES;
        [self.addImgView addImages:self.originImages];//强制改变+的大小
    }
    else
    {
        [self.addImgView addImages:[NSArray array]];//强制改变+的大小
    }
    
    
    //添加位置控件的坐标比例
    CGFloat temp_locationViewHeight = g_template_locationViewHeight*self.visibleViewHeight/g_template_visiableViewHeight;
    CGRect temp_locationViewOrgRect = self.locationView.frame;
    temp_locationViewOrgRect.size.height = (int)temp_locationViewHeight;
    temp_locationViewOrgRect.origin.y = temp_addImgViewOrgRect.origin.y + temp_addImgViewOrgRect.size.height;
    self.locationView.frame = temp_locationViewOrgRect;
    
    [self.locationView relayoutChildControlsWithLocation:self.editFeedEntity.locationDescription];
}

//#endif

#pragma mark 
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0://拍照
            NSLog(@"actionSheet index 0");
            [self takePhoto:nil];
            break;
        case 1://相册
            NSLog(@"actionSheet index 1");
            [self setUpPicker];
            break;
        case 2://取消
            NSLog(@"actionSheet index 2");
            [self.titleTextView becomeFirstResponder];
            break;
        default:
            break;
    }
}

-(void) popActionSheetForAddImageView
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"请选择图片源:"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"拍照",@"相册",nil];
    
    [self.titleTextView resignFirstResponder];
    [self.contentTextView resignFirstResponder];
    [sheet showInView:self.view];
}
@end


