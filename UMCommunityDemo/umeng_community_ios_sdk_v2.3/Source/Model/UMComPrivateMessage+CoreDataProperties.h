//
//  UMComPrivateMessage+CoreDataProperties.h
//  UMCommunity
//
//  Created by umeng on 15/12/1.
//  Copyright © 2015年 Umeng. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "UMComPrivateMessage.h"
void privateMessage();

NS_ASSUME_NONNULL_BEGIN

@interface UMComPrivateMessage (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *message_id;
@property (nullable, nonatomic, retain) NSString *content;
@property (nullable, nonatomic, retain) NSString *create_time;
@property (nullable, nonatomic, retain) UMComUser *creator;
@property (nullable, nonatomic, retain) UMComPrivateLetter *private_letter;

@end

NS_ASSUME_NONNULL_END
