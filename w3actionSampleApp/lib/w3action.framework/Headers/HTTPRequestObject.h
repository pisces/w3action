//
//  HTTPRequestObject.h
//  w3action
//
//  Created by KH Kim on 13. 12. 30..
//  Modified by KH Kim on 15. 2. 5..
//  Modified by KH Kim on 16. 2. 16..
//  Copyright (c) 2013~2016 KH Kim. All rights reserved.
//

/*
 Copyright 2013~2016 KH Kim
 
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

typedef void (^SuccessBlock)(id _Nullable result);
typedef void (^ErrorBlock)(NSError _Nullable *error);
typedef void (^CompletionBlock)(NSHTTPURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable error);

@interface HTTPRequestObject : NSObject <NSURLSessionDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate>
@property(nonatomic, copy) NSDictionary *action;
@property(nonatomic, copy) id body;
@property(nonatomic, copy) NSDictionary *headers;
@property(nonatomic, copy) NSDictionary *param;
@property(nonatomic, readonly) NSString *paramString;
@property(nonatomic, readonly) NSURLSessionDataTask *sessionDataTask;
@property(nonatomic, weak) SuccessBlock successBlock;
@property(nonatomic, weak) ErrorBlock errorBlock;
+ (HTTPRequestObject *)objectWithAction:(NSDictionary *)action param:(NSObject *)param body:(id)body headers:(NSDictionary *)headers success:(SuccessBlock)success error:(ErrorBlock)error;
- (void)cancel;
- (void)clear;
- (void)sendAsynchronousRequest:(NSURLRequest *)request completion:(CompletionBlock)completion;
- (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSHTTPURLResponse * __nullable * __nullable)response error:(NSError * __nullable * __nullable)error;
- (NSString *)paramWithUTF8StringEncoding;
@end

@interface NSDictionary (org_apache_w3action_NSDictionary)
- (NSString *)urlEncodedString;
- (NSString *)urlString;
@end

@interface MultipartFormDataObject : NSObject
@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong) NSString *filetype;
@property (nonatomic, strong) NSData *data;
+ (MultipartFormDataObject *)objectWithFilename:(NSString *)filename filetype:(NSString *)filetype data:(NSData *)data;
@end