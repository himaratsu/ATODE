//
//  UIViewController+GAInject.m
//  ATODE
//
//  Created by himara2 on 2014/07/30.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "UIViewController+GAInject.h"
#import "GAI.h"
#import "GAIFields.h"
#import <objc/runtime.h>

@implementation UIViewController (GAInject)

- (void)replacedViewDidAppear:(BOOL)animated
{
    // 元のメソッド（名前は既に置き換わっているので注意）を呼び出す
    [self replacedViewDidAppear:animated];
    
    // クラスをトラックする
    NSLog(@"GA track:[%@]", NSStringFromClass([self class]));
    
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName
                                       value:NSStringFromClass([self class])];
}

+ (void)exchangeMethod
{
    [self exchangeInstanceMethodFrom:@selector(viewDidAppear:) to:@selector(replacedViewDidAppear:)];
}

/**
 メソッドの入れ替え
 */
+ (void)exchangeInstanceMethodFrom:(SEL)from to:(SEL)to
{
    Method fromMethod = class_getInstanceMethod(self, from);
    Method toMethod   = class_getInstanceMethod(self, to);
    method_exchangeImplementations(fromMethod, toMethod);
}

@end
