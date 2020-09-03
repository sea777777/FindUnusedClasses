//
//  FindUnusedClasses.h
//  wojiubuxinle
//
//  Created by 刘彦超 on 2020/9/2.
//  Copyright © 2020 刘彦超. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FindUnusedClasses : NSObject

/*
 notSystemClass : 非系统类对象，如：[Student Class]
 */
+ (NSArray *)allUnusedClasses:(Class)notSystemClass;

@end

NS_ASSUME_NONNULL_END
