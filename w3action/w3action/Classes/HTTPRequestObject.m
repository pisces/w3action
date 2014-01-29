//
//  HTTPRequestObject.m
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

#import "HTTPRequestObject.h"

// ================================================================================================
//
//  Implementation: HTTPRequestObject
//
// ================================================================================================

@implementation HTTPRequestObject

// ================================================================================================
//  Class method
// ================================================================================================

+ (HTTPRequestObject *)objectWithAction:(NSDictionary *)action param:(NSDictionary *)param body:(id)body header:(NSDictionary *)header success:(SuccessBlock)success error:(ErrorBlock)error
{
    HTTPRequestObject *instance = [[HTTPRequestObject alloc] init];
    instance.action = action;
    instance.body = body;
    instance.param = param;
    instance.header = header;
    instance.successBlock = success;
    instance.errorBlock = error;
    return instance;
}

// ================================================================================================
//  Overridden: NSObject
// ================================================================================================

- (void)dealloc
{
    _action = nil;
    _body = nil;
    _header = nil;
    _param = nil;
    _paramString = nil;
}

// ================================================================================================
//  Public
// ================================================================================================

- (NSString *)paramWithUTF8StringEncoding
{
    return [_paramString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (void)setParam:(NSDictionary *)param
{
    if ([param isEqual:_param])
        return;
    
    _param = nil;
    _paramString = nil;
    
    if (!param)
        return;
    
    _param = param;
    _paramString = [_param urlString];
}
@end

// ================================================================================================
//
//  Implementation: NSDictionary (org_apache_w3action_NSDictionary)
//
// ================================================================================================

@implementation NSDictionary (com_pisces_com_KnitNet)

static NSString *toString(id object)
{
    return [NSString stringWithFormat: @"%@", object];
}

static NSString *urlEncode(id object)
{
    NSString *string = toString(object);
    return [string stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
}

- (NSString *)urlEncodedString
{
    NSMutableArray *parts = [NSMutableArray array];
    for (id key in self) {
        NSString *value = (NSString *) [self objectForKey:key];
        NSString *part = [NSString stringWithFormat:@"%@=%@", urlEncode(key), urlEncode(value)];
        [parts addObject:part];
    }
    return [parts componentsJoinedByString:@"&"];
}

- (NSString *)urlString
{
    NSMutableArray *parts = [NSMutableArray array];
    for (id key in self) {
        NSString *value = (NSString *) [self objectForKey:key];
        NSString *part = [NSString stringWithFormat:@"%@=%@", key, value];
        [parts addObject:part];
    }
    return [parts componentsJoinedByString:@"&"];
}
@end

// ================================================================================================
//
//  Implementation: MultipartFormDataObject
//
// ================================================================================================

@implementation MultipartFormDataObject
+ (MultipartFormDataObject *)objectWithFilename:(NSString *)filename data:(NSData *)data
{
    MultipartFormDataObject *object = [[MultipartFormDataObject alloc] init];
    object.filename = filename;
    object.data = data;
    return object;
}
@end
