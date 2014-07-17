//
//  ATDEditMemoViewController.m
//  ATODE
//
//  Created by 平松　亮介 on 2014/07/17.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "ATDEditMemoViewController.h"
#import "ATDCoreDataManger.h"
#import <UIAlertView+Blocks/UIAlertView+Blocks.h>

@interface ATDEditMemoViewController ()
<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end


@implementation ATDEditMemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _textView.text = _memo.title;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_textView becomeFirstResponder];
}

- (IBAction)doneBtnTouched:(id)sender {
    [self updateMemoTitle];
}

- (void)updateMemoTitle {
    NSString *newTitle = _textView.text;
    PlaceMemo *newMemo = [[ATDCoreDataManger sharedInstance] updateMemo:_memo title:newTitle];
    
    if ([_delegate respondsToSelector:@selector(didChangeMemo:)]) {
        [_delegate didChangeMemo:newMemo];
    }
    
    [UIAlertView showWithTitle:@"Success"
                       message:@"メモの更新に成功しました"
             cancelButtonTitle:nil
             otherButtonTitles:@[@"OK"]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (buttonIndex != alertView.cancelButtonIndex) {
                              [self.navigationController popViewControllerAnimated:YES];
                          }
                      }];
}


#pragma mark -
#pragma mark UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        [self updateMemoTitle];
        return NO;
    }
    return YES;
}


@end
