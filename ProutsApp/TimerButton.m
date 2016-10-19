//
//  TimerButton.m
//  ProutsApp
//
//  Created by Vincent Jardel on 19/10/2016.
//  Copyright © 2016 Vincent Jardel. All rights reserved.
//

#import "TimerButton.h"

@implementation TimerButton

#define DEGREES_TO_RADIANS(degrees)  ((3.14159265359 * degrees)/ 180)
#define TIMER_STEP .01

@synthesize currentAngle;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        currentAngle = 0;
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath* aPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(50, 50)
                                                         radius:45
                                                     startAngle:DEGREES_TO_RADIANS(0)
                                                       endAngle:DEGREES_TO_RADIANS(currentAngle)
                                                      clockwise:YES];
    [[UIColor redColor] setStroke];
    aPath.lineWidth = 5;
    [aPath stroke];
}

-(void)startTimerWithTimeLimit:(int)tl
{
    timerLimit = tl;
    timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_STEP target:self selector:@selector(updateTimerButton:) userInfo:nil repeats:YES];
}

-(void)stopTimer
{
    [timer invalidate];
}

-(void)updateTimerButton:(NSTimer *)timer
{
    currentTime += TIMER_STEP;
    currentAngle = (currentTime/timerLimit) * 360;
    
    if(currentAngle >= 360) [self stopTimer];
    [self setNeedsDisplay];
}

@end
