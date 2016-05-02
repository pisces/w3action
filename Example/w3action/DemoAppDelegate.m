//
//  DemoAppDelegate.m
//  w3action
//
//  Created by pisces on 04/29/2016.
//  Copyright (c) 2016 pisces. All rights reserved.
//

#import "DemoAppDelegate.h"
#import <w3action/w3action.h>

@implementation DemoAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[HTTPActionManager sharedInstance] addResourceWithBundle:[NSBundle mainBundle] plistName:@"action"];
    
    return YES;
}

@end
