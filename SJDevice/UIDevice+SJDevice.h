//
//  UIDevice+SJDevice.h
//  SJDevice
//
//  Created by jocentzhou on 2017/11/18.
//  Copyright © 2017年 jocentzhou. All rights reserved.
//

/**
 参考资料：http://www.jianshu.com/p/deab6550553a
 */
#import <UIKit/UIKit.h>

@interface UIDevice (SJDevice)

/**
 获取总内存大小，单位：byte

 @return 总内存大小
 */
-(unsigned long long)totalMemorySize;

/**
 获取已使用内存

 @return 已使用内存
 */
- (unsigned long)usedMemorySize;

/**
 获取总磁盘容量

 @return 总磁盘容量
 */
-(long long)totalDiskSize;

/**
 获取可用磁盘容量

 @return 可用磁盘容量
 */
- (long long)getAvailableDiskSize;


@end
