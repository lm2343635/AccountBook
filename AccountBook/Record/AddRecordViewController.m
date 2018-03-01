//
//  AddRecordViewController.m
//  GroupFinance
//
//  Created by lidaye on 5/29/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import "AddRecordViewController.h"
#import "SelectRecordItemTableViewController.h"
#import "DateTool.h"
#import "DateSelectorView.h"
#import "UIViewController+Extension.h"
#import "DaoManager.h"
#import "Grouper.h"

@interface AddRecordViewController ()

@end

@implementation AddRecordViewController {
    DaoManager *dao;
    Grouper *grouper;

    NSUInteger selectItemType;
    BOOL saveRecordType;
    
    UIImagePickerController *imagePickerController;
    DateSelectorView *dateSelector;
}

- (void)viewDidLoad {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    dao = [DaoManager sharedInstance];
    grouper = [Grouper sharedInstance];
    
    imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    saveRecordType = NO;
    [self setTime:[[NSDate alloc] init]];
}

- (void)viewWillAppear:(BOOL)animated {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (_item != nil) {
        switch (selectItemType) {
            case SELECT_ITEM_TYPE_CLASSIFICATION:
                _selectedClassification = (Classification *)_item;
                [_selectClassificationButton setTitle:_selectedClassification.cname
                                             forState:UIControlStateNormal];
                break;
            case SELECT_ITEM_TYPE_ACCOUNT:
                _selectedAccount = (Account *)_item;
                [_selectAccountButton setTitle:_selectedAccount.aname
                                      forState:UIControlStateNormal];
                break;
            case SELECT_ITEM_TYPE_SHOP:
                _selectedShop = (Shop *)_item;
                [_selectShopButton setTitle:_selectedShop.sname
                                   forState:UIControlStateNormal];
                break;
            default:
                break;
        }
    }
    if (_template != nil) {
        saveRecordType = _template.saveRecordType.boolValue;
        [_saveTypeSwitch setOn:saveRecordType];
        _saveTypeLabel.text = saveRecordType? @"Save as Earn": @"Save as Spend";
        _selectedClassification = _template.classification;
        [_selectClassificationButton setTitle:_selectedClassification.cname
                                     forState:UIControlStateNormal];
        _selectedAccount = _template.account;
        [_selectAccountButton setTitle:_selectedAccount.aname
                              forState:UIControlStateNormal];
        _selectedShop = _template.shop;
        [_selectShopButton setTitle:_selectedShop.sname
                           forState:UIControlStateNormal];
    }
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class,NSStringFromSelector(_cmd));
    }
    if (textView == _remarkTextView) {
        CGRect frame = textView.frame;
        int offset = frame.origin.y + textView.frame.size.height - (self.view.frame.size.height - KeyboardHeight);
        NSTimeInterval animationDuration = 0.30f;
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        // Move y up to show keyboard.
        if(offset > 0) {
            self.view.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);
        }
        [UIView commitAnimations];
        _remarkOK.hidden = NO;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class,NSStringFromSelector(_cmd));
    }
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
        NSLog(@"MediaInfo: %@",info);
    }
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        _photoImage = [info objectForKey:UIImagePickerControllerEditedImage];
        [_takePhotoButton setImage:_photoImage forState:UIControlStateNormal];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    UIViewController *controller = [segue destinationViewController];
    if ([segue.identifier isEqualToString:@"selectRecordItemSegue"]) {
        [controller setValue:[NSNumber numberWithInteger:selectItemType] forKey:@"selectItemType"];
    } else if ([segue.identifier isEqualToString:@"saveAsTemplateSegue"]) {
        [controller setValue:[NSNumber numberWithBool:saveRecordType] forKey:@"recordType"];
        [controller setValue:_selectedClassification forKey:@"selectedClassification"];
        [controller setValue:_selectedAccount forKey:@"selectedAccount"];
        [controller setValue:_selectedShop forKey:@"selectedShop"];
    }
}

#pragma mark - Action
- (IBAction)save:(id)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (_selectedAccount == nil || _selectedClassification == nil || _selectedShop == nil||
       [_moneyTextFeild.text isEqualToString:@""]) {
        [self showTip:@"Money, classification, account or shop is empty."];
        return;
    }
    
    int moneyInt = (int)_moneyTextFeild.text.doubleValue;
    NSNumber *money = [NSNumber numberWithInt: saveRecordType==YES ? moneyInt: -moneyInt];
    Photo *photo = nil;
    
    // Create new photo object if user has taken a photo.
    if (_photoImage != nil) {
        NSManagedObjectID *pid = [dao.photoDao saveWithData:UIImageJPEGRepresentation(_photoImage, 1.0)];
        if (DEBUG) {
            NSLog(@"Create photo with pid = %@", pid);
        }
        photo = (Photo *)[dao getObjectById:pid];
    }
    
    // Save record to app local persistent store.
    Record *record = [dao.recordDao saveWithMoney:money
                                           remark:_remarkTextView.text
                                             time:_selectedTime
                                   classification:_selectedClassification
                                          account:_selectedAccount
                                             shop:_selectedShop
                                            photo:photo];
    
    // Invoke update method in sender to send an update message.
    [grouper.sender update:record];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)selectClassification:(id)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    _item = nil;
    selectItemType = SELECT_ITEM_TYPE_CLASSIFICATION;
    [self performSegueWithIdentifier:@"selectRecordItemSegue" sender:self];
}

- (IBAction)selectAccount:(id)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    _item = nil;
    selectItemType = SELECT_ITEM_TYPE_ACCOUNT;
    [self performSegueWithIdentifier:@"selectRecordItemSegue" sender:self];
}

- (IBAction)selectShop:(id)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    _item = nil;
    selectItemType = SELECT_ITEM_TYPE_SHOP;
    [self performSegueWithIdentifier:@"selectRecordItemSegue" sender:self];
}

- (IBAction)selectTime:(id)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    _selectTimeButton.enabled = NO;
    dateSelector = [[DateSelectorView alloc] initForController:self done:^(NSDate *date) {
        _selectTimeButton.enabled = YES;
        [self setTime:date];
    }];
    [dateSelector show];
    
}

- (IBAction)takePhoto:(id)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Choose Photo from"
                                                                           message:nil
                                                                    preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                         style:UIAlertActionStyleCancel
                                                       handler:nil];
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Camera"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                                                               // Set source type to camera.
                                                               imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                               // Set mode to taking photo
                                                               imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
                                                               // Use rear camera
                                                               imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
                                                               // Allow editing
                                                               imagePickerController.allowsEditing = YES;
                                                           } else {
                                                               if (DEBUG) {
                                                                   NSLog(@"Warning: iOS Simulator cannot open camera.");
                                                               }
                                                               [self showWarning:@"iOS Simulator cannot open camera."];
                                                           }
                                                           // Show picker view controller.
                                                           [self presentViewController:imagePickerController animated: YES completion:nil];
                                                       }];
    UIAlertAction *libraryAction = [UIAlertAction actionWithTitle:@"Photo Library"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            // Set source type to photo library.
                                                            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                            imagePickerController.allowsEditing = YES;
                                                            // Show picker view controller.
                                                            [self presentViewController:imagePickerController animated: YES completion:nil];
                                                        }];
    [alertController addAction:cancelAction];
    [alertController addAction:cameraAction];
    [alertController addAction:libraryAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)changeSaveType:(id)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if ([sender isOn]) {
        saveRecordType = YES;
        _saveTypeLabel.text = @"Save as Earn";
    } else {
        saveRecordType = NO;
        _saveTypeLabel.text = @"Save as Spend";
    }
}

- (IBAction)finishEditRemark:(id)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    [_remarkTextView resignFirstResponder];
    _remarkOK.hidden = YES;
}

- (IBAction)saveAsTemplate:(id)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    if (_selectedAccount == nil || _selectedClassification == nil || _selectedShop == nil) {
        [self showWarning:@"Classification, account or shop is empty!"];
        return;
    }
    [self performSegueWithIdentifier:@"saveAsTemplateSegue" sender:self];
}

#pragma mark - Service
- (void)setTime:(NSDate *)time {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    _selectedTime = time;
    _selectTimeButton.enabled = YES;
    [_selectTimeButton setTitle:[DateTool formateDate:_selectedTime withFormat:DateFormatYearMonthDayHourMinutes]
                       forState:UIControlStateNormal];
}

@end
