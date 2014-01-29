//
//  ViewController.m
//  w3actionSampleApp
//
//  Created by KH Kim on 2014. 1. 29..
//  Copyright (c) 2014년 KH Kim. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"w3action Sample";
    
    // Set up one time in application
    [[HTTPActionManager sharedInstance] addResourceWithBundle:[NSBundle mainBundle] plistName:@"action"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[HTTPActionManager sharedInstance] doAction:@"example-datatype-json" param:nil body:nil header:nil success:^(NSDictionary *result){
        NSLog(@"JSON result -> %@", result);
        self.textView.text = [NSString stringWithFormat:@"example-datatype-json success\n\nresult ->\n%@", result];
    } error:^(NSError *error){
        NSLog(@"error -> %@", error);
        self.textView.text = [NSString stringWithFormat:@"example-datatype-json error ->\n%@", error];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
