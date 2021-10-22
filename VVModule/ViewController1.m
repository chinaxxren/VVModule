//
// Created by 赵江明 on 2021/10/22.
// Copyright (c) 2021 chinaxxren. All rights reserved.
//


#import "ViewController1.h"

#import "VVModuleRegister.h"
#import "TestModuleService.h"
#import "TestModule.h"

@interface ViewController1 ()

@end

@implementation ViewController1

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"First";
    self.view.backgroundColor = [UIColor greenColor];

    id <TestModuleService1> service1 = [[VVServiceManager sharedInstance] serviceWithName:@"TestModuleService1"];
    [service1 function1];

    id <TestModuleService2> service2 = [[VVServiceManager sharedInstance] serviceWithName:@"TestModuleService2"];
    [service2 function2];

    id <TestModuleService3> service3 = [[VVServiceManager sharedInstance] serviceWithName:@"TestModuleService3"];
    [service3 function3];

    [[VVMediator sharedInstance] performAction:@"action2" router:@"TestRouter" params:@{IsCheckRouter: @(YES)}];

    VVNotificationCenter *center3 = [TestModule3 tp_notificationCenter];
    [center3 addObserver:self selector:@selector(testNotification:) name:@"broadcast_notification_from_TestModule2" object:nil];


    UIButton *gotoBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120, 44)];
    [gotoBtn setTitle:@"Go To Second" forState:UIControlStateNormal];
    [gotoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    gotoBtn.center = self.view.center;
    [gotoBtn addTarget:self action:@selector(goTo2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:gotoBtn];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    VVNotificationCenter *center2 = [TestModule2 tp_notificationCenter];
    [center2 reportNotification:^(TPNotificationMaker *make) {
        make.name(@"report_notification_from_TestModule2");
    }              targetModule:@"TestModule1"];

    [center2 broadcastNotification:^(TPNotificationMaker *make) {
        make.name(@"broadcast_notification_from_TestModule2").userInfo(@{@"key": @"value"}).object(self);
    }];
}

- (void)testNotification:(id)aNotification {
    NSLog(@"ViewController testNotification %@", aNotification);
}

- (void)goTo2 {
    [[VVMediator sharedInstance] openURL:@"china://com.waqu.test/action_test?id=1&name=jack" params:@{@"abc": @"123"}];
}

@end
