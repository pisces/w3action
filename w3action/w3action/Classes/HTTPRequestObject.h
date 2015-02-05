//
//  HTTPRequestObject.h
//  w3action
//
//  Created by KH Kim on 13. 12. 30..
//  Modified by KH Kim on 15. 2. 5..
//  Copyright (c) 2013 KH Kim. All rights reserved.
//

/*
 Copyright 2013~2015 KH Kim
 
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

typedef void (^SuccessBlock)(id result);
typedef void (^ErrorBlock)(NSError *error);
typedef void (^CompletionBlock)(BOOL success, NSData *data, NSError *error);

@interface HTTPRequestObject : NSObject <NSURLConnectionDataDelegate, NSURLConnectionDelegate>
@property(nonatomic, strong) NSDictionary *action;
@property(nonatomic, strong) id body;
@property(nonatomic, strong) NSDictionary *headers;
@property(nonatomic, strong) NSDictionary *param;
@property(nonatomic, readonly, strong) NSString *paramString;
@property(nonatomic, readonly) NSURLConnection *connection;
@property(nonatomic, copy) SuccessBlock successBlock;
@property(nonatomic, copy) ErrorBlock errorBlock;
+ (HTTPRequestObject *)objectWithAction:(NSDictionary *)action param:(NSObject *)param body:(id)body headers:(NSDictionary *)headers success:(SuccessBlock)success error:(ErrorBlock)error;
- (void)cancel;
- (void)clear;
- (void)startWithRequest:(NSURLRequest *)request completion:(CompletionBlock)completion;
- (NSString *)paramWithUTF8StringEncoding;
@end

@interface NSDictionary (org_apache_w3action_NSDictionary)
- (NSString *)urlEncodedString;
- (NSString *)urlString;
@end

@interface MultipartFormDataObject : NSObject
@property (nonatomic, retain) NSString *filename;
@property (nonatomic, retain) NSData *data;
+ (MultipartFormDataObject *)objectWithFilename:(NSString *)filename data:(NSData *)data;
@end