//
//  DemoActionViewController.h
//  w3action
//
//  Created by pisces on 4/29/16.
//  Copyright © 2016 pisces. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DemoActionType) {
    DemoActionTypeJSON = 1,
    DemoActionTypeXML,
    DemoActionTypeText,
    DemoActionTypePathParam,
    DemoActionTypeLoadImage
};

@interface DemoActionViewController : UIViewController
- (id)initWithType:(DemoActionType)type;
@end
