//
//  SettingsTableViewController.m
//  GroupFinance
//
//  Created by lidaye on 25/09/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "DaoManager.h"
#import "UIViewController+Extension.h"
#import "Grouper.h"

@interface SettingsTableViewController ()

@end

@implementation SettingsTableViewController {
    Grouper *grouper;
    DaoManager *dao;
}

- (void)viewDidLoad {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];

    dao = [DaoManager sharedInstance];
    grouper = [Grouper sharedInstance];
}

- (void)viewWillAppear:(BOOL)animated {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewWillAppear:animated];
    
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }

}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (grouper.group.defaults.groupId == nil &&
        ([identifier isEqualToString:@"templatesSegue"] || [identifier isEqualToString:@"classificationsSegue"]
         || [identifier isEqualToString:@"shopsSegue"] || [identifier isEqualToString:@"accountsSegue"])) {
        [self showTip:@"Join or create a group at first!"];
        return NO;
    }
    return YES;
}

#pragma mark - Table view data source
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    //Clear header view color
    UIView *headerView = [[UIView alloc] init];
    [headerView setBackgroundColor:[UIColor clearColor]];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return 0.1;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.reuseIdentifier == nil) {
        return;
    }
    if ([cell.reuseIdentifier isEqualToString:@"members"]) {
        NSBundle *podBundle = [NSBundle bundleForClass:Grouper.self];
        NSBundle *bundle = [NSBundle bundleWithURL:[podBundle URLForResource:@"Grouper" withExtension:@"bundle"]];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Members" bundle:bundle];
        [self presentViewController:[storyboard instantiateInitialViewController] animated:true completion:nil];
    } else if ([cell.reuseIdentifier isEqualToString:@"clear"]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Clear Share ID Cache"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *clear = [UIAlertAction actionWithTitle:@"Clear Now!"
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction * _Nonnull action)
        {
            [grouper.group clearShareId];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                         style:UIAlertActionStyleCancel
                                                       handler:nil];
        [alert addAction:clear];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    } else if ([cell.reuseIdentifier isEqualToString:@"confirm"]) {
        [grouper.sender confirm];
        [self showTip:@"Confirm message has been sent."];
    }

}

@end
