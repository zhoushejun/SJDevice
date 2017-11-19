//
//  SJDeviceInfoViewController.m
//  SJDevice
//
//  Created by 周社军 on 2017/11/18.
//  Copyright © 2017年 jocentzhou. All rights reserved.
//

#import "SJDeviceInfoViewController.h"
#import "UIDevice+SJDevice.h"

@interface SJDeviceInfoViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lblInfo;
@property (nonatomic, strong) UIDevice *currentDevice;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation SJDeviceInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"当前设备运行时信息";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [self refreshUI];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refreshUI) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willEnterForeground:(NSNotification *)notification {
    [self refreshUI];
}

- (void)refreshUI {
    NSMutableArray *mutArray = [[NSMutableArray alloc] init];
    [mutArray addObject:self.currentDevice.name];
    [mutArray addObject:self.currentDevice.systemName];
    [mutArray addObject:self.currentDevice.systemVersion];
    [mutArray addObject:[NSString stringWithFormat:@"总内存:%@", [self.currentDevice fileSizeToString: self.currentDevice.totalMemorySize]]];
    [mutArray addObject:[NSString stringWithFormat:@"已用内存:%@", [self.currentDevice fileSizeToString: self.currentDevice.usedMemorySize]]];
    [mutArray addObject:[NSString stringWithFormat:@"可用的内存:%@", [self.currentDevice fileSizeToString: self.currentDevice.availableMemory]]];
    [mutArray addObject:[NSString stringWithFormat:@"常驻内存:%@", [self.currentDevice fileSizeToString: self.currentDevice.residentMemorySize]]];
    [mutArray addObject:[NSString stringWithFormat:@"虚拟内存:%@", [self.currentDevice fileSizeToString: self.currentDevice.virtualMemory]]];
    [mutArray addObject:[NSString stringWithFormat:@"总磁盘容量:%@", [self.currentDevice fileSizeToString: self.currentDevice.totalDiskSize]]];
    [mutArray addObject:[NSString stringWithFormat:@"非超级用户可用磁盘容量:%@", [self.currentDevice fileSizeToString: self.currentDevice.availableDiskSize]]];
    [mutArray addObject:[NSString stringWithFormat:@"手机空闲磁盘容量:%@", [self.currentDevice fileSizeToString: self.currentDevice.freeDiskSize]]];
    [mutArray addObject:[NSString stringWithFormat:@"最优传输块大小:%@", [self.currentDevice fileSizeToString: self.currentDevice.iosizeDiskSize]]];

    self.lblInfo.text = [mutArray componentsJoinedByString:@"\n"];
}

- (UIDevice *)currentDevice {
    if (!_currentDevice) {
        _currentDevice = [UIDevice currentDevice];
    }
    return _currentDevice;
}
- (IBAction)tappedExitButtonAction:(id)sender {
    [self.timer invalidate];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
