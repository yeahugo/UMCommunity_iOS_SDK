//
//  Medal+CoreDataProperties.h
//  UMCommunity
//
//  Created by umeng on 15/12/29.
//  Copyright © 2015年 Umeng. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "UMComMedal.h"

void initMedal();
NS_ASSUME_NONNULL_BEGIN

@interface UMComMedal (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *classify;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *desc;
@property (nullable, nonatomic, retain) NSString *medal_id;
@property (nullable, nonatomic, retain) NSString *icon_url;
@property (nullable, nonatomic, retain) NSNumber *person_num;
@property (nullable, nonatomic, retain) NSString *create_time;

@end

NS_ASSUME_NONNULL_END
