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

/** 容量转换 */
- (NSString *)fileSizeToString:(unsigned long long)fileSize {
    NSInteger KB = 1024;
    NSInteger MB = KB*KB;
    NSInteger GB = MB*KB;
    
    if (fileSize < 10)  {
        return @"0 B";
    }
    else if (fileSize < KB)    {
        return @"< 1 KB";
    }
    else if (fileSize < MB)    {
        return [NSString stringWithFormat:@"%.2f KB",((CGFloat)fileSize)/KB];
    }
    else if (fileSize < GB)    {
        return [NSString stringWithFormat:@"%.2f MB",((CGFloat)fileSize)/MB];
    }
    else {
        return [NSString stringWithFormat:@"%.2f GB",((CGFloat)fileSize)/GB];
    }
}

- (BOOL)memoryInfo:(vm_statistics_data_t *)vmStats {
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(),
                                               HOST_VM_INFO,
                                               (host_info_t)vmStats,
                                               &infoCount);
    
    return kernReturn == KERN_SUCCESS;
}

- (void)logMemoryInfo {
    //http://mobile.51cto.com/iphone-285371.htm
    /**
     free是空闲内存;
     active是已使用或最近被使用过的内存，但可被分页的(在iOS中，只有在磁盘上静态存在的才能被分页，例如文件的内存映射，而动态分配的内存是不能被分页的);
     inactive是不活跃的，实际上内存不足时，你的应用就可以抢占这部分内存，因此也可看作空闲内存;
     wire就是已使用，且不可被分页的。
    natural_t    free_count;         // # of pages free
    natural_t    active_count;       //  # of pages active
    natural_t    inactive_count;     //   # of pages inactive
    natural_t    wire_count;         // # of pages wired down
    natural_t    zero_fill_count;    // # of zero fill pages
    natural_t    reactivations;      //  # of pages reactivated
    natural_t    pageins;            // # of pageins
    natural_t    pageouts;            // # of pageouts
    natural_t    faults;            //  # of faults
    natural_t    cow_faults;         //  # of copy-on-writes
    natural_t    lookups;           // object cache lookups
    natural_t    hits;               //  object cache hits
    
     added for rev1
    natural_t    purgeable_count;   // # of pages purgeable
    natural_t    purges;            // # of pages purged
    
     added for rev2
    
   //  * NB: speculative pages are already accounted for in "free_count",
   //  * so "speculative_count" is the number of "free" pages that are
   //  * used to hold data that was read speculatively from disk but
   //  * haven't actually been used by anyone so far.
     
    natural_t    speculative_count;   //  # of pages speculative
    
     */
    vm_statistics_data_t vmStats;
//    虚拟内存统计数据结构。
    if ([self memoryInfo:(&vmStats)]) {
        NSLog(@"\n总内存:%@\n空闲内存(free): %@\n已使用但可被分页的内存(active): %@\n不活跃但内存不足时可以抢占的内存(inactive): %@\n已使用，且不可被分页的内存(wire): %@\n补零页(zero fill): %@\n重激活内存(reactivations): %@\n进页面的(pageins): %@\n出页面的(pageouts): %@\n出差错磁盘空间(faults): %@\n即写即拷磁盘空间(cow_faults): %@\n对象缓存查找(lookups): %@\n对象缓存命中率(hits): %@",
              [self fileSizeToString:[self totalMemorySize]],//
              [self fileSizeToString:vmStats.free_count * vm_page_size],//
              [self fileSizeToString:vmStats.active_count * vm_page_size],//
              [self fileSizeToString:vmStats.inactive_count * vm_page_size],//
              [self fileSizeToString:vmStats.wire_count * vm_page_size],//
              [self fileSizeToString:vmStats.zero_fill_count],
              [self fileSizeToString:vmStats.reactivations],
              [self fileSizeToString:vmStats.pageins],
              [self fileSizeToString:vmStats.pageouts],
              [self fileSizeToString:vmStats.faults],
              [self fileSizeToString:vmStats.cow_faults],
              @(vmStats.lookups),
              @(vmStats.hits)
              );
    }
}
/** 获取总内存大小 */
- (unsigned long long)totalMemorySize {
    //创建一个NSProcessInfo对象，表示当前进程
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    
    //获取运行该进程的参数
    NSArray *arr = [processInfo arguments];
    NSLog(@"运行该程序的参数为：%@", arr);
    //获取该进程的进程标示符
    NSLog(@"该程序的进程标示符(PID)为：%d", [processInfo processIdentifier]);
    //获取该进程的进程名
    NSLog(@"该程序的进程名为：%@", [processInfo processName]);
    //设置该进程的新进程名
    [processInfo setProcessName:@"custom process name"];
    NSLog(@"该程序的新进程名为：%@", [processInfo processName]);
    
    //获取运行该进程的系统的环境变量
    NSLog(@"运行该进程的系统的所有环境变量为：%@", [processInfo environment]);
    //获取运行该进程的主机名
    NSLog(@"运行该进程的主机名为：%@", [processInfo hostName]);
    //获取运行该进程的操作系统的版本
    NSLog(@"运行该进程所在的操作系统名为：%@", [processInfo operatingSystemVersionString]);
    //获取运行该进程的操作系统的版本
    NSLog(@"运行该进程所在的操作系统的版本为：%@", [processInfo operatingSystemVersionString]);
    
    //获取运行该进程的系统的物理内存
    NSLog(@"运行该进程的系统的物理内存为：%lld GB", [processInfo physicalMemory]/1024/1024);
    //获取运行该进程的系统的处理器数量
    NSLog(@"运行该进程的系统的处理器数量为：%ld", (unsigned long)[processInfo processorCount]);
    //获取运行该进程的系统的处于激活状态的处理器数量
    NSLog(@"运行该进程的系统的处于激活状态的处理器数量为：%ld", (unsigned long)[processInfo activeProcessorCount]);
    //获取运行该进程的系统已运行的时间
    NSLog(@"运行该进程的系统的已运行时间为：%f", [processInfo systemUptime]);
    return [NSProcessInfo processInfo].physicalMemory;
}

/** 获取已使用内存 */
- (unsigned long)usedMemorySize {
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(),
                                               HOST_VM_INFO,
                                               (host_info_t)&vmStats,
                                               &infoCount);
    if(kernReturn != KERN_SUCCESS) {
        return NSNotFound;
    }

    return ((vm_page_size * (vmStats.wire_count + vmStats.active_count)));
}

/** 获得当前设备可用的内存 */
- (double)availableMemory {
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(),
                                               HOST_VM_INFO,
                                               (host_info_t)&vmStats,
                                               &infoCount);
    if(kernReturn != KERN_SUCCESS) {
        return NSNotFound;
    }
    
    [self logMemoryInfo];
    [self logMemoryInfo2];
    return ((vm_page_size * (vmStats.free_count + vmStats.inactive_count)));
}

/** 获取常驻内存 */
- (unsigned long)residentMemorySize {
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

/** 获取虚拟内存 */
- (NSInteger)virtualMemory {
    struct task_basic_info info;
    mach_msg_type_number_t vsize = sizeof(info);
    kern_return_t kernReturn = task_info(mach_task_self(),
                                         TASK_BASIC_INFO,
                                         (task_info_t)&info,
                                         &vsize);
    
    if(kernReturn != KERN_SUCCESS) {
        return 0;
    }
    return info.virtual_size;
}

/** 获取总磁盘容量 */
-(long long)totalDiskSize {
    struct statfs buf;
    unsigned long long freeSpace = -1;
    if (statfs("/var", &buf) >= 0) {
        freeSpace = (unsigned long long)(buf.f_bsize * buf.f_blocks);
    }
    return freeSpace;
}

/** 非超级用户可用磁盘容量 */
- (long long)availableDiskSize {
    /** file system statistics
    short    f_otype;         f_type的临时备份
    short    f_oflags;        f_flags临时备份
    long     f_bsize;         基本的文件系统块大小：总磁盘容量
    long     f_iosize;        最优传输块大小
    long     f_blocks;        文件系统总的数据块数
    long     f_bfree;         在文件系统自由块大小
    long     f_bavail;        非超级用户可获取的块大小
    long     f_files;         文件系统中的总文件节点数
    long     f_ffree;         文件系统中的可用文件节点数
    fsid_t   f_fsid;          文件系统的id
    uid_t    f_owner;         安装文件系统的用户
    short    f_reserved1;     供以后备用
    short    f_type;          文件系统类型
    long     f_flags;         安装的标识
    long     f_reserved2[2];  供以后备用
    char     f_fstypename[MFSNAMELEN];  文件系统类型名称
    char     f_mntonname[MNAMELEN];     安装的目录名
    char     f_mntfromname[MNAMELEN]; 安装的文件系统名
    char     f_reserved3;     用于对齐
    long     f_reserved4[4];  供以后备用
     */
    struct statfs buf;
    unsigned long long availSpace = -1;
    if (statfs("/var", &buf) >= 0) {
        availSpace = (unsigned long long)(buf.f_bsize * buf.f_bavail);
    }
    return availSpace;
}

/** 手机空闲磁盘容量 */
- (long long)freeDiskSize {
    struct statfs buf;
    unsigned long long freeSpace = -1;
    if (statfs("/var", &buf) >= 0) {
        freeSpace = (unsigned long long)(buf.f_bsize * buf.f_bfree);
    }
    return freeSpace;
}


/** 最优传输块大小 */
- (long long)iosizeDiskSize {
    struct statfs buf;
    unsigned long long freeSpace = -1;
    if (statfs("/var", &buf) >= 0) {
        freeSpace = (unsigned long long)(buf.f_iosize);
    }
    return freeSpace;
}

/** 判断 wifi 是否开启 */
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

/** 获取连接的 wifi 名称 */
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
            wifiName = [networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID];
            CFRelease(dictRef);
        }
    }
    CFRelease(wifiInterfaces);
    return wifiName;
}

/** 获取连接上 wifi 的当前 ip地址 */
- (NSString *)localIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces – returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family ==AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);// Free memory
    return address;
}

/** 获取wifi信号强度 */
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
    return signalStrength;
}

/** 获取网络代理的方法 */
- (NSString *)proxySetting {
    CFDictionaryRef proxySettings = CFNetworkCopySystemProxySettings();
    NSDictionary *dictProxy = (__bridge_transfer id)proxySettings;
    
    NSString *proxyAddress = @"";
    NSInteger proxyPort = 0;
    
    if ([[dictProxy objectForKey:@"HTTPEnable"] boolValue]) {//是否开启了http代理
        proxyAddress = [dictProxy objectForKey:@"HTTPProxy"]; //代理地址
        proxyPort = [[dictProxy objectForKey:@"HTTPPort"] integerValue];  //代理端口号
    }
    NSString *proxy = [NSString stringWithFormat:@"代理地址%@:\n代理端口号%ld",proxyAddress,(long)proxyPort];
    
    return proxy;
}

-(void) logMemoryInfo2 {
    
    
    int mib[6];
    mib[0] = CTL_HW;
    mib[1] = HW_PAGESIZE;
    
    int pagesize;
    size_t length;
    length = sizeof (pagesize);
    if (sysctl (mib, 2, &pagesize, &length, NULL, 0) < 0) {
        fprintf (stderr, "getting page size");
    }
    
    mach_msg_type_number_t count = HOST_VM_INFO_COUNT;
    
    vm_statistics_data_t vmstat;
    if (host_statistics (mach_host_self (), HOST_VM_INFO, (host_info_t) &vmstat, &count) != KERN_SUCCESS) {
        fprintf (stderr, "Failed to get VM statistics.");
    }
    task_basic_info_64_data_t info;
    unsigned size = sizeof (info);
    task_info (mach_task_self (), TASK_BASIC_INFO_64, (task_info_t) &info, &size);
    
    double unit = 1024 * 1024;
    double total = (vmstat.wire_count + vmstat.active_count + vmstat.inactive_count + vmstat.free_count) * pagesize / unit;
    double wired = vmstat.wire_count * pagesize / unit;
    double active = vmstat.active_count * pagesize / unit;
    double inactive = vmstat.inactive_count * pagesize / unit;
    double free = vmstat.free_count * pagesize / unit;
    double resident = info.resident_size / unit;
    NSLog(@"===================================================");
    NSLog(@"Total:%.2lfMb", total);
    NSLog(@"Wired:%.2lfMb", wired);
    NSLog(@"Active:%.2lfMb", active);
    NSLog(@"Inactive:%.2lfMb", inactive);
    NSLog(@"Free:%.2lfMb", free);
    NSLog(@"Resident:%.2lfMb", resident);
    NSLog(@"===================================================");
}

@end
