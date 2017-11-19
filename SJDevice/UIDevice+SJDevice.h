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
 获得当前设备可用的内存

 @return 当前设备可用的内存
 */
- (double)availableMemory;


/**
 获取常驻内存

 @return 常驻内存
 */
- (unsigned long)residentMemorySize;


/**
 获取虚拟内存

 @return 虚拟内存
 */
- (NSInteger)virtualMemory;

/**
 获取总磁盘容量

 @return 总磁盘容量
 */
-(long long)totalDiskSize;

/**
 获取非超级用户可用磁盘容量

 @return 非超级用户可用磁盘容量
 */
- (long long)availableDiskSize;

/**
 获取手机剩余磁盘容量
 
 @return 手机空闲磁盘容量
 */
- (long long)freeDiskSize;

/**
 获取最优传输块大小

 @return 最优传输块大小
 */
- (long long)iosizeDiskSize;


/**
 将byte转化为MB或GB

 @param fileSize 文件或磁盘大小，单位:byte
 @return 转化后的文件或磁盘大小字符串
 */
- (NSString *)fileSizeToString:(unsigned long long)fileSize;

/**
 判断 wifi 是否开启
 
 @return    YES/NO
 */
- (BOOL)isWiFiEnabled;

/**
 获取连接的 wifi 名称
 
 @return    连接的 wifi 名称
 */
- (NSString *)wifiName;

/**
 获取连接上 wifi 的当前 ip地址
 
 @return    本地 ip 地址
 */
- (NSString *)localIPAddress;

/**
 获取wifi信号强度
 
 @return    wifi信号强度
 */
- (NSInteger)wifiSignalStrength;


/**
 获取网络代理的方法
 
 @return 网络代理地址和端口号字符串
 */
- (NSString *)proxySetting;

@end
