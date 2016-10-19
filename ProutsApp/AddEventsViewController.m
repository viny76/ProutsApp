//
//  ViewController.m
//  ChillN
//
//  Created by Vincent Jardel on 26/03/2015.
//  Copyright (c) 2015 ChillCompany. All rights reserved.
//

#import "AddEventsViewController.h"
#import "ShowFriendViewController.h"

@interface AddEventsViewController () <UIAlertViewDelegate>
@end

@implementation AddEventsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.sendButton sizeToFit];
    [self initMicrophone];
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

- (BOOL)verifications {
    BOOL ok = YES;
    
//     Check Sound
    if (self.datasound == nil) {
        ok = NO;
    }
//    if (self.datasound.text.length == 0) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localized(@"ERROR") message:Localized(@"Question is empty") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        alert.tag = 100;
//        [alert show];
//        ok = NO;
//    }
    
//    // Check Date
//    else if ([self.dateButton.titleLabel.text isEqualToString:@"Choisir Date"]) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localized(@"ERROR") message:Localized(@"Select Date") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        alert.tag = 101;
//        [alert show];
//        ok = NO;
//    }
    
    return ok;
}

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if (alertView.tag == 100) {
//        if (buttonIndex == 0) {
//            [self.questionTextField becomeFirstResponder];
//        }
//    }
//    else if (alertView.tag == 101) {
//        if (buttonIndex == 0) {
//            [self showDatePicker:self.dateButton];
//        }
//    }
//}

- (IBAction)sendEvent:(id)sender {
    if ([self verifications]) {
        [self performSegueWithIdentifier:@"showFriend" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showFriend"]) {
        PFObject *events = [PFObject objectWithClassName:@"Events"];
        [events setObject:[PFFile fileWithName:@"sound.caf" data:self.datasound] forKey:@"soundFile"];
        
        ShowFriendViewController *showFriendController = [segue destinationViewController];
        showFriendController.currentUser = self.currentUser;
        showFriendController.friendsList = self.friendsList;
        showFriendController.eventObject = events;
    }
}

#pragma mark - AUDIO RECORDER
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
        NSData *data = [NSData dataWithContentsOfURL:recorder.url];
        [self sendAudioToServer:data];
}
- (IBAction)startRec:(KYShutterButton *)sender {
    if (sender.buttonState == ButtonStateNormal) {
        sender.buttonState = ButtonStateRecording;
        [self.audioRecorder record];
    } else if (sender.buttonState == ButtonStateRecording) {
        sender.buttonState = ButtonStateNormal;
        [self.audioRecorder stop];
    }
}

- (BOOL)sendAudioToServer:(NSData *)data {
    self.datasound = [NSData dataWithData:data];
    return YES;
}

- (void)initMicrophone {
    //RECORD AUDIO
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *soundFilePath = [docsDir
                               stringByAppendingPathComponent:@"tempsound.caf"];
    
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
    [[AVAudioSession sharedInstance] setMode:AVAudioSessionModeVideoRecording error:nil];
    NSDictionary *recordSettings =
    [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:AVAudioQualityMin],
     AVEncoderAudioQualityKey, [NSNumber numberWithInt: 1], AVNumberOfChannelsKey, [NSNumber numberWithFloat:22050.0], AVSampleRateKey, nil];
    
    NSError *error = nil;
    
    self.audioRecorder = [[AVAudioRecorder alloc]
                          initWithURL:soundFileURL
                          settings:recordSettings
                          error:nil];
    self.audioRecorder.delegate = self;
    if (error) {
        NSLog(@"error: %@", [error localizedDescription]);
    } else {
        [self.audioRecorder prepareToRecord];
    }
}

@end
