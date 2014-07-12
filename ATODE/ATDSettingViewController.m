//
//  ATDSettingViewController.m
//  ATODE
//
//  Created by himara2 on 2014/07/12.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "ATDSettingViewController.h"
#import "ATDCoreDataManger.h"

@interface ATDSettingViewController ()
<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end


@implementation ATDSettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}


#pragma mark -
#pragma mark IBAction

- (IBAction)closeBtnTouched:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -
#pragma mark UITableViewDelegate / DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeleteCell"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // データ削除
    [self resetMemoData];
}


- (void)resetMemoData {
    [[ATDCoreDataManger sharedInstance] resetSaveData];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"データを削除しました"
                                                     message:@""
                                                    delegate:nil
                                           cancelButtonTitle:nil otherButtonTitles:@"OK", nil
                           ];
    [alert show];
}

@end
