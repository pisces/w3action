//
//  DemoActionViewController.m
//  w3action
//
//  Created by pisces on 4/29/16.
//  Copyright © 2016 pisces. All rights reserved.
//

#import "DemoActionViewController.h"
#import "w3action.h"

@interface DemoActionViewController ()
@property (nonatomic) DemoActionType type;
@property (nonatomic, readonly) NSString *action;
@end

@implementation DemoActionViewController
{
    __weak IBOutlet UITextView *textView;
    __weak IBOutlet UIActivityIndicatorView *activityIndicatorView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (id)initWithType:(DemoActionType)type {
    self = [super initWithNibName:@"DemoActionView" bundle:[NSBundle mainBundle]];
    
    if (self) {
        self.type = type;
    }
    
    return self;
}

- (NSString *)action {
    if (_type == DemoActionTypeJSON)
        return @"example-datatype-json";
    if (_type == DemoActionTypeXML)
        return @"example-datatype-xml";
    if (_type == DemoActionTypeText)
        return @"example-datatype-text";
    return nil;
}

- (void)setType:(DemoActionType)type {
    if (type == _type)
        return;
    
    _type = type;
    activityIndicatorView.hidden = NO;
    
    [activityIndicatorView startAnimating];
    
    [[HTTPActionManager sharedInstance] doAction:self.action param:nil body:nil headers:nil success:^(id  _Nullable result) {
        activityIndicatorView.hidden = YES;
        [activityIndicatorView stopAnimating];
        
        id resultDescription = [result isKindOfClass:[APDocument class]] ? ((APDocument *) result).prettyXML : result;
        textView.text = [NSString stringWithFormat:@"Success!!\n\nResult Class -> \"%@\"\n\ntoString ->\n\"%@\"", NSStringFromClass([result class]), resultDescription];
        
    } error:^(NSError * _Nullable error) {
        activityIndicatorView.hidden = YES;
        [activityIndicatorView stopAnimating];
        
        textView.text = [NSString stringWithFormat:@"Error -> %@", error];
    }];
    
}

@end
