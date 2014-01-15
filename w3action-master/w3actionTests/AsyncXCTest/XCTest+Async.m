//
//  XCTest+Async.m
//  AsyncXCTest
//
//  Created by KH Kim on 2014. 1. 2..
//  Copyright (c) 2014년 KH Kim. All rights reserved.
//

/*
 Copyright 2013 KH Kim
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "XCTest+Async.h"

@implementation XCTest (org_apache_w3action_XCTest)
- (void)async:(void (^)(FinishBlock finish))execution
{
    __block BOOL wating = YES;
    FinishBlock fb = ^(void) {
        wating = NO;
    };
    
    execution(fb);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        while (wating)
            [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    });
}
@end
