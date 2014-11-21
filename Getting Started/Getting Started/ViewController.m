//
//  ViewController.h
//  Getting Started
//
//  Created by Jeff Swartz on 11/19/14.
//  Copyright (c) 2014 TokBox, Inc. All rights reserved.

#import "ViewController.h"
#import <OpenTok/OpenTok.h>

@interface ViewController ()
<OTSessionDelegate, OTSubscriberKitDelegate, OTPublisherDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *subscriberView;
@property (weak, nonatomic) IBOutlet UIView *publisherView;
@property (weak, nonatomic) IBOutlet UIButton *swapCameraBtn;
@property (weak, nonatomic) IBOutlet UIButton *archiveControlBtn;
@property (weak, nonatomic) IBOutlet UIButton *publisherAudioBtn;
@property (weak, nonatomic) IBOutlet UIButton *subscriberAudioBtn;
@property (weak, nonatomic) IBOutlet UIImageView *archivingIndicatorImg;
@property (weak, nonatomic) IBOutlet UIScrollView *chatScrollView;
@property (weak, nonatomic) IBOutlet UITextView *chatTextInputView;

@end

@implementation ViewController {
    OTSession* _session;
    OTPublisher* _publisher;
    OTSubscriber* _subscriber;
    
    // Used for archive recording:
    NSString* _archiveId;
    NSTimer * _archiveIndicatorTimer;
}

/*
 Set kSessionCredentialsUrl to the URL for your webservice that returns
 the OpenTok session ID, API key, and token to be used by this client.
 The webservice should return the data as JSON in the following form:

 {
   "sessionId":"2_MX40NDQ0MzEyMn5-fn4",
   "apiKey":"12345",
   "token":"T1==cGFydG5lcl9pZD00jg="
 }

 Set kStartArchiveURL to the URL for your webservice that starts recording
 the session to an OpenTok archive:

 Set kStartArchiveURL to the URL for your webservice that stops recording
 the session to an OpenTok archive:

 Set kPlaybackArchiveURL to the URL for your the page that plays back archive
 recordings. Append the URL with a query string containing the archive ID:
 */
static NSString *const kSessionCredentialsUrl;
static NSString *const kStartArchiveURL;
static NSString *const kStopArchiveURL;
static NSString *const kPlaybackArchiveURL;

/*
 For test purposes, if you do not have a webservice set up to provide OpenTok
 session information, you can set the following to your OpenTok API key,
 a test session ID, and a test token, which you can obtain at the OpenTok
 dashboard: https://dashboard.tokbox.com
 */

NSString* _apiKey;
NSString* _sessionId;
NSString* _token;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _chatTextInputView.delegate = self;
    [self getSessionCredentials];
}

- (void)getSessionCredentials
{
    if (!_apiKey || !_sessionId || !_token) {
        // Get the OpenTok API key and a session ID and token from the web service
        NSURL *url = [NSURL URLWithString: kSessionCredentialsUrl];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
        [request setHTTPMethod: @"GET"];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
            if (error){
                NSLog(@"Error,%@, URL: %@", [error localizedDescription],kSessionCredentialsUrl);
            }
            else{
                NSDictionary *roomInfo = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                _apiKey = [roomInfo objectForKey:@"apiKey"];
                _token = [roomInfo objectForKey:@"token"];
                _sessionId = [roomInfo objectForKey:@"sessionId"];
                
                if(!_apiKey || !_token || !_sessionId) {
                    NSLog(@"Error invalid response from server, URL: %@",kSessionCredentialsUrl);
                } else {
                    [self doConnect];
                }
            }
        }];
    } else {
        // Use the hardcoded API key, session ID, and token values,
        // which you should not do in a shipping application.
        [self doConnect];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if (UIUserInterfaceIdiomPhone == [[UIDevice currentDevice]
                                      userInterfaceIdiom])
    {
        return NO;
    } else {
        return YES;
    }
}
#pragma mark - OpenTok methods

/**
 * Asynchronously begins the session connect process. Some time later, we will
 * expect a delegate method to call us back with the results of this action.
 */
- (void)doConnect
{
    // Initialize a new instance of OTSession and begin the connection process.
    _session = [[OTSession alloc] initWithApiKey:_apiKey
                                       sessionId:_sessionId
                                        delegate:self];
    OTError *error = nil;
    [_session connectWithToken:_token error:&error];
    if (error)
    {
        NSLog(@"Unable to connect to session (%@)",
              error.localizedDescription);
    }
}

/**
 * Sets up an instance of OTPublisher to use with this session. OTPubilsher
 * binds to the device camera and microphone, and will provide A/V streams
 * to the OpenTok session.
 */
- (void)doPublish
{
    _publisher = [[OTPublisher alloc]
                  initWithDelegate:self];
    
    OTError *error = nil;
    [_session publish:_publisher error:&error];
    if (error)
    {
        NSLog(@"Unable to publish (%@)",
              error.localizedDescription);
    }
    
    [_publisher.view setFrame:CGRectMake(0, 0, _publisherView.bounds.size.width,
                                         _publisherView.bounds.size.height)];
    [_publisherView addSubview:_publisher.view];

    _archiveControlBtn.hidden = NO;
    [_archiveControlBtn addTarget:self
                           action:@selector(startArchive)
                 forControlEvents:UIControlEventTouchUpInside];
    
    _publisherAudioBtn.hidden = NO;
    [_publisherAudioBtn addTarget:self
                          action:@selector(togglePublisherMic)
                forControlEvents:UIControlEventTouchUpInside];
    
    _swapCameraBtn.hidden = NO;
    [_swapCameraBtn addTarget:self
               action:@selector(swapCamera)
     forControlEvents:UIControlEventTouchUpInside];
}

-(void)startArchive
{
    _archiveControlBtn.hidden = YES;
    NSURL *url = [NSURL URLWithString: kStartArchiveURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    [request setHTTPMethod: @"GET"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        if (error){
            NSLog(@"Error starting the archive: %@. URL : %@",
                  [error localizedDescription],
                  kStartArchiveURL);
        }
        else{
            NSLog(@"Web service call to start the archive: %@", kStartArchiveURL);
        }
    }];
}

-(void)stopArchive
{
    _archiveControlBtn.hidden = YES;
    NSString *fullURL = kStopArchiveURL;
    fullURL = [fullURL stringByAppendingString:@"/"];
    fullURL = [fullURL stringByAppendingString:_archiveId];
    NSURL *url = [NSURL URLWithString: fullURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    [request setHTTPMethod: @"GET"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        if (error){
            NSLog(@"Error stopping the archive: %@. URL : %@",
                  [error localizedDescription],fullURL);
        }
        else{
            NSLog(@"Web service call to stop the archive: %@", fullURL);
        }
    }];
}

- (void) blinkArchiveIndicator
{
    _archiveIndicatorTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                              target: self
                                                            selector:@selector(onArchiveIndicatorTimerTick)
                                                            userInfo: nil repeats:YES];
}

-(void) onArchiveIndicatorTimerTick
{
    _archivingIndicatorImg.hidden = !_archivingIndicatorImg.hidden;
}

-(void)loadArchivePlaybackInBrowser
{
    NSString *fullURL = kPlaybackArchiveURL;
    fullURL = [fullURL stringByAppendingString:@"?archiveId="];
    fullURL = [fullURL stringByAppendingString:_archiveId];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:fullURL]];
}

-(void)togglePublisherMic
{
    _publisher.publishAudio = !_publisher.publishAudio;
    if (_publisher.publishAudio) {
        [_publisherAudioBtn setTitle: @"Mute mic" forState:UIControlStateNormal];
    } else {
        [_publisherAudioBtn setTitle: @"Unute mic" forState:UIControlStateNormal];
    }
}
-(void)swapCamera
{
    if (_publisher.cameraPosition == AVCaptureDevicePositionFront) {
        _publisher.cameraPosition = AVCaptureDevicePositionBack;
    } else if (_publisher.cameraPosition == AVCaptureDevicePositionBack) {
        _publisher.cameraPosition = AVCaptureDevicePositionFront;
    }
}

/**
 * Cleans up the publisher and its view. At this point, the publisher is not
 * attached to the session.
 */
- (void)cleanupPublisher {
    [_publisher.view removeFromSuperview];
    _publisher = nil;
    // this is a good place to notify the end-user that publishing has stopped.
}

/**
 * Instantiates a subscriber for the given stream and asynchronously begins the
 * process to begin receiving A/V content for this stream. Unlike doPublish,
 * this method does not add the subscriber to the view hierarchy. Instead, we
 * add the subscriber only after it has connected and begins receiving data.
 */
- (void)doSubscribe:(OTStream*)stream
{
    _subscriber = [[OTSubscriber alloc] initWithStream:stream
                                              delegate:self];
    OTError *error = nil;
    [_session subscribe:_subscriber error:&error];
    if (error)
    {
        NSLog(@"Unable to publish (%@)",
              error.localizedDescription);
    }
}

/**
 * Cleans the subscriber from the view hierarchy, if any.
 * NB: You do *not* have to call unsubscribe in your controller in response to
 * a streamDestroyed event. Any subscribers (or the publisher) for a stream will
 * be automatically removed from the session during cleanup of the stream.
 */
- (void)cleanupSubscriber
{
    [_subscriber.view removeFromSuperview];
    _subscriber = nil;
}

- (void) sendChatMessage
{
    OTError* error = nil;
    [_session signalWithType:@"chat" string:_chatTextInputView.text connection:nil error:&error];
    if (error) {
        NSLog(@"Signal error: %@", error);
    } else {
        NSLog(@"Signal sent: %@", _chatTextInputView.text);
    }
    _chatTextInputView.text = @"";
}

- (void)logSignalString:(NSString*)string fromSelf:(Boolean)fromSelf {
    UIColor* backgroundColor = [UIColor whiteColor];
    if (fromSelf) {
        backgroundColor = [UIColor colorWithRed:0.81 green:0.89 blue:0.95 alpha:1.0];
    }
    UITextView* textView =
    [[UITextView alloc]initWithFrame:CGRectMake(0,
                                                (_chatScrollView.subviews.count - 2) * 40,
                                                _chatScrollView.bounds.size.width - 20,
                                                40)];
    textView.font = [UIFont fontWithName:@"Helvetica" size:12];
    textView.font = [UIFont boldSystemFontOfSize:12];
    textView.backgroundColor = backgroundColor;
    textView.textColor = [UIColor blackColor];
    textView.scrollEnabled = NO;
    textView.pagingEnabled = YES;
    textView.editable = NO;
    textView.text = string;
    
    CGRect frame = textView.frame;
    frame.size.height = [textView contentSize].height;
    textView.frame = frame;
    
    [_chatScrollView addSubview:textView];
}

# pragma mark - OTSession delegate callbacks

- (void)sessionDidConnect:(OTSession*)session
{
    // We have successfully connected, now start pushing an audio-video stream
    // to the OpenTok session.
    _chatTextInputView.hidden = NO;

    [self doPublish];
}

- (void)sessionDidDisconnect:(OTSession*)session
{
    NSString* alertMessage =
    [NSString stringWithFormat:@"Session disconnected: (%@)",
     session.sessionId];
    NSLog(@"sessionDidDisconnect (%@)", alertMessage);
}

- (void)session:(OTSession*)mySession
streamCreated:(OTStream *)stream
{
    NSLog(@"session streamCreated (%@)", stream.streamId);
    
    if (nil == _subscriber)
    {
        [self doSubscribe:stream];
        _chatTextInputView.hidden = NO;
    }
}

- (void)session:(OTSession*)session
streamDestroyed:(OTStream *)stream
{
    NSLog(@"session streamDestroyed (%@)", stream.streamId);
    
    if ([_subscriber.stream.streamId isEqualToString:stream.streamId])
    {
        [self cleanupSubscriber];
    }
}

- (void)  session:(OTSession *)session
connectionCreated:(OTConnection *)connection
{
    NSLog(@"session connectionCreated (%@)", connection.connectionId);
}

- (void)    session:(OTSession *)session
connectionDestroyed:(OTConnection *)connection
{
    NSLog(@"session connectionDestroyed (%@)", connection.connectionId);
    if ([_subscriber.stream.connection.connectionId
         isEqualToString:connection.connectionId])
    {
        [self cleanupSubscriber];
    }
}

- (void) session:(OTSession*)session
didFailWithError:(OTError*)error
{
    NSLog(@"didFailWithError: (%@)", error);
}

# pragma mark - OTSubscriber delegate callbacks

- (void)subscriberDidConnectToStream:(OTSubscriberKit*)subscriber
{
    NSLog(@"subscriberDidConnectToStream (%@)",
          subscriber.stream.connection.connectionId);
    [_subscriber.view setFrame:CGRectMake(0, 0, _subscriberView.bounds.size.width,
                                          _subscriberView.bounds.size.height)];
    [_subscriberView addSubview:_subscriber.view];
    _subscriberAudioBtn.hidden = NO;
}

- (void)subscriber:(OTSubscriberKit*)subscriber
didFailWithError:(OTError*)error
{
    NSLog(@"subscriber %@ didFailWithError %@",
          subscriber.stream.streamId,
          error);
}

# pragma mark - OTPublisher delegate callbacks

- (void)publisher:(OTPublisherKit *)publisher
streamCreated:(OTStream *)stream
{
    NSLog(@"Now publishing.");
}

- (void)publisher:(OTPublisherKit*)publisher
streamDestroyed:(OTStream *)stream
{
    if ([_subscriber.stream.streamId isEqualToString:stream.streamId])
    {
        [self cleanupSubscriber];
    }
    
    [self cleanupPublisher];
}

- (void)publisher:(OTPublisherKit*)publisher
didFailWithError:(OTError*) error
{
    NSLog(@"publisher didFailWithError %@", error);
    [self cleanupPublisher];
}

- (void)     session:(OTSession*)session
archiveStartedWithId:(NSString *)archiveId
name:(NSString *)name
{
    NSLog(@"session archiving started with id:%@ name:%@", archiveId, name);
    _archiveId = archiveId;
    [_archiveControlBtn setTitle: @"Stop recording" forState:UIControlStateNormal];
    _archiveControlBtn.hidden = NO;
    [_archiveControlBtn addTarget:self
                           action:@selector(stopArchive)
                 forControlEvents:UIControlEventTouchUpInside];
    [self blinkArchiveIndicator];
}

- (void)     session:(OTSession*)session
archiveStoppedWithId:(NSString *)archiveId
{
    NSLog(@"session archiving stopped with id:%@", archiveId);
    [_archiveIndicatorTimer invalidate];
    _archivingIndicatorImg.hidden = YES;
    [_archiveControlBtn setTitle: @"View archive" forState:UIControlStateNormal];
    _archiveControlBtn.hidden = NO;
    [_archiveControlBtn addTarget:self
                           action:@selector(loadArchivePlaybackInBrowser)
                 forControlEvents:UIControlEventTouchUpInside];
}

- (void)session:(OTSession*)session receivedSignalType:(NSString*)type fromConnection:(OTConnection*)connection withString:(NSString*)string {
    NSLog(@"Received signal %@", string);
    Boolean fromSelf = NO;
    if ([connection.connectionId isEqualToString:session.connection.connectionId]) {
        fromSelf = YES;
    }
    [self logSignalString:string fromSelf:fromSelf];
}

# pragma mark - UITextViewDelegate callbacks

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    _chatTextInputView.text = @"";
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSCharacterSet *doneButtonCharacterSet = [NSCharacterSet newlineCharacterSet];
    NSRange replacementTextRange = [text rangeOfCharacterFromSet:doneButtonCharacterSet];
    NSUInteger location = replacementTextRange.location;
    
    if (textView.text.length + text.length > 140){
        if (location != NSNotFound){
            [textView resignFirstResponder];
            [self sendChatMessage];
        }
        return NO;
    }
    else if (location != NSNotFound){
        [textView resignFirstResponder];
        [self sendChatMessage];
        return NO;
    }
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesBegan:withEvent:");
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

@end