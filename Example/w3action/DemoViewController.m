//
//  DemoViewController.m
//  w3action
//
//  Created by pisces on 04/29/2016.
//  Copyright (c) 2016 pisces. All rights reserved.
//

#import "DemoViewController.h"
#import "DemoActionViewController.h"

@interface DemoViewController ()

@end

@implementation DemoViewController
{
    NSArray<NSString *> *cellTexts;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Select Demo";
    cellTexts = @[@"Data Type JSON",
                  @"Data Type XML",
                  @"Data Type Text"];
}


// ================================================================================================
//  Protocol Implementation
// ================================================================================================

#pragma mark - UITableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return cellTexts.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *const cellIdentifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    cell.textLabel.text = cellTexts[indexPath.row];
    
    return cell;
}

#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DemoActionViewController *controller = [[DemoActionViewController alloc] initWithType:indexPath.row + 1];
    controller.title = cellTexts[indexPath.row];
    
    [self.navigationController pushViewController:controller animated:YES];
}

@end
