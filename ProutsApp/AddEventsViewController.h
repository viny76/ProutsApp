//
//  ViewController.h
//  ChillN
//
//  Created by Vincent Jardel on 26/03/2015.
//  Copyright (c) 2015 ChillCompany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"
#import "HSDatePickerViewController.h"

@class SevenSwitch;

@interface AddEventsViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) NSArray *friendsList;
@property (strong, nonatomic) IBOutlet UITextField *questionTextField;
@property (strong, nonatomic) IBOutlet UIButton *dateButton;
@property (strong, nonatomic) IBOutlet SevenSwitch *mySwitch;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *sendEventButton;
@property (strong, nonatomic) NSString *questionString;
@property (strong, nonatomic) NSDate *selectedDate;
@property (strong, nonatomic) IBOutlet UIView *otherDetailsView;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (nonatomic, strong) CLLocation *address;

@end
