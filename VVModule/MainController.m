//
// Created by 赵江明 on 2021/10/28.
// Copyright (c) 2021 Jiangmingz. All rights reserved.
//

#import "MainController.h"
#import "ViewController1.h"
#import "EventController.h"

@implementation MainController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Module";
    } else {
        cell.textLabel.text = @"EventBus";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        ViewController1 *controller1 = [ViewController1 new];
        [self.navigationController pushViewController:controller1 animated:YES];
    } else {
        EventController *eventController = [EventController new];
        [self.navigationController pushViewController:eventController animated:YES];
    }
}
@end