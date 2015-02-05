//
//  HTTPActionManager.h
//  w3action
//
//  Created by KH Kim on 2013. 12. 30..
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
#import <UIKit/UIKit.h>
#import "APXML.h"
#import "JSONKit.h"
#import "HTTPRequestObject.h"
#import "NSData+Extensions.h"

// ================================================================================================
//  Define
// ================================================================================================

#define ContentTypeApplicationJSON @"application/json"
#define ContentTypeApplicationXML @"application/xml"
#define ContentTypeApplicationXWWWFormURLEncoded @"application/x-www-form-urlencoded"
#define ContentTypeMultipartFormData @"multipart/form-data"
#define DataTypeJSON @"json"
#define DataTypeXML @"xml"
#define DataTypeText @"text"
#define HTTP_METHOD_GET @"GET"
#define HTTP_METHOD_POST @"POST"

enum {
    HTTPStatusCodeOK = 200,
    HTTPStatusCodeCachedOk = 304,
    HTTPStatusCodeBadRequest = 400,
    HTTPStatusCodeUnauthorized = 401,
    HTTPStatusCodeForbidden = 403,
    HTTPStatusCodeNotFound = 404,
    HTTPStatusCodeBadGateway = 502,
    HTTPStatusCodeServiceUnavailable = 503
};
typedef NSInteger HTTPStatusCode;

// ================================================================================================
//  NSURLObject
// ================================================================================================

@interface NSURLObject : NSObject
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSHTTPURLResponse *response;
+ (NSURLObject *)objectWithRequest:(NSURLRequest *)request response:(NSHTTPURLResponse *)response;
@end

// ================================================================================================
//  Interface HTTPActionManager
// ================================================================================================

@interface HTTPActionManager : NSObject <NSURLConnectionDelegate>
@property (nonatomic) BOOL async;
@property (nonatomic) BOOL useNetworkActivityIndicator;
@property (nonatomic) NSTimeInterval timeInterval;
@property (nonatomic, readonly, strong) NSMutableDictionary *headers;

+ (HTTPActionManager *)sharedInstance;
- (NSDictionary *)actionWith:(NSString *)actionId;
- (void)addResourceWithBundle:(NSBundle *)bundle plistName:(NSString *)plistName;
- (BOOL)contains:(NSString *)actionId;
- (HTTPRequestObject *)doAction:(NSString *)actionId param:(NSObject *)param body:(id)body headers:(NSDictionary *)headers success:(SuccessBlock)success error:(ErrorBlock)error;
- (HTTPRequestObject *)doActionWithRequestObject:(HTTPRequestObject *)object success:(SuccessBlock)success error:(ErrorBlock)error;
- (void)removeResourceWithBundle:(NSBundle *)bundle plistName:(NSString *)plistName;
- (NSURLObject *)URLObjectWithRequstObject:(HTTPRequestObject *)object;
@end

// ================================================================================================
//  Category NSBundle (org_apache_w3action_NSBundle)
// ================================================================================================

@interface NSBundle (org_apache_w3action_NSBundle)
- (NSDictionary *)dictionaryWithPlistName:(NSString*)plistName;
@end