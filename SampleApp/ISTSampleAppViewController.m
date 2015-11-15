//
// Most of the implementation of the Sample App
// is in this file, it can be used as a reference
// to create other apps based on the ISTAnalyzer
//


#import "ISTSampleAppViewController.h"

// Import the ISTAnalyzer header file
#import "ISTAnalyzer.h"


@interface ISTSampleAppViewController ()

// These are actions attached to buttons:

// Initialization button
- (IBAction)initializeAnalyzer:(id)sender;

// Buttons to start/stop recording/playback
- (IBAction)startRecording:(id)sender;
- (IBAction)StopRecording:(id)sender;
- (IBAction)startReplay:(id)sender;
- (IBAction)stopReplay:(id)sender;

// Button to add word
- (IBAction)addWord:(id)sender;

// Properties associated to Text fields and labels

// Field to input sentence to be read
@property (weak, nonatomic) IBOutlet UITextField *sentencesField;

// Label that displays completion percentage during analysis
@property (weak, nonatomic) IBOutlet UILabel *completionLabel;

// Label that displays score after analysis
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;

// Label that displays speech tempo after analysis
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;

//Label that displays init status
@property (weak, nonatomic) IBOutlet UILabel *initializedLabel;

// Label that displays recognized words during recording
@property (weak, nonatomic) IBOutlet UILabel *recognizedLabel;

// Label that displays mispronounced words after analysis
@property (weak, nonatomic) IBOutlet UILabel *mispronouncedLabel;

// Text fields to input a new word (word and associated pronunciation)
@property (weak, nonatomic) IBOutlet UITextField *addWordField;
@property (weak, nonatomic) IBOutlet UITextField *addWordPronField;

@end

@implementation ISTSampleAppViewController {

    // The ISTAnalyzer is kept as an instance variable
    ISTAnalyzer* analyzer;
}

// Once view is loaded, we create an analyzer instance and
// create the blocks for callbacks
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Analyzer instance we'll be using
    analyzer = [ISTAnalyzer new];

    // Creating a weak ref to self to put in the blocks
    ISTSampleAppViewController * weakSelf = self;
    

    // When playback is done, we do nothing else than logging it here
    [analyzer setPlaybackDoneCallback:^(){
        NSLog(@"Playback done");
    }];
    

    // When Initialization is done, we update the labels in the view
    // Since it's called from another thread, you must use
    // performSelectorOnMainThread
    [analyzer setInitDoneCallback:^(int initStatus){
        NSNumber * status = [NSNumber numberWithInt:initStatus];
        [weakSelf performSelectorOnMainThread:@selector(setInitDoneLabelWithStatus:) withObject:status waitUntilDone:NO];
    }];

    // When analysis result is ready, we update the labels in UI, again, notice the 
    // performSelectorOnMainThread
    [analyzer setResultCallback:^(int score, int speed, NSString *words){
        NSString *scoreString = [NSString stringWithFormat:@"%d", score];
        NSString *speedString = [NSString stringWithFormat:@"%d", speed];
        [weakSelf performSelectorOnMainThread:@selector(setScoreLabelWithText:) withObject:scoreString waitUntilDone:NO];
        [weakSelf performSelectorOnMainThread:@selector(setSpeedLabelWithText:) withObject:speedString waitUntilDone:NO];
        [weakSelf performSelectorOnMainThread:@selector(setMispronouncedLabelWithText:) withObject:words waitUntilDone:NO];
    }];

    // Updating completion percentage label during analysis
    [analyzer setCompletionCallback:^(int completion){
        NSString *completionString = [NSString stringWithFormat:@"%d", completion];
        [weakSelf performSelectorOnMainThread:@selector(setCompletionLabelWithText:) withObject:completionString waitUntilDone:NO];
    }];
    
    // Updating recognized words label during recording
    [analyzer setNewWordsCallback:^(NSString *words) {
        [weakSelf performSelectorOnMainThread:@selector(setRecognizedLabelWithText:) withObject:words waitUntilDone:NO];
    }];
    
}


// Nothing special there
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

// This is just to hide the virtual keyboard once "Done" is pressed
- (BOOL) textFieldShouldReturn:(UITextField *)theTextField {
    if ((theTextField == self.sentencesField) ||
        (theTextField == self.addWordField) ||
        (theTextField == self.addWordPronField)
        )
    {
        [theTextField resignFirstResponder];
    }
    return YES;
}

// Following are a bunch of method called in the blocks to update the UI. Should be self-explanatory
- (void) setInitDoneLabelWithStatus:(NSNumber *)initStatus {
  if ([initStatus shortValue] == 0)
    self.initializedLabel.text = @"Yes";
  else
    self.initializedLabel.text = @"Error";
}
- (void) setCompletionLabelWithText:(NSString *)text {
    self.completionLabel.text = text;
}
- (void) setRecognizedLabelWithText:(NSString *)text {
    self.recognizedLabel.text = text;
}
- (void) setMispronouncedLabelWithText:(NSString *)text {
    self.mispronouncedLabel.text = text;
}
- (void) setScoreLabelWithText:(NSString *)text {
    self.scoreLabel.text = text;
}
- (void) setSpeedLabelWithText:(NSString *)text {
    self.speedLabel.text = text;
}

// Following is the implementation of actions wired to buttons
// Usually these are straignt calls to the ISTAnalyzer member
// functions

- (IBAction)initializeAnalyzer:(id)sender {
    self.initializedLabel.text = @"Initializing";
    // Those next three lines are now necessary to be able
    // to play and record audio
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error: nil];
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute,
                            sizeof(audioRouteOverride), &audioRouteOverride);
    [analyzer startInitialization];
}

// Before starting recording, updating the sentence property from the 
// text field
- (IBAction)startRecording:(id)sender {
    // Make sure the sentence wont be freed
    NSString *sentences = [NSString stringWithString:self.sentencesField.text];
    int strictness = 1;
    [analyzer setStrictness:strictness];
    [analyzer setSentences:sentences];
    [analyzer startRecording];
}

- (IBAction)StopRecording:(id)sender {
    [analyzer stopRecording];
}

- (IBAction)startReplay:(id)sender {
    [analyzer startPlayback];
}

- (IBAction)stopReplay:(id)sender {
    [analyzer stopPlayback];
}

// Adding a word to dictionary. We reset the text fields if successful
- (IBAction)addWord:(id)sender {
    if([analyzer addWordWithWord:self.addWordField.text pronunciation:self.addWordPronField.text]) {
        self.addWordField.text = @"";
        self.addWordPronField.text = @"";
    }
}
@end
