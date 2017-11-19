//
//  ViewController.m
//  SJDevice
//
//  Created by jocentzhou on 2017/11/18.
//  Copyright © 2017年 jocentzhou. All rights reserved.
//

#import "ViewController.h"
#import "SJDeviceInfoViewController.h"

@interface ViewController ()
@property (nonatomic, strong) UIButton *btnKeepBounds;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.btnKeepBounds.frame = CGRectMake(SCREEN_WIDTH/2.0-50.0, SCREEN_HEIGHT/2.0-50.0, 120, 44);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIButton *)btnKeepBounds {
    if (!_btnKeepBounds) {
        _btnKeepBounds = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnKeepBounds.backgroundColor = [UIColor orangeColor];
        _btnKeepBounds.isKeepBounds = YES;
        _btnKeepBounds.layer.cornerRadius = 8.0;
        [_btnKeepBounds setTitle:@"查看运行信息" forState:UIControlStateNormal];
        [_btnKeepBounds addTarget:self action:@selector(tappedButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_btnKeepBounds];
    }
    return _btnKeepBounds;
}

- (void)tappedButtonAction:(UIButton *)button {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *deviceInfoVC = [sb instantiateViewControllerWithIdentifier:@"SJDeviceInfoViewController_nav"];
    
    [self presentViewController:deviceInfoVC animated:YES completion:nil];
}

@end
