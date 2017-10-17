//
//  ViewController.m
//  打飞机App
//
//  Created by Yang on 2017/10/16.
//  Copyright © 2017年 Tucodec. All rights reserved.
//

#import "ViewController.h"
#include "PlaneViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setFrame:CGRectMake(100, 200, 150, 80)];
    [btn setTitle:@"开始游戏" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    //侧滑手势
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
}

-(void)test{
    PlaneViewController * plane = [[PlaneViewController alloc] init];
    [self.navigationController pushViewController:plane animated:YES];
}
@end
