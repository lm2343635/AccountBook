//
//  PhotoDao.h
//  GroupFinance
//
//  Created by lidaye on 5/29/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "DaoTemplate.h"

#define PhotoEntityName @"Photo"

@interface PhotoDao : DaoTemplate

// For new photo
- (NSManagedObjectID *)saveWithData:(NSData *)pdata;

@end
