//
//  UIDevice+SJDevice.m
//  SJDevice
//
//  Created by jocentzhou on 2017/11/18.
//  Copyright © 2017年 jocentzhou. All rights reserved.
//

#import "UIDevice+SJDevice.h"
#import <sys/utsname.h>
#import <sys/mount.h>
#import <sys/sysctl.h>
#import <mach/mach.h>
#import <ifaddrs.h>
#import <net/if.h>
#include <arpa/inet.h>

#import <SystemConfiguration/CaptiveNetwork.h>


@implementation UIDevice (SJDevice)

/** 获取总内存大小 */
- (unsigned long long)totalMemorySize {
    return [NSProcessInfo processInfo].physicalMemory;
}

/** 获取已使用内存 */
- (unsigned long)usedMemorySize {
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(),
                                         TASK_BASIC_INFO,
                                         (task_info_t)&taskInfo,
                                         &infoCount);
    
    if (kernReturn != KERN_SUCCESS) {
        return NSNotFound;
    }
    
    return taskInfo.resident_size;
}

/** 获得当前设备可用的内存 */
//获取当前任务所占用的内存
- (double)availableMemory {
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(),HOST_VM_INFO,(host_info_t)&vmStats,&infoCount);
    if(kernReturn != KERN_SUCCESS) {
        return NSNotFound;
    }
    return ((vm_page_size * vmStats.free_count) / 1024.0) / 1024.0;
}


- (NSInteger)virtualMemory {
    //参考：https://www.zhihu.com/question/22992491
    //    task_info 里面得的值和activity monitor是一样的，task_info的第三个参数，是要根据版本修改的，现在应该已经推荐使用为mach_task_basic_info_data_t了，所以调用方式应该改为:
//    mach_task_basic_info_data_t info;
//    unsigned size = sizeof (info);
//    task_info (mach_task_self (), MACH_TASK_BASIC_INFO, (task_info_t) &info, &size);
    
    struct task_basic_info info;
    mach_msg_type_number_t vsize = sizeof(info);
    if(task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &vsize) != KERN_SUCCESS) {
        return 0;
    }
    return info.virtual_size / 1024 /1024;
}

/** 获取总磁盘容量 */
-(long long)getTotalDiskSize {
    struct statfs buf;
    unsigned long long freeSpace = -1;
    if (statfs("/var", &buf) >= 0)
    {
        freeSpace = (unsigned long long)(buf.f_bsize * buf.f_blocks);
    }
    return freeSpace;
}

/** 获取可用磁盘容量 */
- (long long)getAvailableDiskSize {
    struct statfs buf;
    unsigned long long freeSpace = -1;
    if (statfs("/var", &buf) >= 0)
    {
        freeSpace = (unsigned long long)(buf.f_bsize * buf.f_bavail);
    }
    return freeSpace;
}

/** 容量转换 */
- (NSString *)fileSizeToString:(unsigned long long)fileSize {
    NSInteger KB = 1024;
    NSInteger MB = KB*KB;
    NSInteger GB = MB*KB;
    
    if (fileSize < 10)  {
        return @"0 B";
    }else if (fileSize < KB)    {
        return @"< 1 KB";
    }else if (fileSize < MB)    {
        return [NSString stringWithFormat:@"%.1f KB",((CGFloat)fileSize)/KB];
    }else if (fileSize < GB)    {
        return [NSString stringWithFormat:@"%.1f MB",((CGFloat)fileSize)/MB];
    }else   {
        return [NSString stringWithFormat:@"%.1f GB",((CGFloat)fileSize)/GB];
    }
}

- (BOOL)isWiFiEnabled {
    NSCountedSet * cset = [NSCountedSet new];
    struct ifaddrs *interfaces;
    if( ! getifaddrs(&interfaces) ) {
        for( struct ifaddrs *interface = interfaces; interface; interface = interface->ifa_next) {
            if ( (interface->ifa_flags & IFF_UP) == IFF_UP ) {
                [cset addObject:[NSString stringWithUTF8String:interface->ifa_name]];
            }
        }
    }
    
    return [cset countForObject:@"awdl0"] > 1 ? YES : NO;
}

- (NSString *)wifiName {
    NSString *wifiName = nil;
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    if (!wifiInterfaces) {
        return nil;
    }
    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    for (NSString *interfaceName in interfaces) {
        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
        if (dictRef) {
            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
            NSLog(@"network info -> %@", networkInfo);
            wifiName = [networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID];
            CFRelease(dictRef);
        }
    }
    CFRelease(wifiInterfaces);
    return wifiName;
}

- (NSString *)localIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces – returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL)
        {
            if(temp_addr->ifa_addr->sa_family ==AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

//获取wifi信号强度
- (NSInteger)wifiSignalStrength{
    
    UIApplication *app = [UIApplication sharedApplication];
//    UIView *statusBar = [app valueForKey:@"statusBar"];
    //iPhoneX
    //    UIView *foregroundView = [statusBar valueForKeyPath:@"statusBar.foregroundView"];
    //    NSArray *subviews = [foregroundView subviews];
    //非iPhoneX
    NSArray *subviews = [[[app valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
    NSString *dataNetworkItemView = nil;
    
    for (id subview in subviews) {
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
            dataNetworkItemView = subview;
            break;
        }
    }
    
    NSInteger signalStrength = [[dataNetworkItemView valueForKey:@"_wifiStrengthBars"] integerValue];
    
    NSLog(@"signal %ld", (long)signalStrength);
    
    return signalStrength;
}

/** 获取网络代理的方法 */
+ (BOOL)proxySetting {
    CFDictionaryRef proxySettings = CFNetworkCopySystemProxySettings();
    NSDictionary *dictProxy = (__bridge_transfer id)proxySettings;
    //    NSLog(@"%@",dictProxy);
    
    //是否开启了http代理
    if ([[dictProxy objectForKey:@"HTTPEnable"] boolValue]) {
        NSString *proxyAddress = [dictProxy objectForKey:@"HTTPProxy"]; //代理地址
        NSInteger proxyPort = [[dictProxy objectForKey:@"HTTPPort"] integerValue];  //代理端口号
        NSLog(@"%@:%ld",proxyAddress,(long)proxyPort);
        return YES;
    }
    return NO;
}

@end
