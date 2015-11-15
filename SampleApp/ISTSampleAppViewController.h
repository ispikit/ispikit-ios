//
//  ISTSampleAppViewController.h
//  SampleApp
//
//  Created by Sylvain Chevalier on 3/21/13.
//  Copyright (c) 2013-2015 Ispikit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVPlayer.h>
#import <AVFoundation/AVPlayerItem.h>
#import <AVFoundation/AVAudioSession.h>
#import <AudioToolbox/AudioToolbox.h>

@interface ISTSampleAppViewController : UIViewController <UITextFieldDelegate>
- (void) setInitDoneLabelWithStatus:(NSNumber *)status;
- (void) setCompletionLabelWithText:(NSString *)text;
- (void) setRecognizedLabelWithText:(NSString *)text;
- (void) setMispronouncedLabelWithText:(NSString *)text;
- (void) setScoreLabelWithText:(NSString *)text;
- (void) setSpeedLabelWithText:(NSString *)text;
@property (copy, nonatomic) NSString *currentSentence;
@end
