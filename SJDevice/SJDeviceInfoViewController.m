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

@end

@implementation SJDeviceInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"当前设备运行时信息";
    
    NSMutableArray *mutArray = [[NSMutableArray alloc] init];
    [mutArray addObject:self.currentDevice.name];
    [mutArray addObject:self.currentDevice.systemName];
    [mutArray addObject:self.currentDevice.systemVersion];
    [mutArray addObject:[NSNumber numberWithUnsignedLongLong:self.currentDevice.totalDiskSize]];
    
    self.lblInfo.text = [NSString stringWithFormat:@"%@\n%@\n%@", self.currentDevice.name,
                         self.currentDevice.systemName,
                         self.currentDevice.systemVersion];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIDevice *)currentDevice {
    if (!_currentDevice) {
        _currentDevice = [UIDevice currentDevice];
    }
    return _currentDevice;
}

@end
