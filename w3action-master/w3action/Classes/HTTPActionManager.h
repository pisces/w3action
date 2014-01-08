//
//  HTTPActionManager.h
//  w3action
//
//  Created by KH Kim on 2013. 12. 30..
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
#import <UIKit/UIKit.h>
#import "JSONKit.h"
#import "HTTPRequestObject.h"
#import "NSData+Extensions.h"
#import "MultipartFormDataObject.h"

enum {
    HTTPActionServiceStateDisabled = 0,
    HTTPActionServiceStateLive = 1,
    HTTPActionServiceStateDev = 2,
    HTTPActionServiceStateQA = 3,
    HTTPActionServiceStateSM = 4
};
typedef int HTTPActionServiceState;

// ================================================================================================
//  Define
// ================================================================================================

#define HTTP_METHOD_GET @"GET"
#define HTTP_METHOD_POST @"POST"
#define ContentTypeApplicationJSON @"application/json"
#define ContentTypeApplicationXML @"application/xml"
#define ContentTypeApplicationXWWWFormURLEncoded @"application/x-www-form-urlencoded"
#define ContentTypeMultipartFormData @"multipart/form-data"

// ================================================================================================
//  Interface HTTPActionManager
// ================================================================================================

@interface HTTPActionManager : NSObject
@property (nonatomic) BOOL async;
@property (nonatomic) BOOL useNetworkActivityIndicator;
@property (nonatomic) NSTimeInterval timeInterval;
@property (nonatomic) HTTPActionServiceState serviceState;
@property (nonatomic, retain) NSString *plistName;
@property (nonatomic, retain) NSDictionary *header;

+ (HTTPActionManager *)sharedInstance;
- (NSString *)actionPlistNameWithServiceState;
- (NSDictionary *)actionWith:(NSString *)actionId;
- (void)clearPlist:(NSBundle *)bundle actionPlistName:(NSString *)actionPlistName;
- (BOOL)contains:(NSString *)actionId;
- (HTTPRequestObject *)doAction:(NSString *)actionId param:(NSObject *)param body:(id)body header:(NSDictionary *)header success:(SuccessBlock)success error:(ErrorBlock)error;
- (BOOL)doActionWithRequest:(HTTPRequestObject *)request;
- (void)loadPlist:(NSBundle *)bundle actionPlistName:(NSString *)actionPlistName;
- (HTTPRequestObject *)objectWithData:(NSData *)data;
- (NSString *)stringWithServiceState;
@end

// ================================================================================================
//  Category NSBundle (com_pisces_lib_w3action)
// ================================================================================================

@interface NSBundle (com_pisces_lib_w3action)
- (NSDictionary *)dictionaryWithPlistName:(NSString*)plistName;
@end