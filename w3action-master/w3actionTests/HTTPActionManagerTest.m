//
//  HTTPActionManagerTest.m
//  w3action
//
//  Created by KH Kim on 2014. 1. 16..
//  Copyright (c) 2014년 KH Kim. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "w3action.h"

@interface HTTPActionManagerTest : XCTestCase

@end

@implementation HTTPActionManagerTest

- (void)setUp
{
    [super setUp];
    
    [[HTTPActionManager sharedInstance] addResourceWithBundle:[NSBundle bundleForClass:[self class]] plistName:@"action"];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testAddResourceWithBundle
{
    XCTAssertNotNil([[HTTPActionManager sharedInstance] actionWith:@"example-datatype-json"]);
    XCTAssertNotNil([[HTTPActionManager sharedInstance] actionWith:@"example-datatype-xml"]);
    XCTAssertNotNil([[HTTPActionManager sharedInstance] actionWith:@"example-datatype-text"]);
    XCTAssertNotNil([[HTTPActionManager sharedInstance] actionWith:@"example-contenttype-multipart"]);
}

- (void)testContains
{
    XCTAssertTrue([[HTTPActionManager sharedInstance] contains:@"example-datatype-json"]);
    XCTAssertTrue([[HTTPActionManager sharedInstance] contains:@"example-datatype-xml"]);
    XCTAssertTrue([[HTTPActionManager sharedInstance] contains:@"example-datatype-text"]);
    XCTAssertTrue([[HTTPActionManager sharedInstance] contains:@"example-contenttype-multipart"]);
}

- (void)testDoActionWithDataTypeJSON
{
    TRVSMonitor *monitor = [[TRVSMonitor alloc] initWithExpectedSignalCount:1];
    
    [[HTTPActionManager sharedInstance] doAction:@"example-datatype-json" param:nil body:nil header:nil success:^(id result){
        [monitor signal];
        XCTAssertNotNil(result);
        XCTAssertTrue([result isKindOfClass:[NSDictionary class]]);
    } error:^(NSError *error){
        [monitor signal];
        XCTAssertFalse(YES);
    }];
    
    [monitor wait];
}

- (void)testDoActionWithDataTypeXML
{
    TRVSMonitor *monitor = [[TRVSMonitor alloc] initWithExpectedSignalCount:1];
    
    [[HTTPActionManager sharedInstance] doAction:@"example-datatype-xml" param:nil body:nil header:nil success:^(id result){
        [monitor signal];
        XCTAssertNotNil(result);
        XCTAssertTrue([result isKindOfClass:[APDocument class]]);
    } error:^(NSError *error){
        [monitor signal];
        XCTAssertFalse(YES);
    }];
    
    [monitor wait];
}

- (void)testDoActionWithDataTypeText
{
    TRVSMonitor *monitor = [[TRVSMonitor alloc] initWithExpectedSignalCount:1];
    
    [[HTTPActionManager sharedInstance] doAction:@"example-datatype-text" param:nil body:nil header:nil success:^(id result){
        [monitor signal];
        XCTAssertNotNil(result);
        XCTAssertTrue([result isKindOfClass:[NSString class]]);
    } error:^(NSError *error){
        [monitor signal];
        XCTAssertFalse(YES);
    }];
    
    [monitor wait];
}

- (void)testDoActionWithRequestObject
{
    TRVSMonitor *monitor = [[TRVSMonitor alloc] initWithExpectedSignalCount:1];
    
    NSDictionary *action = [NSMutableDictionary dictionaryWithDictionary:[[HTTPActionManager sharedInstance] actionWith:@"example-datatype-json"]];
    [action setValue:@"method" forKey:HTTP_METHOD_POST];
    [action setValue:@"contentType" forKey:ContentTypeApplicationJSON];
    
    HTTPRequestObject *object = [[HTTPRequestObject alloc] init];
    object.action = action;
    object.param = @{@"a": @"1", @"b": @"2"};
    
    [[HTTPActionManager sharedInstance] doActionWithRequestObject:object success:^(NSData *result){
        [monitor signal];
        XCTAssertNotNil(result);
        XCTAssertTrue([result isKindOfClass:[NSDictionary class]]);
    } error:^(NSError *error){
        [monitor signal];
        XCTAssertFalse(YES);
    }];
    
    [monitor wait];
}

- (void)testURLObjectWithRequstObject
{
    TRVSMonitor *monitor = [[TRVSMonitor alloc] initWithExpectedSignalCount:1];
    
    __block HTTPRequestObject *object = [[HTTPActionManager sharedInstance] doAction:@"example-datatype-json" param:nil body:nil header:nil success:^(NSData *result){
        [monitor signal];
        XCTAssertNotNil([[HTTPActionManager sharedInstance] URLObjectWithRequstObject:object]);
    } error:^(NSError *error){
        [monitor signal];
        XCTAssertFalse(YES);
    }];
    
    [monitor wait];
}

- (void)testMultipartFormData
{
    TRVSMonitor *monitor = [[TRVSMonitor alloc] initWithExpectedSignalCount:1];
    
    UIImage *image = [[UIImage alloc] init];
    NSData *data = UIImagePNGRepresentation(image);
    
    MultipartFormDataObject *object = [MultipartFormDataObject objectWithFilename:@"sample.png" data:data];
    
    [[HTTPActionManager sharedInstance] doAction:@"example-multipart" param:nil body:object header:nil success:^(NSData *result){
        [monitor signal];
        XCTAssertNotNil(result);
        XCTAssertNotNil([NSString stringWithData:result]);
    } error:^(NSError *error){
        [monitor signal];
    }];
    
    [monitor wait];
}
@end
