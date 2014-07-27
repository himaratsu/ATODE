//
//  ATDSettingViewController.m
//  ATODE
//
//  Created by himara2 on 2014/07/12.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "ATDSettingViewController.h"
#import "ATDCoreDataManger.h"
#import <UIActionSheet+Blocks/UIActionSheet+Blocks.h>

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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    else if (section == 1) {
        return 5;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"メモの管理";
    }
    else if (section == 1) {
        return @"このアプリについて";
    }
    
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeleteCell"];
        return cell;
    }
    else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IndicatorCell"];
        switch (indexPath.row) {
            case kSettingCellTypeRequest:
                cell.textLabel.text = @"ご意見・ご要望";
                break;
            case kSettingCellTypeIntroduce:
                cell.textLabel.text = @"このアプリを友達に紹介する";
                break;
            case kSettingCellTypeReview:
                cell.textLabel.text = @"アプリのレビューを書く";
                break;
            case kSettingCellTypeLicense:
                cell.textLabel.text = @"ソフトウェア・ライセンス";
                break;
            case kSettingCellTypeVersion:
            {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
                cell.textLabel.text = @"アプリのバージョン";
                cell.detailTextLabel.text = [self getVersion];
                return cell;
            }
        }
        return cell;
    }
    
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            // データ削除
            [UIActionSheet showInView:self.view
                            withTitle:@"削除したデータは元に戻せません。よろしいですか？"
                    cancelButtonTitle:@"キャンセル"
               destructiveButtonTitle:@"データをすべて削除する"
                    otherButtonTitles:nil
                             tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                                 if (actionSheet.cancelButtonIndex != buttonIndex) {
                                     [self resetMemoData];
                                 }
                             }];
        }
    }
    else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case kSettingCellTypeIntroduce:
                // 友達に紹介する(Tw / Fb)
                break;
            case kSettingCellTypeRequest:
                // ご意見・ご要望（メール or Tw）
                break;
            case kSettingCellTypeReview:
                // レビュー
                break;
            case kSettingCellTypeLicense:
                // ライセンス
                break;
        }
    }
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


- (NSString *)getVersion {
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return version;
}


@end
