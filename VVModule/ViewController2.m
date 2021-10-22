//
// Created by 赵江明 on 2021/10/22.
// Copyright (c) 2021 chinaxxren. All rights reserved.
//


#import "ViewController2.h"

#import "VVModuleRegister.h"
#import "TestModule.h"

@interface ViewController2 ()

@end

@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Second";
    self.view.backgroundColor = [UIColor blueColor];
    
    VVNotificationCenter *center1 = [TestModule1 tp_notificationCenter];
    [center1 addObserver:self selector:@selector(testNotification:) name:@"report_notification_from_TestModule2" object:nil];
}

- (IBAction)backButtonTapped:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)testNotification:(id)aNotification {
    NSLog(@"ViewController2 testNotification %@", aNotification);
}

@end
