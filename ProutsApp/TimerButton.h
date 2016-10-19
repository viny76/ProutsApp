//
//  TimerButton.h
//  ProutsApp
//
//  Created by Vincent Jardel on 19/10/2016.
//  Copyright © 2016 Vincent Jardel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimerButton : UIView
{
    float currentAngle;
    float currentTime;
    float timerLimit;
    NSTimer *timer;
}

@property float currentAngle;

-(void)stopTimer;
-(void)startTimerWithTimeLimit:(int)tl;

@end
