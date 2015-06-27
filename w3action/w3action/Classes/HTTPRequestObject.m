//
//  HTTPRequestObject.m
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

#import "HTTPRequestObject.h"

// ================================================================================================
//
//  Implementation: HTTPRequestObject
//
// ================================================================================================

@implementation HTTPRequestObject
{
@private
    CompletionBlock completionBlock;
    NSMutableData *mutableData;
}

// ================================================================================================
//  Overridden: NSObject
// ================================================================================================

#pragma mark - Overridden: NSObject

- (void)dealloc
{
    [self clear];
}

// ================================================================================================
//  Public
// ================================================================================================

#pragma mark - Public class methods

+ (HTTPRequestObject *)objectWithAction:(NSDictionary *)action param:(NSDictionary *)param body:(id)body headers:(NSDictionary *)headers success:(SuccessBlock)success error:(ErrorBlock)error
{
    HTTPRequestObject *instance = [[HTTPRequestObject alloc] init];
    instance.action = action;
    instance.body = body;
    instance.param = param;
    instance.headers = headers;
    instance.successBlock = success;
    instance.errorBlock = error;
    return instance;
}

#pragma mark - Public getter/setter

- (void)setParam:(NSDictionary *)param
{
    if ([param isEqual:_param])
        return;
    
    _param = nil;
    _paramString = nil;
    
    if (!param)
        return;
    
    _param = param;
    _paramString = _param.urlEncodedString;
}

#pragma mark - Public methods

- (void)cancel
{
    if (_connection)
    {
        [_connection cancel];
        _connection = nil;
    }
    
    completionBlock = NULL;
    mutableData = nil;
}

- (void)clear
{
    [self cancel];
    
    completionBlock = nil;
    mutableData = nil;
    _action = nil;
    _body = nil;
    _connection = nil;
    _headers = nil;
    _param = nil;
    _paramString = nil;
    _errorBlock = NULL;
    _successBlock = NULL;
}

- (NSString *)paramWithUTF8StringEncoding
{
    return [self.paramString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (void)startWithRequest:(NSURLRequest *)request completion:(CompletionBlock)completion
{
    [self cancel];
    
    completionBlock = completion;
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    
    [_connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [_connection start];
}

// ================================================================================================
//  Private
// ================================================================================================

#pragma mark - Private methods

- (void)processWithError:(NSError *)error
{
    if (completionBlock)
        completionBlock(NO, nil, error);
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error
{
    [self processWithError:error];
}

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    
    if (httpResponse.statusCode >= 200 && httpResponse.statusCode <= 304)
        mutableData = [NSMutableData data];
    else
        [self processWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnknown userInfo:@{@"statusCode": @(httpResponse.statusCode)}]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection
{
    if (completionBlock)
        completionBlock(YES, mutableData, nil);
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)data
{
    [mutableData appendData:data];
}

@end

// ================================================================================================
//
//  Implementation: NSDictionary (org_apache_w3action_NSDictionary)
//
// ================================================================================================

@implementation NSDictionary (org_apache_w3action_NSDictionary)

static NSString *urlEncode(NSString *string)
{
    CFStringRef str = CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef) string, NULL, (CFStringRef) @"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
    NSString *result = [NSString stringWithString:(__bridge NSString *) str];
    CFRelease(str);
    return result;
}

- (NSString *)urlEncodedString
{
    NSMutableArray *parts = [NSMutableArray array];
    for (id key in self) {
        NSString *encodedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        id value = [self objectForKey:key];
        value = [value isKindOfClass:[NSString class]] ? urlEncode(value) : value;
        
        [parts addObject:[NSString stringWithFormat:@"%@=%@", encodedKey, value]];
    }
    return [parts componentsJoinedByString:@"&"];
}

- (NSString *)urlString
{
    NSMutableArray *parts = [NSMutableArray array];
    for (id key in self) {
        id value = [self objectForKey:key];
        
        [parts addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
    }
    return [parts componentsJoinedByString:@"&"];
}
@end

// ================================================================================================
//
//  Implementation: MultipartFormDataObject
//
// ================================================================================================

// ================================================================================================
//  Public
// ================================================================================================

#pragma mark - Public class methods

@implementation MultipartFormDataObject
+ (MultipartFormDataObject *)objectWithFilename:(NSString *)filename filetype:(NSString *)filetype data:(NSData *)data
{
    MultipartFormDataObject *object = [[MultipartFormDataObject alloc] init];
    object.filename = filename;
    object.filetype = filetype;
    object.data = data;
    return object;
}
@end
