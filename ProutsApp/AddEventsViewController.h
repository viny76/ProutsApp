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
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD.h"

@interface AddEventsViewController : UIViewController <AVAudioRecorderDelegate>

@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) NSArray *friendsList;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *sendEventButton;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (nonatomic, retain) AVAudioRecorder *audioRecorder;
@property (nonatomic, weak) IBOutlet UIButton *recordSoundButton;
@property (nonatomic, weak) IBOutlet UIButton *sendSoundButton;
@property (nonatomic, weak) IBOutlet UIButton *stopSoundButton;
@property (nonatomic, strong) AVAudioSession *audioSession;
@property (nonatomic, strong) NSData *datasound;
@property BOOL stopped;

@end
