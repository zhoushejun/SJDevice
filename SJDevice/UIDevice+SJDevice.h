//
//  UIDevice+SJDevice.h
//  SJDevice
//
//  Created by jocentzhou on 2017/11/18.
//  Copyright © 2017年 jocentzhou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (SJDevice)

/**
 获取总内存大小，单位：byte

 @return 总内存大小
 */
-(long long)getTotalMemorySize;

/**
 获取总磁盘容量

 @return 总磁盘容量
 */
-(long long)getTotalDiskSize;

/**
 获取可用磁盘容量

 @return 可用磁盘容量
 */
- (long long)getAvailableDiskSize;


@end
