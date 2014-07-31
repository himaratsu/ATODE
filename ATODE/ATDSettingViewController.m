//
//  ATDSettingViewController.m
//  ATODE
//
//  Created by himara2 on 2014/07/12.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "ATDSettingViewController.h"
#import "ATDCoreDataManger.h"
#import "LicenseViewController.h"
#import "ATDTutorialView.h"
#import <UIActionSheet+Blocks/UIActionSheet+Blocks.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <Social/Social.h>
#import <sys/sysctl.h>
#import "GAIDictionaryBuilder.h"

@interface ATDSettingViewController ()
<UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end


@implementation ATDSettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUpFooterView];
}

- (void)setUpFooterView {
    UILabel *footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    footerLabel.text = @"Copyright (c) 2014 @himara2.";
    footerLabel.textColor = [UIColor lightGrayColor];
    footerLabel.textAlignment = NSTextAlignmentCenter;
    footerLabel.font = [UIFont systemFontOfSize:12.0f];
    footerLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(footerLabelTouched)];
    [footerLabel addGestureRecognizer:tapGesture];
    _tableView.tableFooterView = footerLabel;
}

- (void)footerLabelTouched {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:DEVELOPER_TWITTER_URL]];
}


#pragma mark -
#pragma mark IBAction

- (IBAction)closeBtnTouched:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -
#pragma mark UITableViewDelegate / DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    }
    else if (section == 1) {
        return 3;
    }
    else if (section == 2) {
        return 1;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(CONTACT_US, nil);
    }
    else if (section == 1) {
        return NSLocalizedString(ABOUT, nil);
    }
    else if (section == 2) {
        return NSLocalizedString(OTHER, nil);
    }
    
    return @"";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IndicatorCell"];
        switch (indexPath.row) {
            case kSettingRequestCellTypeRequest:
                cell.textLabel.text = NSLocalizedString(FEEDBACK_AND_COMMENT, nil);
                break;
            case kSettingRequestCellTypeIntroduce:
                cell.textLabel.text = NSLocalizedString(INTRODUCE_FRIENDS, nil);
                break;
            case kSettingRequestCellTypeReview:
                cell.textLabel.text = NSLocalizedString(WRITE_REVIEW, nil);
                break;
        }
        return cell;
    }
    else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IndicatorCell"];
        switch (indexPath.row) {
            case kSettingAboutCellTypeHowToUse:
                cell.textLabel.text = NSLocalizedString(HOW_TO_USE, nil);
                break;
            case kSettingAboutCellTypeLicense:
                cell.textLabel.text = NSLocalizedString(LICENSE, nil);
                break;
            case kSettingAboutCellTypeVersion:
            {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
                cell.textLabel.text = NSLocalizedString(VERSION, nil);
                cell.detailTextLabel.text = [self _appVersion];
                return cell;
            }
        }
        return cell;
    }
    else if (indexPath.section == 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeleteCell"];
        return cell;
    }
    
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case kSettingRequestCellTypeIntroduce:
                // 友達に紹介する(Tw / Fb)
                [self introduceFriends];
                break;
            case kSettingRequestCellTypeRequest:
                // ご意見・ご要望（メール or Tw）
                [self launchMail];
                break;
            case kSettingRequestCellTypeReview:
            {
                // レビュー
                id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ACTION"
                                                                      action:@"touch"
                                                                       label:@"go review"
                                                                       value:nil] build]];
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APP_STORE_URL]];
                break;
            }
        }
    }
    else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case kSettingAboutCellTypeHowToUse:
                // 使い方を見る
                [self showTutorial];
                break;
            case kSettingAboutCellTypeLicense:
            {
                // ライセンス
                LicenseViewController *vc = [LicenseViewController view];
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
        }
    }
    else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            // データ削除
            [UIActionSheet showInView:self.view
                            withTitle:NSLocalizedString(DELETE_CONFIRM, nil)
                    cancelButtonTitle:NSLocalizedString(CANCEL, nil)
               destructiveButtonTitle:@"データをすべて削除する"
                    otherButtonTitles:nil
                             tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                                 if (actionSheet.cancelButtonIndex != buttonIndex) {
                                     [self resetMemoData];
                                 }
                             }];
        }
    }
}



- (void)resetMemoData {
    [[ATDCoreDataManger sharedInstance] resetSaveData];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(DELETE_DONE, nil)
                                                     message:@""
                                                    delegate:nil
                                           cancelButtonTitle:nil otherButtonTitles:@"OK", nil
                           ];
    [alert show];
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ACTION"
                                                          action:@"touch"
                                                           label:@"delete all memo"
                                                           value:nil] build]];
}


#pragma mark -
#pragma mark Post to SNS

- (void)showTutorial {
    ATDTutorialView *view = [ATDTutorialView view];
    view.center = self.view.center;
    [view show];
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ACTION"
                                                          action:@"touch"
                                                           label:@"show tutorial"
                                                           value:nil] build]];
}

- (void)introduceFriends {
    [UIActionSheet showInView:self.view
                    withTitle:NSLocalizedString(INTRODUCE_FRIENDS, nil)
            cancelButtonTitle:NSLocalizedString(CANCEL, nil)
       destructiveButtonTitle:nil
            otherButtonTitles:@[NSLocalizedString(POST_TO_TWITTER, nil),
                                NSLocalizedString(POST_TO_FACEBOOK, nil),
                                NSLocalizedString(POST_TO_LINE, nil)]
                     tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                         if (actionSheet.cancelButtonIndex != buttonIndex) {
                             if (buttonIndex == 0) {
                                 [self postTwitter];
                             }
                             else if (buttonIndex == 1) {
                                 [self postFacebook];
                             }
                             else if (buttonIndex == 2) {
                                 [self postLINE];
                             }
                         }
                     }];
}

- (NSString *)createShareMessage {
    NSString *msg = [NSString stringWithFormat:@"%@ - %@",
                     NSLocalizedString(APP_DESCRIPTION, nil),
                     APP_STORE_URL];
    return msg;
}

- (void)postTwitter {
    SLComposeViewController *vc = [SLComposeViewController
                                   composeViewControllerForServiceType:SLServiceTypeTwitter];
    [vc setInitialText:NSLocalizedString(APP_DESCRIPTION, nil)];
    [vc addURL:[NSURL URLWithString:APP_STORE_URL]];
    [self presentViewController:vc animated:YES completion:nil];
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ACTION"
                                                          action:@"touch"
                                                           label:@"share twitter"
                                                           value:nil] build]];
}

- (void)postFacebook {
    SLComposeViewController *vc = [SLComposeViewController
                                   composeViewControllerForServiceType:SLServiceTypeFacebook];
    [vc setInitialText:NSLocalizedString(APP_DESCRIPTION, nil)];
    [vc addURL:[NSURL URLWithString:APP_STORE_URL]];
    [self presentViewController:vc animated:YES completion:nil];
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ACTION"
                                                          action:@"touch"
                                                           label:@"share facebook"
                                                           value:nil] build]];
}

- (void)postLINE {
    if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"line://"]]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedString(LINE_NOT_INSTALLED, nil)
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
        return;
    }
    
    // この例ではUIImageクラスの_resultImageを送る
    NSString *encodeMes = [self encodeStr:[self createShareMessage]];
    // URLスキームを使ってLINEを起動
    NSString *LineUrlString = [NSString stringWithFormat:@"line://msg/text/%@", encodeMes];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:LineUrlString]];
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ACTION"
                                                          action:@"touch"
                                                           label:@"share line"
                                                           value:nil] build]];
}


- (NSString *)encodeStr:(NSString *)str {
    NSString *escapedUrlString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                       NULL,
                                                                                                       (CFStringRef)str,
                                                                                                       NULL,
                                                                                                       (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                       kCFStringEncodingUTF8 ));
    return escapedUrlString;
}



#pragma mark -

/*
 * アプリ内でメールを立ち上げる
 */
-(void)launchMail
{
    
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setToRecipients:[NSArray arrayWithObject:SUPPORT_MAIL_ADDRESS]];
        mailViewController.title = @"";
        
        NSString *subjectStr = [NSString stringWithFormat:@"【Go Memo】%@", NSLocalizedString(CONTACT_US, nil)];
        [mailViewController setSubject:subjectStr];
        
        // マーケットに出ている場合
        NSString *body = @"【%@】\n\n\n\n※%@ \n-----\nDEVICE: %@\niOS: %@\nVERSION: %@\n";
        [mailViewController setMessageBody:[NSString stringWithFormat:body,
                                            NSLocalizedString(FEEDBACK_AND_COMMENT, nil),
                                            NSLocalizedString(DONT_CHANGE_BELOW, nil),
                                            [UIDevice currentDevice].systemVersion,
                                            [self _platformString],
                                            [self _appVersion]] isHTML:NO];
        
        [[mailViewController navigationBar] setTintColor:[UIColor whiteColor]];
        
        [self presentViewController:mailViewController animated:YES completion:nil];
    }
    
    else {
        UIAlertView *mailBoxAlert = [[UIAlertView alloc] initWithTitle:@"メール設定エラー"
                                                               message:@"端末にメールアカウント設定を行ってください。"
                                                              delegate:self
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles: nil];
        [mailBoxAlert show];
    }
}

- (NSString*)_appVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

- (NSString *) _platform
{
    int mib[2];
    size_t len;
    char *machine;
    
    mib[0] = 6;
    mib[1] = 1;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    machine = malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    return platform;
}

- (NSString *) _platformString
{
    NSString *platform = [self _platform];
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPod1,1"])  return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])  return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])  return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])  return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])  return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPad1,1"])  return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])  return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])  return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])  return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,5"])  return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])  return @"iPad Mini (GSM)";
    if ([platform isEqualToString:@"iPad2,7"])  return @"iPad Mini (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])  return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])  return @"iPad 3 (GSM)";
    if ([platform isEqualToString:@"iPad3,3"])  return @"iPad 3 (CDMA)";
    if ([platform isEqualToString:@"iPad4,1"])  return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad4,2"])  return @"iPad 4 (GSM)";
    if ([platform isEqualToString:@"iPad4,3"])  return @"iPad 4 (CDMA)";
    if ([platform isEqualToString:@"i386"])   return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"])  return @"iPhone Simulator";
    return platform;
}


/*
 * メール画面の「閉じる」ボタンを押したらメール画面を消す
 */
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    
    // 送信
    if (result == MFMailComposeResultSent) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(THANK_YOU, nil)
                                                            message:NSLocalizedString(WE_IMPROVE, nil)
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"OK", nil];
        [alertView show];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
