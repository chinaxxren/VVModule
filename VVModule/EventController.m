//
// Created by 赵江明 on 2021/10/28.
// Copyright (c) 2021 Jiangmingz. All rights reserved.
//

#import "EventController.h"
#import "VVEventBus.h"

@interface DemoEvent : NSObject <VVIEvent>

@property(assign, nonatomic) long count;

@end

@implementation DemoEvent

@end

@implementation EventController

- (void)viewDidLoad {
    [super viewDidLoad];

    [VVSubClass(self, [DemoEvent class]) doNext:^(DemoEvent *event) {
        NSLog(@"%ld", event.count);
    }];

    [VVSubNotification(self, @"name") doNext:^(NSNotification *event) {
        NSLog(@"%@", @"Block 1 Receive Notification");
    }];

    [VVSubNotification(self, @"name") doNext:^(NSNotification *event) {
        NSLog(@"%@", @"Block 2 Receive Notification");
    }];

    [VVSubString(self, @"StringEvent") doNext:^(NSString *event) {
        NSLog(@"%@", @"Receive String Event");
    }];

    [VVSubParam(self, @"EventKey") doNext:^(VVParamEvent *event) {
        NSLog(@"Receive Json Event: %@", event.data);
    }];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"NSNotificationCenter";
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"DemoEvent";
    } else if (indexPath.row == 2) {
        cell.textLabel.text = @"StringEvent";
    } else if (indexPath.row == 3) {
        cell.textLabel.text = @"ParamEvent";
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"name" object:nil];
    } else if (indexPath.row == 1) {
        static long _count = 1;
        DemoEvent *event = [[DemoEvent alloc] init];
        event.count = _count;
        _count++;
        [[VVEventBus shared] dispatch:event];
    } else if (indexPath.row == 2) {
        [[VVEventBus shared] dispatch:@"StringEvent"];
    } else if (indexPath.row == 3) {
        VVParamEvent *event = [VVParamEvent eventWithId:@"EventKey"
                                             jsonObject:@{@"Author": @"Developer"}];
        [[VVEventBus shared] dispatch:event];
    }
}

- (void)dealloc {
    NSLog(@"Dealloc: %@", NSStringFromClass(self.class));
}

@end
