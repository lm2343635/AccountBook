//
//  RecordDao.h
//  GroupFinance
//
//  Created by lidaye on 5/29/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "DaoTemplate.h"

#define RecordEntityName @"Record"

@interface RecordDao : DaoTemplate

- (Record *)saveWithMoney:(NSNumber *)money
                   remark:(NSString *)remark
                     time:(NSDate *)time
           classification:(Classification *)classsification
                  account:(Account *)account
                     shop:(Shop *)shop
                    photo:(Photo *)photo ;

- (NSArray *)findAll;

@end
