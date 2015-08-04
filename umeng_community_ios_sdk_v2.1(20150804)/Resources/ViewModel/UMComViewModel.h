//
//  UMComViewModel.h
//  UMCommunity
//
//  Created by luyiyuan on 14/10/14.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "UMComFetchRequest.h"

@protocol UMComViewModelDelegate <NSObject>

@optional
- (void)loadDataFromCoreDataWithCompletion:(LoadDataCompletion)completion;

- (void)loadDataFromWebWithCompletion:(LoadDataCompletion)completion;

- (void)loadMoreDataWithCompletion:(LoadDataCompletion)completion getDataFromWeb:(LoadServerDataCompletion)fromWeb;

@end


@interface UMComViewModel : NSObject<NSFetchedResultsControllerDelegate,UMComViewModelDelegate>

@end
