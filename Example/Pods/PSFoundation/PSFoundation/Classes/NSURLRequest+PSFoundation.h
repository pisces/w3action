//
//  NSURLRequest+PSFoundation.h
//  PSFoundation
//
//  Created by Steve Kim on 2015. 4. 8..
//  Copyright (c) 2013 ~ 2016 Steve Kim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLRequest (PSFoundation_NSURLRequest)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host;
@end
