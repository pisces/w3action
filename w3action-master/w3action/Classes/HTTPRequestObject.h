//
//  HTTPRequestObject.h
//  w3action
//
//  Created by KH Kim on 13. 12. 30..
//  Copyright (c) 2013 KH Kim. All rights reserved.
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

#import <Foundation/Foundation.h>

typedef void (^SuccessBlock)(NSData *result);
typedef void (^ErrorBlock)(NSError *error);

@interface HTTPRequestObject : NSObject
@property(nonatomic, retain) NSDictionary *action;
@property(nonatomic, retain) id body;
@property(nonatomic, retain) NSDictionary *header;
@property(nonatomic, retain) NSObject *param;
@property(nonatomic, readonly, retain) NSString *paramString;
@property(nonatomic, copy) SuccessBlock successBlock;
@property(nonatomic, copy) ErrorBlock errorBlock;
+ (HTTPRequestObject *)createWithAction:(NSDictionary *)action param:(NSObject *)param body:(id)body header:(NSDictionary *)header success:(SuccessBlock)success error:(ErrorBlock)error;
- (NSString *)paramWithUTF8StringEncoding;
@end

// ================================================================================================
//  Category NSDictionary (com_pisces_com_KnitNet)
// ================================================================================================

@interface NSDictionary (com_pisces_com_KnitNet)
- (NSString *)urlEncodedString;
- (NSString *)urlString;
@end