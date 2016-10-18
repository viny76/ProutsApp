//
//  ViewController.m
//  ChillN
//
//  Created by Vincent Jardel on 26/03/2015.
//  Copyright (c) 2015 ChillCompany. All rights reserved.
//

#import "AddEventsViewController.h"
#import <SevenSwitch.h>
#import "ShowFriendViewController.h"

@interface AddEventsViewController () <UIAlertViewDelegate, UITextFieldDelegate, HSDatePickerViewControllerDelegate>
@end

@implementation AddEventsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.sendButton sizeToFit];
    self.mySwitch.on = YES;
}
- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    return (newLength > 30) ? NO : YES; // 30 is custom value. you can use your own.
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    textField.textAlignment = NSTextAlignmentLeft;
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"OK" style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyboard)];
    self.navigationItem.rightBarButtonItem = rightButton;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    textField.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.rightBarButtonItem = self.sendEventButton;
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)showDatePicker:(id)sender {
    HSDatePickerViewController *hsdpvc = [HSDatePickerViewController new];
    hsdpvc.delegate = self;
    [self presentViewController:hsdpvc animated:YES completion:nil];
}

// DATE PICKER
#pragma mark - HSDatePickerViewControllerDelegate
- (void)hsDatePickerPickedDate:(NSDate *)date {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    
    // Add the following line to display the time in the local time zone
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm"];
    NSString* finalTime = [dateFormatter stringFromDate:date];
    [self.dateButton setTitle:[dateFormatter stringFromDate:date] forState:UIControlStateNormal];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    self.selectedDate = [dateFormatter dateFromString:finalTime];
}

//optional
- (void)hsDatePickerDidDismissWithQuitMethod:(HSDatePickerQuitMethod)method {
    //    NSLog(@"Picker did dismiss with %lu", (unsigned long)method);
}

//optional
- (void)hsDatePickerWillDismissWithQuitMethod:(HSDatePickerQuitMethod)method {
    //  NSLog(@"Picker will dismiss with %lu", (unsigned long)method);
}

- (BOOL)verifications {
    BOOL ok = YES;
    
    // Check Question
    if (self.questionTextField.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localized(@"ERROR") message:Localized(@"Question is empty") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        alert.tag = 100;
        [alert show];
        ok = NO;
    }
    
    // Check Date
    else if ([self.dateButton.titleLabel.text isEqualToString:@"Choisir Date"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localized(@"ERROR") message:Localized(@"Select Date") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        alert.tag = 101;
        [alert show];
        ok = NO;
    }
    
    return ok;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 100) {
        if (buttonIndex == 0) {
            [self.questionTextField becomeFirstResponder];
        }
    }
    else if (alertView.tag == 101) {
        if (buttonIndex == 0) {
            [self showDatePicker:self.dateButton];
        }
    }
}

- (IBAction)sendEvent:(id)sender {
    if ([self verifications]) {
        [self performSegueWithIdentifier:@"showFriend" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showFriend"]) {
        PFObject *events = [PFObject objectWithClassName:@"Events"];
        [events setObject:self.questionTextField.text forKey:@"question"];
        [events setObject:[NSNumber numberWithBool:[self.mySwitch isOn]] forKey:@"visibility"];
        [events setObject:self.selectedDate forKey:@"date"];
        if (self.address != nil) {
            [events setObject:[NSNumber numberWithDouble:self.address.coordinate.latitude] forKey:@"lat"];
            [events setObject:[NSNumber numberWithDouble:self.address.coordinate.longitude] forKey:@"long"];
        }
        
        ShowFriendViewController *showFriendController = [segue destinationViewController];
        showFriendController.currentUser = self.currentUser;
        showFriendController.friendsList = self.friendsList;
        showFriendController.eventObject = events;
    }
}


@end
