//
//  MMVBoxInfoModels.h
//  MwancpQuery
//
//  Created by Mike on 2017/9/28.
//  Copyright © 2017年 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMVBoxInfoModel;
@interface MMVBoxInfoModels : NSObject


@property (nonatomic, copy) NSString *msg;

@property (nonatomic, copy) NSString *param;

@property (nonatomic, strong) MMVBoxInfoModel *data;


+(instancetype)friendWithDict:(NSDictionary *)dict;
-(instancetype)initWithDict:(NSDictionary *)dict;


@end
