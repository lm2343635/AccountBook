//
//  AddAccountViewController.h
//  GroupFinance
//
//  Created by lidaye on 5/22/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddAccountViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *anameTextField;

- (IBAction)save:(id)sender;

@end
