//
//  CCJBLECenterManager.h
//  CJBlueToothDemo
//
//  Created by ccj on 15/12/11.
//  Copyright © 2015年 ccj. All rights reserved.
//

#import "ViewController.h"
#import "CJBlueTooth.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CJBlueTooth *cenMgr = [CJBlueTooth defaultBleManager];
    
    [cenMgr searchPeripheralWithName:@"ITAG"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSInteger num = [cenMgr readRSSIValue];
        NSLog(@"RSSI的值是:%ld",num);
    });

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
     CJBlueTooth *cenMgr = [CJBlueTooth defaultBleManager];
    
    [cenMgr beginAlert];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
