//
//  HTTPActionManager.m
//  w3action
//
//  Created by KH Kim on 2013. 12. 30..
//  Copyright (c) 2013년 KH Kim. All rights reserved.
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

@implementation HTTPActionManager
{
@private
NSMutableDictionary *actionPlist;
NSMutableDictionary *actionPlistDictionary;
NSMutableDictionary *requestObjectDic;
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
    //  Instance Methods
    // ================================================================================================
    
- (id)init
    {
        self = [super init];
        if (self)
        {
            _async = YES;
            _useNetworkActivityIndicator = YES;
            _timeInterval = 10;
            _serviceState = HTTPActionServiceStateDisabled;
            _plistName = @"HTTPAction";
            actionPlist = [[NSMutableDictionary alloc] init];
            actionPlistDictionary = [[NSMutableDictionary alloc] init];
            requestObjectDic = [[NSMutableDictionary alloc] init];
        }
        return self;
    }
    
- (void)dealloc
    {
        _headers = nil;
        actionPlist = nil;
        actionPlistDictionary = nil;
        requestObjectDic = nil;
    }
    
- (void)setServiceState:(HTTPActionServiceState)serviceState
    {
        if (serviceState == _serviceState)
        return;
        
        _serviceState = serviceState;
        
        if (_serviceState > HTTPActionServiceStateDisabled)
        [self loadPlist:[NSBundle mainBundle] actionPlistName:[self actionPlistNameWithServiceState]];
    }
    
- (NSString *)stringWithServiceState
    {
        if (_serviceState == HTTPActionServiceStateLive)
        return @"";
        if (_serviceState == HTTPActionServiceStateDev)
        return @"Dev";
        if (_serviceState == HTTPActionServiceStateQA)
        return @"QA";
        if (_serviceState == HTTPActionServiceStateSM)
        return @"SM";
        return @"";
    }
    
- (NSString *)actionPlistNameWithServiceState
    {
        return [_plistName stringByAppendingString:[self stringWithServiceState]];
    }
    
- (NSDictionary *)actionWith:(NSString *)actionId
    {
        if ([self contains:actionId])
        return [actionPlist objectForKey:actionId];
        return nil;
    }
    
- (BOOL)contains:(NSString *)actionId
    {
        if (actionPlist == nil)    return NO;
        return [actionPlist objectForKey:actionId] != nil;
    }
    
- (HTTPRequestObject *)objectWithData:(NSData *)data
    {
        NSNumber *objectKey = [NSNumber numberWithUnsignedLong:[data hash]];
        return [requestObjectDic objectForKey:objectKey];
    }
    
- (HTTPRequestObject *)doAction:(NSString *)actionId param:(NSObject *)param target:(id)target success:(SEL)success error:(SEL)error
    {
        if (![self contains:actionId]) {
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [target performSelector:error withObject:[NSError errorWithDomain:[NSString stringWithFormat:@"The name of actionId \"%@\" is not exist in plist.", actionId] code:99 userInfo:nil]];
            return nil;
        }
        
        NSDictionary *action = [actionPlist objectForKey:actionId];
        HTTPRequestObject *request = [HTTPRequestObject createWithAction:action param:param target:target success:success error:error];
        [NSThread detachNewThreadSelector:@selector(doRequest:) toTarget:self withObject:request];
        return request;
    }
    
- (HTTPRequestObject *)doAction:(NSString *)actionId param:(NSObject *)param success:(void (^)(NSData *result))success error:(void (^)(NSError *error))error
    {
        if (![self contains:actionId]) {
            error([NSError errorWithDomain:[NSString stringWithFormat:@"The name of actionId \"%@\" is not exist in plist.", actionId] code:99 userInfo:nil]);
            return nil;
        }
        
        NSDictionary *action = [actionPlist objectForKey:actionId];
        HTTPRequestObject *request = [HTTPRequestObject createWithAction:action param:param];
        request.successBlock = success;
        request.errorBlock = error;
        [NSThread detachNewThreadSelector:@selector(doRequest:) toTarget:self withObject:request];
        return request;
    }
    
- (HTTPRequestObject *)doAction:(NSString *)actionId param:(NSObject *)param body:(id)body target:(id)target success:(SEL)success error:(SEL)error
    {
        if (![self contains:actionId]) {
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [target performSelector:error withObject:[NSError errorWithDomain:[NSString stringWithFormat:@"The name of actionId \"%@\" is not exist in plist.", actionId] code:99 userInfo:nil]];
            return nil;
        }
        
        NSDictionary *action = [actionPlist objectForKey:actionId];
        HTTPRequestObject *request = [HTTPRequestObject createWithAction:action param:param body:body target:target success:success error:error];
        [NSThread detachNewThreadSelector:@selector(doRequest:) toTarget:self withObject:request];
        return request;
    }
    
- (HTTPRequestObject *)doAction:(NSString *)actionId param:(NSObject *)param body:(id)body success:(void (^)(NSData *))success error:(void (^)(NSError *))error
    {
        if (![self contains:actionId]) {
            error([NSError errorWithDomain:[NSString stringWithFormat:@"The name of actionId \"%@\" is not exist in plist.", actionId] code:99 userInfo:nil]);
            return nil;
        }
        
        NSDictionary *action = [actionPlist objectForKey:actionId];
        HTTPRequestObject *request = [HTTPRequestObject createWithAction:action param:param body:body];
        request.successBlock = success;
        request.errorBlock = error;
        [NSThread detachNewThreadSelector:@selector(doRequest:) toTarget:self withObject:request];
        return request;
    }
    
- (BOOL)doActionWithRequest:(HTTPRequestObject *)request target:(id)target success:(SEL)success error:(SEL)error
    {
        if (!request)
        return NO;
        
        request.target = target;
        request.success = success;
        request.error = error;
        [NSThread detachNewThreadSelector:@selector(doRequest:) toTarget:self withObject:request];
        return YES;
    }
    
- (BOOL)doActionWithRequest:(HTTPRequestObject *)request success:(void (^)(NSData *result))success error:(void (^)(NSError *error))error
    {
        if (!request)
        return NO;
        
        request.successBlock = success;
        request.errorBlock = error;
        [NSThread detachNewThreadSelector:@selector(doRequest:) toTarget:self withObject:request];
        return YES;
    }
    
- (void)clearPlist:(NSBundle *)bundle actionPlistName:(NSString *)actionPlistName
    {
        NSString *key = [NSString stringWithFormat:@"%d-%@", bundle.hash, actionPlistName];
        
        if ([actionPlistDictionary objectForKey:key])
        {
        
         NSDictionary *actions = [actionPlistDictionary objectForKey:key];

        for (NSString *key in actions)
        {
        	[actionPlist removeObjectForKey:key];
        }
        	[actionPlistDictionary removeObjectForKey:key];
            }
    }
    
- (void)loadPlist:(NSBundle *)bundle actionPlistName:(NSString *)actionPlistName
    {
        NSString *key = [NSString stringWithFormat:@"%d-%@", bundle.hash, actionPlistName];
        if ([actionPlistDictionary objectForKey:key])
        return;
        
        NSDictionary *rootDictionary = [bundle dictionaryWithPlistName:actionPlistName];
        if (rootDictionary == nil) {
#if HTTPLogEnabled
            NSLog(@"WARNING: %@.plist is missing.", actionPlistName);
#endif
            return;
        }
        
        NSDictionary *actions = [rootDictionary objectForKey:@"Actions"];
        [actionPlist addEntriesFromDictionary:actions];
        [actionPlistDictionary setObject:actions forKey:key];
    }
    
- (void)doRequest:(HTTPRequestObject *)object
    {
        @autoreleasepool {
            if (_useNetworkActivityIndicator)
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            
            NSURLRequest *request = [self requestWithObject:object];
            if (_async)
            [self sendAsynchronousRequest:request withObject:object];
            else
            [self sendSynchronousRequest:request withObject:object];
            
#if HTTPLogEnabled
            NSLog(@"Request End -----------------------------------------");
#endif
            
        }
        [NSThread exit];
    }
    
- (NSURLRequest *)requestWithObject:(HTTPRequestObject *)object
    {
        NSString *orgUrl = [object.action objectForKey:@"url"];
        NSString *method = [object.action objectForKey:@"method"];
        NSString *contentType = [object.action objectForKey:@"contentType"];
        NSString *url = (object.param != nil && [method isEqualToString:HTTP_METHOD_GET]) ? [orgUrl stringByAppendingFormat:@"?%@", [object paramWithUTF8StringEncoding]] : orgUrl;
        
#if HTTPLogEnabled
        NSLog(@"Request Start -----------------------------------------");
        NSLog(@"headers, url, contentType, method -> %@, %@, %@, %@", headers, orgUrl, contentType, method);
        NSLog(@"param -> %@", object.param);
#endif
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:_timeInterval];
        
        [request setHTTPMethod:method];
        
        if (_headers) {
            for (NSString *key in _headers)
            [request setValue:[_headers objectForKey:key] forHTTPHeaderField:key];
        }
        
        if ([contentType isEqualToString:ContentTypeMultipartFormData]) {
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
        } else {
            [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
            
            NSString *bodyString = nil;
            if ([contentType isEqualToString:ContentTypeApplicationJSON])
            bodyString = [object.body JSONString];
            else if ([contentType isEqualToString:ContentTypeApplicationXML])
            bodyString = [object.body urlString];
            else
            bodyString = object.paramString != nil && [method isEqualToString:HTTP_METHOD_POST] ? [object paramString] : nil;
#if HTTPLogEnabled
            NSLog(@"bodyString -> %@", bodyString);
#endif
            if (bodyString) {
                NSData *body = [bodyString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
                NSString *bodyLength = [NSString stringWithFormat:@"%ul", [body length]];
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
            if (object.target)
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [object.target performSelector:object.error withObject:error];
            else
            object.errorBlock(error);
#if HTTPLogEnabled
            NSLog(@"HTTPAction error -> %@", error);
#endif
        };
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError){
            dispatch_async(dispatch_get_main_queue(), ^{
                NSNumber *objectKey = [NSNumber numberWithUnsignedLong:[data hash]];
                [requestObjectDic setObject:object forKey:objectKey];
                
                if (connectionError) {
                    callError(connectionError);
                } else {
                    NSHTTPURLResponse *_response = (NSHTTPURLResponse *) response;
                    if (_response.statusCode >= 200 && _response.statusCode <= 304) {
                        NSNumber *objectKey = [NSNumber numberWithUnsignedLong:[data hash]];
                        [requestObjectDic setObject:object forKey:objectKey];
                        
                        if (object.target)
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                        [object.target performSelector:object.success withObject:data];
                        else
                        object.successBlock(data);
#if HTTPLogEnabled
                        NSLog(@"asynchronousRequest success -> %@", [data dictionaryWithUTF8JSONString]);
#endif
                    } else {
                        callError(nil);
                    }
                }
                
                [requestObjectDic removeObjectForKey:objectKey];
                
                if (_useNetworkActivityIndicator)
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            });
        }];
    }
    
- (void)sendSynchronousRequest:(NSURLRequest *)request withObject:(HTTPRequestObject *)object
    {
        NSError *error = nil;
        NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
#if HTTPLogEnabled
        NSLog(@"synchronousRequest result, error -> %@, %@", [result dictionaryWithUTF8JSONString], error);
#endif
        dispatch_async(dispatch_get_main_queue(), ^{
            NSNumber *objectKey = [NSNumber numberWithUnsignedLong:[result hash]];
            [requestObjectDic setObject:object forKey:objectKey];
            
            if (object.target) {
                if (error != nil)
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [object.target performSelector:object.error withObject:error];
                else
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [object.target performSelector:object.success withObject:result];
            } else {
                if (error != nil)
                object.errorBlock(error);
                else
                object.successBlock(result);
            }
            
            [requestObjectDic removeObjectForKey:objectKey];
            
            if (_useNetworkActivityIndicator)
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    }
    @end

// ================================================================================================
//  Implementation NSBundle (com_pisces_com_w3action)
// ================================================================================================

@implementation NSBundle (com_pisces_com_w3action)
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
