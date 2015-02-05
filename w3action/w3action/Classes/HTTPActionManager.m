//
//  HTTPActionManager.m
//  w3action
//
//  Created by KH Kim on 2013. 12. 30..
//  Modified by KH Kim on 15. 2. 5..
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

#define HTTPActionAsyncKey @"async"
#define HTTPActionContentTypeKey @"contentType"
#define HTTPActionDataTypeKey @"dataType"
#define HTTPActionMethodKey @"method"
#define HTTPActionTimeoutKey @"timeout"
#define HTTPActionURLKey @"url"

// ================================================================================================
//
//  Implementation: NSURLObject
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
//  Overridden: NSObject
// ================================================================================================

#pragma mark - Overridden: NSObject

- (void)dealloc
{
    dispatch_release(queue);
    
    _headers = nil;
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
        _useNetworkActivityIndicator = YES;
        _timeInterval = 10;
        _headers = [NSMutableDictionary dictionary];
        actionPlist = [[NSMutableDictionary alloc] init];
        actionPlistDictionary = [[NSMutableDictionary alloc] init];
        urlObjectDic = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

// ================================================================================================
//  Public
// ================================================================================================

#pragma mark - Public class methods

+ (HTTPActionManager *)sharedInstance
{
    static HTTPActionManager *instance;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

#pragma mark - Public methods

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

- (HTTPRequestObject *)doAction:(NSString *)actionId param:(NSObject *)param body:(id)body headers:(NSDictionary *)headers success:(SuccessBlock)success error:(ErrorBlock)error
{
    if (![self contains:actionId])
    {
        error([NSError errorWithDomain:[NSString stringWithFormat:@"The name of actionId \"%@\" is not exist in plist.", actionId] code:99 userInfo:nil]);
        return nil;
    }
    
    HTTPRequestObject *object = [HTTPRequestObject objectWithAction:[actionPlist objectForKey:actionId] param:param body:body headers:headers success:success error:error];
    
    [self doRequest:object];
    
    return object;
}

- (HTTPRequestObject *)doActionWithRequestObject:(HTTPRequestObject *)object success:(SuccessBlock)success error:(ErrorBlock)error
{
    if (!object)
        return nil;
    
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
    return [urlObjectDic objectForKey:[NSNumber numberWithUnsignedLong:object.hash]];
}

// ================================================================================================
//  Private
// ================================================================================================

#pragma mark - Private methods

- (void)doRequest:(HTTPRequestObject *)object
{
    dispatch_async(queue, ^(void){
        NSURLRequest *request = [self requestWithObject:object];
        id asyncOption = [object.action objectForKey:HTTPActionAsyncKey];
        BOOL async = asyncOption ? [asyncOption boolValue] : _async;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.useNetworkActivityIndicator)
                [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            
            if (async)
                [self sendAsynchronousRequest:request withObject:object];
            else
                [self sendSynchronousRequest:request withObject:object];
        });
    });
#if DEBUG
    NSLog(@"Request End -----------------------------------------");
#endif
}

- (NSError *)errorWithError:(NSError *)error data:(NSData *)data
{
    NSMutableDictionary *userInfo = error.userInfo ? [NSMutableDictionary dictionaryWithDictionary:error.userInfo] : [NSMutableDictionary dictionary];
    
    if (data)
        [userInfo setObject:data forKey:@"data"];
    
    return [NSError errorWithDomain:error.domain code:error.code userInfo:userInfo];
}

- (NSURLRequest *)requestWithObject:(HTTPRequestObject *)object
{
    NSString *method = [object.action objectForKey:HTTPActionMethodKey];
    NSString *contentType = [object.action objectForKey:HTTPActionContentTypeKey];
    NSTimeInterval timeInterval = [object.action objectForKey:HTTPActionTimeoutKey] ? [[object.action objectForKey:HTTPActionTimeoutKey] doubleValue] : _timeInterval;
    NSURL *url = [self URLWithObject:object];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:timeInterval];
    
    [request setHTTPMethod:method];
    
    if (_headers)
    {
        for (NSString *key in _headers)
            [request setValue:[_headers objectForKey:key] forHTTPHeaderField:key];
    }
    
    if (object.headers)
    {
        for (NSString *key in object.headers)
            [request setValue:[object.headers objectForKey:key] forHTTPHeaderField:key];
    }
#if DEBUG
    NSLog(@"\nRequest Start -----------------------------------------\norgUrl -> %@,\nurl -> %@,\ncontentType -> %@,\n method -> %@,\n header -> %@,\n param -> %@", [object.action objectForKey:HTTPActionURLKey], url, contentType, method, request.allHTTPHeaderFields, object.param);
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

- (id)resultWithData:(NSData *)data dataType:(NSString *)dataType
{
    if (!data)
        return nil;
    
    if ([dataType isEqualToString:DataTypeJSON])
        return [data dictionaryWithUTF8JSONString];
    if ([dataType isEqualToString:DataTypeXML])
        return [APDocument documentWithXMLString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    if ([dataType isEqualToString:DataTypeText])
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return data;
}

- (void)sendAsynchronousRequest:(NSURLRequest *)request withObject:(HTTPRequestObject *)object
{
    NSNumber *key = @(object.hash);
    
    [urlObjectDic setObject:[NSURLObject objectWithRequest:request response:nil] forKey:key];
    
    [object startWithRequest:request completion:^(BOOL success, NSData *data, NSError *error) {
        if (success) {
#if DEBUG
            NSLog(@"%@:: sendAsynchronousRequest success -> %@, %@", NSStringFromClass([self class]), [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding], [data dictionaryWithUTF8JSONString]);
#endif
            NSString *dataType = [object.action objectForKey:HTTPActionDataTypeKey];
            object.successBlock([self resultWithData:data dataType:dataType]);
        } else {
#if DEBUG
            NSLog(@"%@:: sendAsynchronousRequest error -> %@, %@", NSStringFromClass([self class]), object.action, error);
#endif
            object.errorBlock([self errorWithError:error data:data]);
        }
        
        if (self.useNetworkActivityIndicator)
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        [urlObjectDic removeObjectForKey:key];
        [object clear];
    }];
}

- (void)sendSynchronousRequest:(NSURLRequest *)request withObject:(HTTPRequestObject *)object
{
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSNumber *key = @(object.hash);
    
    [urlObjectDic setObject:[NSURLObject objectWithRequest:request response:response] forKey:key];
    
    if (error) {
#if DEBUG
        NSLog(@"%@:: sendSynchronousRequest error -> %@, %@", NSStringFromClass([self class]), object.action, error);
#endif
        object.errorBlock([self errorWithError:error data:data]);
    } else {
#if DEBUG
        NSLog(@"%@:: sendSynchronousRequest success -> %@, %@", NSStringFromClass([self class]), [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding], [data dictionaryWithUTF8JSONString]);
#endif
        NSString *dataType = [object.action objectForKey:HTTPActionDataTypeKey];
        object.successBlock([self resultWithData:data dataType:dataType]);
    }
    
    if (self.useNetworkActivityIndicator)
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    [urlObjectDic removeObjectForKey:key];
    [object clear];
}

- (NSURL *)URLWithObject:(HTTPRequestObject *)object
{
    NSString *method = [object.action objectForKey:HTTPActionMethodKey];
    NSString *stringOfURL = [object.action objectForKey:HTTPActionURLKey];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\{.*?\\}" options:0 error:nil];
    NSArray *matches = [regex matchesInString:stringOfURL options:0 range:(NSRange) {0, stringOfURL.length}];
    if (matches.count > 0)
    {
        NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:object.param];
        
        for (NSTextCheckingResult *result in matches)
        {
            NSRegularExpression *propertyNameRegex = [NSRegularExpression regularExpressionWithPattern:@"\\{|\\}" options:0 error:nil];
            NSString *matchedString = [stringOfURL substringWithRange:result.range];
            NSString *propertyName = [propertyNameRegex stringByReplacingMatchesInString:matchedString options:0 range:(NSRange) {0, matchedString.length} withTemplate:@""];
            id value = [object.param objectForKey:propertyName];
            NSString *replaceString = [NSString stringWithFormat:@"%@", value];
            stringOfURL = [regex stringByReplacingMatchesInString:stringOfURL options:0 range:result.range withTemplate:replaceString];
            
            [param removeObjectForKey:propertyName];
        }
        
        object.param = param;
    }
    
    if ([method isEqualToString:HTTP_METHOD_GET] && object.param && object.param.count > 0)
        stringOfURL = [stringOfURL stringByAppendingFormat:@"?%@", [object paramWithUTF8StringEncoding]];
    
    return [NSURL URLWithString:stringOfURL];
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
