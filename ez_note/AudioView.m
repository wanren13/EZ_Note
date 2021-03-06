//
//  AudioView.m
//  try_20150719_audioView
//
//  Created by Yiheng Ding on 7/19/15.
//  Copyright (c) 2015 Yiheng Ding. All rights reserved.
//

#import "AudioView.h"

@implementation AudioView{
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    float recordTimeLimit;
    NSTimer *responseTimer;
    NSTimer *updateTimer;
    BOOL isNewAudio;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
//

- (id) getOutput{
    if(!recorder){
        return player.url;
    }
    return recorder.url;
}

- (UIView *)viewFromNib{
    Class class = [self class];
    NSString *nibName = NSStringFromClass(class);
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
    UIView *view = [nibViews objectAtIndex:0];
    return view;
}

- (void) addsubviewFromNib
{
    UIView *view = [self viewFromNib];
    view.frame = self.bounds;
    //NSLog(@"%f %f %f %f",self.bounds.origin.x,self.bounds.origin.y,self.bounds.size.width,self.bounds.size.height);
    
    [self addSubview:view];
}

- (instancetype)initWithFactorySettings:(NSDictionary *)settings url:(NSURL *)url{
    self = [super initWithFrame: CGRectMake(0, 0, [settings[@"width"] floatValue], [settings[@"height"] floatValue])];
    
    if(self){
        
        
        
        [self addsubviewFromNib];
        [self.AudioButton setTitle:settings[@"title"] forState:UIControlStateNormal];
        self.AudioLabel.text = @"0:00:00";
        self.progressSlider.value = 0.0f;
        recordTimeLimit = [settings[@"timeLimit"] floatValue];
        
        //time stamp for naming the record
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
        NSString *todayString=[dateFormatter stringFromDate:[NSDate date]];
        
        NSString *todayStamp = [todayString stringByAppendingString:@".m4a"];
        NSLog(@"%@",todayStamp);
        NSArray *pathComponents = [NSArray arrayWithObjects:
                                   [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                   todayStamp,
                                   nil];
        
        if(url){
            self.outputFileURL = url;
            [self.AudioButton setTitle:@"Play" forState:UIControlStateNormal];
//            isNewAudio
        }else{
            self.outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
            recorder = [[AVAudioRecorder alloc] initWithURL:self.outputFileURL settings:settings[@"recordSetting"] error:nil];
            recorder.delegate = self;
            recorder.meteringEnabled = YES;
            
            [recorder prepareToRecord];
        }
        
        

//        NSLog(@"2.%@", self.outputFileURL);
        //this background color is not subview's background color, don't mess up
        self.backgroundColor = settings[@"backgroundColor"];
        
        // Initiate and prepare the recorder
//        recorder = [[AVAudioRecorder alloc] initWithURL:self.outputFileURL settings:settings[@"recordSetting"] error:nil];
//        recorder.delegate = self;
//        recorder.meteringEnabled = YES;
//        
//        [recorder prepareToRecord];
//        }

        
        
        //set up timer
        responseTimer = [[NSTimer alloc] init];
        updateTimer = [[NSTimer alloc] init];
        
    }
    return self;
}

- (IBAction)buttonPressed:(id)sender {
    if (recorder.recording) {
        [self stopRecording];
    }
    else{
        if (player.playing) {
            NSLog(@"playing!!");
            [self stopPlaying];
        }
        else{
            [self startPlaying];
        }
    }
}

- (void) stopTimer: (NSTimer *)timer{
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

- (void) timerResponse{
    
    //time format hh:mm:ss
    NSDateComponentsFormatter *formatter = [[NSDateComponentsFormatter alloc] init];
    formatter.allowedUnits = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    formatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
    //NSString *string = [formatter stringFromTimeInterval:recorder.currentTime];
    
    if (recorder.recording) {
        if (recorder.currentTime < recordTimeLimit) {
            //self.AudioLabel.text = [[NSString stringWithFormat:@"%.0f",recorder.currentTime] stringByAppendingString:@"s"];
            self.AudioLabel.text = [formatter stringFromTimeInterval:recorder.currentTime];
        }
        else{
            [self stopRecording];
        }
        
    }
    else if (player.playing){
        //self.AudioLabel.text = [[NSString stringWithFormat:@"%.0f",player.currentTime] stringByAppendingString:@"s"];
        self.AudioLabel.text = [formatter stringFromTimeInterval:player.currentTime];
    }
}

- (void) startRecording{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    
    [recorder record];
    [self.AudioButton setTitle:@"Recording" forState:UIControlStateNormal];
    
    // set a timer
    responseTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerResponse) userInfo:nil repeats:YES];
    
    // notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"startRecording" object:self userInfo:nil];
    
}

- (void) stopRecording{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:NO error:nil];
    
    [recorder stop];
    [self.AudioButton setTitle:@"Play" forState:UIControlStateNormal];
    self.AudioLabel.text = @"0:00:00";
    
    // notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopRecording" object:self userInfo:nil];
    
    // stop response timer
    [self stopTimer:responseTimer];
}

- (void) startPlaying{
    if (!recorder.recording){
        NSError *error;
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.outputFileURL fileTypeHint:AVFileTypeAppleM4A error:&error];
        if(!player){
            NSLog(@"Error: %@",error);
        }

        
        [player setDelegate:self];
        [player prepareToPlay];
        [self.AudioButton setTitle:@"Playing" forState:UIControlStateNormal];
        
        //set up the responsetimer
        self.AudioLabel.text = @"0:00:00";
        responseTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerResponse) userInfo:nil repeats:YES];
        
        //notification
        [[NSNotificationCenter defaultCenter] postNotificationName:@"startPlaying" object:self userInfo:nil];
        
        //set up the progressSlider
        self.progressSlider.maximumValue = [player duration];
        float progress = [player duration] / 100;
        updateTimer = [NSTimer scheduledTimerWithTimeInterval:progress target:self selector:@selector(updateSlierTime) userInfo:nil repeats:YES];
        
        
        //start play
        [player play];
    }
}

- (void) updateSlierTime{
    if (player.playing) {
        self.progressSlider.value = player.currentTime;
    }
}

- (IBAction)progressSliderMoved:(id)sender {
    if (player.playing) {
        player.currentTime = self.progressSlider.value;
    }
}


- (void) stopPlaying{
    [player stop];
    [self.AudioButton setTitle:@"Play" forState:UIControlStateNormal];
    self.AudioLabel.text = @"0:00:00";
    
    // nitification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopPlaying" object:self userInfo:nil];
    
    // resumre the progressslider
    self.progressSlider.value = 0.0f;
    
    // stop updatetimer and responsetimer
    [self stopTimer:updateTimer];
    [self stopTimer:responseTimer];
}


- (void) pauseRecording{
    [recorder pause];
    [self.AudioButton setTitle:@"Pause" forState:UIControlStateNormal];
    
    // nitification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pauseRecording" object:self userInfo:nil];
}

- (void) resumeRecording{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [recorder record];
    [self.AudioButton setTitle:@"Recording" forState:UIControlStateNormal];
    
    // notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"resumeRecording" object:self userInfo:nil];
}

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [self stopPlaying];
    
    // notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopPlaying" object:self userInfo:nil];
    
    // resumre the progressslider
    self.progressSlider.value = 0.0f;
    
    // stop updateTimer
    [self stopTimer:updateTimer];
    [self stopTimer:responseTimer];    
}

- (void)dealloc {
    player = nil;
}


@end
