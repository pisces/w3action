//
//  HTTPActionManager.m
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

#import "HTTPActionManager.h"

#define HTTPActionContentTypeKey @"contentType"
#define HTTPActionDataTypeKey @"dataType"
#define HTTPActionMethodKey @"method"
#define HTTPActionTimeoutKey @"timeout"
#define HTTPActionURLKey @"url"

// ================================================================================================
//
//  HTTPActionObject
//
// ================================================================================================

@implementation NSURLObject
+ (NSURLObject *)objectWithRequest:(NSURLRequest *)request response:(NSHTTPURLResponse *)response
{
    NSURLObject *object = [[NSURLObject alloc] init];
    object.request = request;
    object.response = response;
    return object;
}
@end

// ================================================================================================
//
//  Implementation: HTTPActionManager
//
// ================================================================================================

@implementation HTTPActionManager
{
@private
    dispatch_queue_t queue;
    NSMutableDictionary *actionPlist;
    NSMutableDictionary *actionPlistDictionary;
    NSMutableDictionary *urlObjectDic;
}

// ================================================================================================
//  Class Variables
// ================================================================================================

static HTTPActionManager *uniqueInstance;

// ================================================================================================
//  Class Methods
// ================================================================================================

// Get the shared instance and create it if necessary.
+ (HTTPActionManager *)sharedInstance {
    @synchronized (self) {
        if (!uniqueInstance) {
            uniqueInstance = [[HTTPActionManager alloc] init];
            uniqueInstance.timeInterval = 10.0;
        }
    }
    return uniqueInstance;
}

// ================================================================================================
//  Overridden: NSObject
// ================================================================================================

- (void)dealloc
{
    dispatch_release(queue);
    
    _header = nil;
    actionPlist = nil;
    actionPlistDictionary = nil;
    urlObjectDic = nil;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        queue = dispatch_queue_create("org.apache.w3action.HTTPActionManager", NULL);
        _async = YES;
        _useNetworkActivityIndicator = YES;
        _timeInterval = 10;
        actionPlist = [[NSMutableDictionary alloc] init];
        actionPlistDictionary = [[NSMutableDictionary alloc] init];
        urlObjectDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}

// ================================================================================================
//  Public
// ================================================================================================

- (NSDictionary *)actionWith:(NSString *)actionId
{
    if ([self contains:actionId])
        return [actionPlist objectForKey:actionId];
    return nil;
}

- (void)addResourceWithBundle:(NSBundle *)bundle plistName:(NSString *)plistName
{
    NSString *key = [NSString stringWithFormat:@"%lu-%@", (unsigned long) bundle.hash, plistName];
    if ([actionPlistDictionary objectForKey:key])
        return;
    
    NSDictionary *rootDictionary = [bundle dictionaryWithPlistName:plistName];
    if (rootDictionary == nil)
    {
#if DEBUG
        NSLog(@"WARNING: %@.plist is missing.", plistName);
#endif
        return;
    }
    
    NSDictionary *actions = [rootDictionary objectForKey:@"Actions"];
    [actionPlist addEntriesFromDictionary:actions];
    [actionPlistDictionary setObject:actions forKey:key];
}

- (BOOL)contains:(NSString *)actionId
{
    if (actionPlist == nil)    return NO;
    return [actionPlist objectForKey:actionId] != nil;
}

- (HTTPRequestObject *)doAction:(NSString *)actionId param:(NSObject *)param body:(id)body header:(NSDictionary *)header success:(SuccessBlock)success error:(ErrorBlock)error
{
    if (![self contains:actionId])
    {
        error([NSError errorWithDomain:[NSString stringWithFormat:@"The name of actionId \"%@\" is not exist in plist.", actionId] code:99 userInfo:nil]);
        return nil;
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (_useNetworkActivityIndicator)
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSDictionary *action = [actionPlist objectForKey:actionId];
    HTTPRequestObject *object = [HTTPRequestObject objectWithAction:action param:param body:body header:header success:success error:error];
    [self doRequest:object];
    return object;
}

- (HTTPRequestObject *)doActionWithRequestObject:(HTTPRequestObject *)object success:(SuccessBlock)success error:(ErrorBlock)error
{
    if (!object)
        return NO;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (_useNetworkActivityIndicator)
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    object.successBlock = success;
    object.errorBlock = error;
    
    [self doRequest:object];
    return object;
}

- (void)removeResourceWithBundle:(NSBundle *)bundle plistName:(NSString *)plistName
{
    NSString *key = [NSString stringWithFormat:@"%lu-%@", (unsigned long) bundle.hash, plistName];
    if ([actionPlistDictionary objectForKey:key])
    {
        NSDictionary *actions = [actionPlistDictionary objectForKey:key];
        
        for (NSString *key in actions)
        	[actionPlist removeObjectForKey:key];
        
        [actionPlistDictionary removeObjectForKey:key];
    }
}

- (NSURLObject *)URLObjectWithRequstObject:(HTTPRequestObject *)object
{
    NSNumber *key = [NSNumber numberWithUnsignedLong:object.hash];
    return [urlObjectDic objectForKey:key];
}

// ================================================================================================
//  Internal
// ================================================================================================

- (void)doRequest:(HTTPRequestObject *)object
{
    dispatch_async(queue, ^(void){
        NSURLRequest *request = [self requestWithObject:object];
        if (_async)
            [self sendAsynchronousRequest:request withObject:object];
        else
            [self sendSynchronousRequest:request withObject:object];
    });
#if DEBUG
    NSLog(@"Request End -----------------------------------------");
#endif
}

- (id)resultWithData:(NSData *)data dataType:(NSString *)dataType
{
    if (!data)
        return nil;
    
    if ([dataType isEqualToString:DataTypeJSON])
        return [data dictionaryWithUTF8JSONString];
    if ([dataType isEqualToString:DataTypeText])
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return nil;
}

- (NSURLRequest *)requestWithObject:(HTTPRequestObject *)object
{
    NSString *orgUrl = [object.action objectForKey:HTTPActionURLKey];
    NSString *method = [object.action objectForKey:HTTPActionMethodKey];
    NSString *contentType = [object.action objectForKey:HTTPActionContentTypeKey];
    NSTimeInterval timeInterval = [object.action objectForKey:HTTPActionTimeoutKey] ?  [[object.action objectForKey:HTTPActionTimeoutKey] doubleValue] : _timeInterval;
    NSString *url = (object.param != nil && [method isEqualToString:HTTP_METHOD_GET]) ? [orgUrl stringByAppendingFormat:@"?%@", [object paramWithUTF8StringEncoding]] : orgUrl;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:timeInterval];
    
    [request setHTTPMethod:method];
    
    if (_header)
    {
        for (NSString *key in _header)
            [request setValue:[_header objectForKey:key] forHTTPHeaderField:key];
    }
    
    if (object.header)
    {
        for (NSString *key in object.header)
            [request setValue:[object.header objectForKey:key] forHTTPHeaderField:key];
    }
#if DEBUG
    NSLog(@"\nRequest Start -----------------------------------------\norgUrl -> %@,\nurl -> %@,\ncontentType -> %@,\n method -> %@,\n header -> %@,\n param -> %@", orgUrl, url, contentType, method, request.allHTTPHeaderFields, object.param);
#endif
    if ([contentType isEqualToString:ContentTypeMultipartFormData])
    {
        NSString *boundary = @"0xKhTmLbOuNdArY";
        contentType = [contentType stringByAppendingFormat:@"; boundary=%@", boundary];
        [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
        
        MultipartFormDataObject *mobject = (MultipartFormDataObject *) object.body;
        NSMutableData *body = [NSMutableData data];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"Filedata\"; filename=\"%@\"\r\n", mobject.filename] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:mobject.data];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:body];
    }
    else
    {
        [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
        
        NSString *bodyString = nil;
        if ([contentType isEqualToString:ContentTypeApplicationJSON])
            bodyString = [((NSDictionary *) object.body) JSONString];
        else if ([contentType isEqualToString:ContentTypeApplicationXML])
            bodyString = [((NSDictionary *) object.body) urlString];
        else
            bodyString = object.paramString != nil && [method isEqualToString:HTTP_METHOD_POST] ? [object paramString] : nil;
#if DEBUG
        NSLog(@"bodyString -> %@", bodyString);
#endif
        if (bodyString)
        {
            NSData *body = [bodyString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
            NSString *bodyLength = [NSString stringWithFormat:@"%lu", (unsigned long) [body length]];
            [request setValue:bodyLength forHTTPHeaderField:@"Content-Length"];
            [request setHTTPBody:body];
        }
    }
    return request;
}

- (void)sendAsynchronousRequest:(NSURLRequest *)request withObject:(HTTPRequestObject *)object
{
    typedef void (^CallError)(NSError *error);
    CallError callError = ^void(NSError *error) {
        object.errorBlock(error);
#if DEBUG
        NSLog(@"HTTPAction error -> %@", error);
#endif
    };
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError){
            NSHTTPURLResponse *_response = (NSHTTPURLResponse *) response;
            NSNumber *key = [NSNumber numberWithUnsignedLong:object.hash];
            [urlObjectDic setObject:[NSURLObject objectWithRequest:request response:_response] forKey:key];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (connectionError) {
                callError(connectionError);
            } else {
#if DEBUG
                NSLog(@"_response.statusCode -> %d", _response.statusCode);
#endif
                if (_response.statusCode >= 200 && _response.statusCode <= 304) {
                    NSString *dataType = [object.action objectForKey:HTTPActionDataTypeKey];
                    object.successBlock([self resultWithData:data dataType:dataType]);
#if DEBUG
                    NSLog(@"\nasynchronousRequest success -> %@", [data dictionaryWithUTF8JSONString]);
#endif
                } else {
                    callError([NSError errorWithDomain:@"Unknown http error." code:_response.statusCode userInfo:@{@"data": data}]);
                }
            }
            
            [urlObjectDic removeObjectForKey:key];
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    }];
}

- (void)sendSynchronousRequest:(NSURLRequest *)request withObject:(HTTPRequestObject *)object
{
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
#if DEBUG
    NSLog(@"\nsynchronousRequest result, error -> %@, %@", [result dictionaryWithUTF8JSONString], error);
#endif
    NSNumber *key = [NSNumber numberWithUnsignedLong:object.hash];
    [urlObjectDic setObject:[NSURLObject objectWithRequest:request response:response] forKey:key];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error != nil)
            object.errorBlock(error);
        else
            object.successBlock(result);
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        [urlObjectDic removeObjectForKey:key];
    });
}
@end

// ================================================================================================
//
//  Category: NSBundle (org_apache_w3action_NSBundle)
//
// ================================================================================================

@implementation NSBundle (org_apache_w3action_NSBundle)
- (NSDictionary *)dictionaryWithPlistName:(NSString*)plistName
{
    NSError *error = nil;
    NSPropertyListFormat format;
    NSString *plistPath = [self pathForResource:plistName ofType:@"plist"];
    plistPath = plistPath == nil ? [plistName stringByAppendingString:@".plist"] : plistPath;
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    if (!plistXML)
        return nil;
    return [NSPropertyListSerialization propertyListWithData:plistXML options:NSPropertyListImmutable format:&format error:&error];
}
@end
