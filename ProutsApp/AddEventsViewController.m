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
int count;
NSTimer *timer;

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
    
    return ok;
}

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
    if (timer) {
        [timer invalidate];
    }
    if (sender.buttonState == ButtonStateNormal) {
        count = 10;
        sender.buttonState = ButtonStateRecording;
        [self.audioRecorder record];
        [self.circleProgressBar setProgress:100 animated:YES duration:5.0f];
        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    } else if (sender.buttonState == ButtonStateRecording) {
        count = 0;
        sender.buttonState = ButtonStateNormal;
        [self.audioRecorder stop];
        [self.circleProgressBar stopAnimation];
        [self.circleProgressBar setProgress:0 animated:NO];
    }
}

- (void)updateTime {
    NSLog(@"updateTime");
    if (count > 0) {
        count--;
        NSLog(@"%d", count);
        NSLog(@"yeah");
    } else {
        [timer invalidate];
        self.recordSoundButton.buttonState = ButtonStateNormal;
        [self.audioRecorder stop];
        [self.circleProgressBar stopAnimation];
        [self.circleProgressBar setProgress:0 animated:NO];
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
