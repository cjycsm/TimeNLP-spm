//
//  TimeNormalizer.h
//  TimeNLP
//
//  Created by NAGI on 2017/10/13.
//  Copyright © 2017年 NAGI. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TimeUnit;

@interface TimeNormalizer : NSObject

@property (nonatomic, assign)BOOL isPreferFuture;
@property (nonatomic, copy)NSString* timeBase;
@property (nonatomic, copy)NSString* oldTimeBase;
@property (nonatomic, copy)NSString* target;

/**
 * 同上的TimeNormalizer的构造方法，timeBase取默认的系统当前时间
 *
 * @param text 待分析字符串
 * @return 时间单元数组
 */
- (NSArray<TimeUnit*>*)handleText:(NSString*)text;

/**
 * TimeNormalizer的构造方法，根据提供的待分析字符串和timeBase进行时间表达式提取
 * 在构造方法中已完成对待分析字符串的表达式提取工作
 *
 * @param text   待分析字符串
 * @param timeBase 给定的timeBase
 * @return 返回值
 */
- (NSArray<TimeUnit*>*)handleText:(NSString*)text timeBase:(NSString*)timeBase;
@end
