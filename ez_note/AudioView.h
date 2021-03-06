//
//  AudioView.h
//  try_20150719_audioView
//
//  Created by Yiheng Ding on 7/19/15.
//  Copyright (c) 2015 Yiheng Ding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "EZView.h"

@interface AudioView : EZView<AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *AudioButton;
@property (weak, nonatomic) IBOutlet UILabel *AudioLabel;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;

@property NSURL *outputFileURL;

- (void) addsubviewFromNib;
- (UIView *) viewFromNib;
- (instancetype)initWithFactorySettings:(NSDictionary *)settings url:(NSURL *)url;

//function methods
- (void) startRecording;
- (void) stopRecording;
- (void) startPlaying;
- (void) stopPlaying;
- (void) pauseRecording;
- (void) resumeRecording;

//timer methods
- (void) timerResponse;
- (void) updateSlierTime;

//trying the github
//trying the hahaha
//last try


@end
