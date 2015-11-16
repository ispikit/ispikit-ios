ISTAnalyzer - Ispikit Library for iOS
=====================================

Version 2.0

This package contains the Ispikit Library, or ISTAnalyzer for iOS (ARM and Intel) devices. It also includes a simple iOS application (named SampleApp) that illustrates the use of the library. The library is intended to record audio from a user, recognize it, score the pronunciation, the speech tempo, and detect mispronounced words. It has an Objective-C API, and it can be easily integrated into an existing application, as shown in the sample project. This repository contains:

* `ISTAnalyzer`: Ispikit Library, including header file, static libraries and resource files
* `SampleApp`: sample application
* `README.md`: This file
* `LICENSE`

This version is free to use and includes two limitations compared to the full version:

    Number of sentences for recognition is limited to 3
    Number of words per sentence is limited to 4

Contact us at info@ispikit.com for the full version.

Content:

1. Introduction - Compile and use the sample application
2. What the Ispikit Library does
3. Integrate the library into an iOS application
4. API documentation
5. Important requirements for applications that use the Ispikit Library
6. Additional notes
7. Appendix: Pronunciation Dictionary


# 1. Introduction - Compile and use the sample application

* Open the SampleApp project in XCode
* Make sure it is set to compile and run the sample app on the simulator.
* Make sure you have a valid headset configured.
* Launch compilation and app.
* Once the app is up, you must first initialize the library (press the "Initialize" button). The field "Init" changes to "Yes" once completed.
* Enter sentences in the text field (separated with commas, no punctuation inside sentences).
* Press the "Start" and read one of the sentences.
* While you read, you will see the recognized words as they are reported by the library (in the format x-y-z-k, explained in section 4. of this document).
* Press "Stop" to stop.
* Analysis is starting, you can see the completion status in the "Completion" field.
* At the end of analysis, you will see the score (between 0 and 100) and speech tempo (80 being probably a satisfactory value) in the corresponding fields. You will also see the analyzed words (in the format i-j-k, explained in section 4. of this document).
* You can replay the last recording with the "Play" button.
* You can add new words by entering the word and associated pronunciation, and then using that new word in your sentence, more on this later in this document and in the Appendix.



# 2. What the Ispikit Library does

The library records a user's audio input, recognizes it among the provided sentences, and computes a pronunciation score based on the words that the user was expected to say. The score is a number between 0 and 100, 100 being the ideal score of a native-like pronunciation. It also gives the reading speed, the speech tempo, that can be used to measure the reader's fluency. It is measured by "number of spoken phonemes in 10 seconds", and in practice should be more than 80 for a fluent reader.

Expected sentences can be of any length, using any word that exists in the pronunciation dictionary. The library ships with a pronunciation dictionary which is fairly large and should contain most words used in language learning context. However, it can be expanded to add new words, either by editing the packaged dictionary, or at runtime (See Appendix).


# 3. Integrate the library into an iOS application

In a nutshell, you need to import the header file (`ISTAnalyzer.h`), integrate relevant features into your app using this API, link to the static libraries (for both simulator and device) and pick the resource files to be package inside your app.

The library, header file and resource files are:

```
 ISTAnalyzer/
  -------- include/  -> Header file
  -------- res/      -> Resource files, to be packaged into your application
  -------- lib/      -> Static library files, your app should link to them (fat binaries)
```

The given SampleApp application already has this set up, you can use it as a basis of your implementation. Most code is in `SampleApp/ISTSampleAppViewController.m`.

In more details:

* Add the folder where ISTAnalyzer.h is (`ISTAnalyzer/include/`) to the list "Header Search Paths" in XCode
* Import ISTAnalyzer.h in your application, where you want to use it.
* Create an instance of ISTAnalyzer, for instance with [ISTAnalyzer new].
* Add the two lib folders to "Library Search Paths" in XCode. Make sure to differentiate properly between device and simulator versions.
* Add the proper "Other Linker Flags" in XCode to link to each of the libraries, namely: `-lupal -lsphinxbase -lpocketsphinx -lprotobuf-lite -lboost_filesystem -lboost_system -lboost_thread`
* Link to the AudioToolbox.framework and libstdc++.dylib frameworks in "Build Phases" -> "Link Binary With Libraries".
* Add the "res" folder to the bundle Resources, in "Build Phases" -> "Copy Bundle Resources". Make sure you add the folder as a whole (ie. it should appear as one item "res" in the list.

# 4. API documentation

The whole public API lies in `ISTAnalyzer.h` which defines the ISTAnalyzer class. It includes documentation. Below are more details description of the calls and callbacks.

The API consists in a few calls which are often asynchronous. Callbacks are implemented through Blocks which are read-write properties of the ISTAnalyzer class. There is also a sentence property which should be set to the current sentence to read.


## 4.a Typedefs for the blocks

Following are the signatures of the blocks used:

* `typedef void (^InitDoneCallback)(int);`

  Used to indicate that initialization of the analyzer is done. It returns an integer which should be 0 is successful. Other values indicate an error, such as missing resource files.
* `typedef void (^ResultCallback)(int, int, NSString*);`

  Gives the result of analysis. Arguments are, respectively, the pronunciation assessment score, the speech tempo and the analyzed words.

  The score of the pronunciation is an integer between 0 and 100, 100 being the highest score, showing native-like pronunciation. The speech tempo is the measure of speed. Speed is measured by "number of spoken phonemes in 10 seconds". A possible satisfactory value could be 80, slower values being associated to slow or not fluent speech.

  The NSString of analyzed words gives the list of recognized words together with a flag describing if the word has been mispronounced. Word `i-j-0` means that word index `j` of sentence `i` was recognized and is correctly pronounced. Word `i-j-1` means that word index `j` of sentence index `i` was recognized and is incorrectly pronounced.

  For instance, let's take the sentences "He speaks French and he likes it,He speaks English and he likes it,He speaks German and he likes it", and the NSString equal to "1-0-0 1-1-1 1-2-0 1-4-0 1-5-0 1-6-0". It means that the user said the second sentence (index 1), did not say the word "and", and mispronounced the word "speaks".
* `typedef void (^PlaybackDoneCallback)(void);`

  Indicates that playback is done.
* `typedef void (^NewWordsCallback)(NSString*);`

  Indicates the recognized words, in real-time during recording.

  The words are given in the following format: `x-y-z-k`. `x` being the sentence index and `y` being the word index, starting from 0. So, if you give a sentence with 10 words, you can stop recording once `y` is equal to 9. `z` and `k` show which of the pronunciation alternatives is recognized when there are alternatives, it should not be useful for the application. Accuracy of this detection is not perfect, and if you want to make use of it to stop recording, you might want to experiment with it to determine if the accuracy is good enough for your needs.
* `typedef void (^CompletionCallback)(int);`

 Indicates the percentage of completion of the analysis. Analysis start at the end of the recording and typically takes a fraction of the recorded time to complete. This callback can be used to display a completion bar in the UI to show the status to the user.

## 4.b ISTAnalyzer member functions

Most calls do not take arguments and return a boolean. YES means that the call was successful, NO means that an error was encountered or that the call can not be made at this time.

* `(BOOL) startInitialization;`

  Starts initialization of the Analyzer. This should not be confused with the proper alloc-init of the object, it must be called on a valid object, created with  [ISTAnalyzer new] or [[ISTAnalyzer alloc] init]. This call is asynchronous and calls back executing the initDoneCallback block. Typically, it takes a few seconds. Returns NO if already initialized.
* `(BOOL) startRecording;`

  Starts recording. It uses the `sentences` property as basis for recognition and analysis, so the `sentences` property should have been set before that call. During recording, the newWordsCallback block is executed each time a new word was recognized. Recording continues until stopRecording or stopRecordingWithForce is called. 

  It returns NO if the object was not Initialized, or the sentence is invalid or it is not ready to record, for instance during audio playback.

 * `(BOOL) stopRecordingWithForce:(BOOL)force;`
 * `(BOOL) stopRecording;`

  Stops recording. Typically, this will trigger analysis of the recording and calls back with the completionCallback block to give the percentage of analysis completed and finally resultCallback with the final result.

  If stopRecordingWithForce is called with YES, then no analysis is started. This is useful to stop any ongoing recording when the app is put in background and the current audio being recorded being discarded.

  Calling stopRecording is similar to calling stopRecordingWithForce with NO.

  Returns NO if Analyzer object not recording.
* `(BOOL) startPlayback;`

  Starts playing back the last recorded audio. When the whole audio is played, the playbackDoneCallback block is executed.
* `(BOOL) stopPlayback;`

  Stops playback before the end.
* `(BOOL) addWordWithWord:(NSString *)word pronunciation:(NSString *)pronunciation;`

  Adds words to the dictionary at runtime. If a word already exists, the new pronunciation is added to the existing ones, otherwise a new word is created. Words added through this API do not persist. Words and pronunciation are case insensitive. See Appendix for details.

## 4.c ISTAnalyzer properties

The ISTAnalyzer object exposes a few read-write properties.

    @property NSString *sentences;

This should be set to the expected sentences to be read before starting recording. The sentences must include only words that are present in the dictionary. See Appendix for details.

    @property (copy) InitDoneCallback initDoneCallback;
    @property (copy) ResultCallback resultCallback;
    @property (copy) PlaybackDoneCallback playbackDoneCallback;
    @property (copy) NewWordsCallback newWordsCallback;
    @property (copy) CompletionCallback completionCallback;

These are the blocks used as callbacks, as described previously. You do not have to set them all, but most of them relate to important features or help providing user-friendly UI.

# 5. Important requirements for applications that use the Ispikit Library

The library is available for the simulator and arm7+ architectures, which means that old versions of iPhones are not supported.

# 6. Appendix: Pronunciation Dictionary

In order to recognize and analyze speech, assuming the speaker is saying the sentence, the library must know how each of the word used in the sentence is pronounced. The library ships with a pronunciation dictionary that contains most words used in English. It is stored in the ISTAnalyzer/res/libdictionary.so file (it is actually a plain text file). The format used is the CMU Pronunciation dictionary: http://www.speech.cs.cmu.edu/cgi-bin/cmudict. Words and phonemes are case insensitive.

If you plan to use words that are not in this dictionary, you can edit this file and add them. Input one word per line, with one space to separate words and phonemes. You can enter the same word several times to add alternative pronunciations.

If you know beforehand all words your app will need, you can trim down the dictionary file to only contain the words you need. The app will be smaller and load faster.

Alternatively, words can be added at runtime using the provided API (See the "addWord" function). Words added at runtime do not persist when the library or app restarts.
