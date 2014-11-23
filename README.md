OpenTok iOS SDK Getting Started Sample App
==========================================

This sample app shows how to accomplish basic tasks using the OpenTok iOS SDK.
It connects the user with another client so that they can share an OpenTok audio-video
chat session. Additionally, the app uses the OpenTok API to provide the following:

* Controls for muting the audio of each participant
* A control for switching the camera used (between the front and back)
* A text chat panel
* The ability to record the chat session, stop the recording, and view the recording

Configuring the application
---------------------------

Before you can test the application, you need to make some settings in Xcode.

## Adding the OpenTok framework

1. Download the [OpenTok iOS SDK] [1].

2. Open the OpenTok-Getting-Started.xcodeproj file in Xcode.

3. Include the OpenTok.framework in the list of frameworks used by the app.
   From the OpenTok iOS SDK, you can drag the OpenTok.framework into the list of
   libraries in the Xcode project explorer for the app.

## Getting an OpenTok session ID, token, and API key

An OpenTok session connects different clients letting them share audio-video streams and
send messages. Clients in the same session can include iOS, Android, and web browsers.

**Session IDs** -- Each client that connects to the session needs the session ID, which identifies
the session. Think of a session as a room, in which clients meet. Depending on the requirements of your application, you will either reuse the same session (and session ID) repeatedly or generate
new session IDs for new groups of clients.

*Important:* This demo application assumes that only two clients -- the local iOS client and another
client -- will connect in the same OpenTok session. It is up to your server-side code to create a
unique session ID for each pair of clients. In other applications, you may want to connect some
clients in one OpenTok session (for instance, a meeting room), and others in another session
(another meeting room).

Since this app uses the OpenTok archiving feature to record the session, the session must be set
to use the `routed` media mode, indicating that it will use the OpenTok Media Router. The OpenTok
Media Router provides other advanced features (see [The OpenTok Media Router and media modes] [2]).
If your application does not require the features provided by the OpenTok Media Router, you can set
the media mode to `relayed`.

**Token** -- The client also needs a token, which grants them access to the session. Each client is
issued a unique token when they connect to the session.

**API key** -- The API key identifies your OpenTok developer account.

Upon starting up, the application calls the `[self getSessionCredentials]` method (defined in
the ViewController.m file). This method calls a web service that provides an OpenTok session ID,API key, and token to be used by the client. Set URL of the web service in the `kSessionCredentialsUrl`
property (also in the ViewController.m file):

    static NSString *const kSessionCredentialsUrl = @"https://your_web_service_url";

The web service returns an HTTP response that includes the session ID, the token, and API key
formatted as JSON data:

    {
      "sessionId": "2_MX40NDQ0MzEyMn5-fn4",
      "apiKey": "12345",
      "token": "T1==cGFydG5lcl9pZD00jg="
    }

For sample PHP server code that serves up these credentials, see the Getting Started PHP sample
application. (TODO: Add a link.)

For test purposes, you can assign hard-coded test session IDs to the following variable declarations
at the beginning of the ViewController.m file:

    NSString* _sessionId = @"2_MX40NDQ0MzEyMn5-fn4";
    NSString* _apiKey = "12345",
    NSString* _token @"T1==cGFydG5lcl9pZD00jg=";

You can obtain your API key as well as test values for the session ID and token at the
[OpenTok dashboard] [3]. If you set these hard-coded values, the application uses these values
instead of retrieving them from the web service. However in a production application, you will
always want to use a web service to obtain a unique token each time a user connects to an OpenTok
session.

You will want to authenticate each user (using your own server-side authentication techniques)
before sending an OpenTok token. Otherwise, malicious users could call your web service and
use tokens, causing streaming minutes to be charged to your OpenTok developer account. Also,
it is a best practice to use an HTTPS URL for the web service that returns an OpenTok token,
so that it cannot be intercepted and misused.

## Setting the archiving web service URLs

The OpenTok archiving API lets you record audio-video streams in a session to MP4 files. You use
server-side code to start and stop archive recordings. Set the following properties to the URLs of
web service calls that start archive recording, stop recording, and play back the recorded video:

    static NSString *const kStartArchiveURL = @"";
    static NSString *const kStopArchiveURL = @"";
    static NSString *const kPlaybackArchiveURL = @"";

See the PHP Getting Started sample for sample server-side PHP code for OpenTok archiving.
(TODO: Add a link.)

Testing the app
---------------

Now that you have configured the app to get the OpenTok session ID, token, and API key (see the
previous section), you can test the application:

1. In XCode, launch the app in a connected iOS device or in the iOS simulator.

   The app uses the API key, token and session ID to connect to an OpenTok session, and *publishes*
   an audio-video *stream* to the session. Other clients can *subscribe* to the stream you
   publish.

2. On first run, the app asks you for access to the camera:

   Getting Started would like to Access the Camera: Don't Allow / OK

   iOS OS requires apps to automatically ask the user to grant camera permission to an app.

   The published stream appears in the lower-lefthand corner of the video view. (The main storyboard
   of the app defines many of the views and UI controls used by the app.)

3. Now close the app, and find the test.html in the root of the project. You will use the test.html
   file (in located in the root directory of this project), to connect to the OpenTok session and
   publish an audio-video stream from a web browser:

   * Edit the test.html file and set the `sessionCredentialsUrl` variable to match the
     `ksessionCredentialsUrl` property used in the iOS app. Or, if you are using hard-coded
     session ID, token, and API key settings, set the `apiKey`,`sessionId`, and `token` variables.

   * Add the test.html file to a web server. (You cannot run WebRTC
     video in web pages loaded from the desktop.)

   * In a browser, load the test.html file from the web server.

4. Run the iOS app again. The app will send an audio-video stream to the web client and receive
   the web client's stream.

5. Click the mute mic button (below the video views).

   This mutes the microphone and prevents audio from being published. Click the button again to
   resume publishing audio.

6. Click the mute mic button in the subscribed stream view.

   This mutes the local playback of the subscribed stream.

7. Click the swap camera button (below the video views).

   This changes the camera used (between front and back) for the published stream.

8. Click in the text chat input field (labeled "Enter text chat message here"), enter a text
   chat message and tap the Return button.

   The text chat message is sent to the web client. You can also send a chat message from the web
   client to the iOS client.

9. Tap the Start Archive button.

   This starts recording the audio video streams on the OpenTok Media Server.

10. Click the Stop Archive button to stop the recording.

Read the following section to learn how to use the OpenTok iOS SDK to accomplish these tasks.

Connecting to the session
-------------------------

Upon obtaining the session ID, token, and API, the app calls the `[self doConnect]` method to
initialize an OTSession object and connect to the OpenTok session:

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

The OTSession object (`_session`), defined by the OpenTok iSO SDK, represents the OpenTok session
(which connects users).

The `[OTSession connectWithToken:error]` method connects the iOS app to the OpenTok session.
You must connect before sending or receiving audio-video streams in the session (or before
interacting with the session in any way).

This app sets `self` to implement the `[OTSessionDelegate]` interface to receive session-related
messages. These messages are sent when other clients connect to the session, when they send
audio-video streams to the session, and upon other session-related events, which we will look
at in the following sections.

Publishing an audio video stream to the session
-----------------------------------------------

Upon successfully connecting to the OpenTok session (see the previous section), the
`[OTSessionDelegate session:didConnect:]` message is sent. The ViewController.m code implements
this delegate method:

    - (void)sessionDidConnect:(OTSession*)session
    {
        // We have successfully connected, now start pushing an audio-video stream
        // to the OpenTok session.
        [self doPublish];
    }

The method calls the `[self doPublish]` method, which first initializes an OTPublisher object,
defined by the OpenTok iSO SDK:

    _publisher = [[OTPublisher alloc]
                  initWithDelegate:self];

The code calls the `[OTSession publish:error:]` method to publish an audio-video stream
to the session:

    OTError *error = nil;
    [_session publish:_publisher error:&error];
    if (error)
    {
        NSLog(@"Unable to publish (%@)",
              error.localizedDescription);
    }

The code sets up `self` to be the object that implements the OTPublisherDelegate
methods, which are called for publisher-related events.

Upon successfully publishing the stream, the following delegate method is called:

    - (void)publisher:(OTPublisherKit *)publisher
    streamCreated:(OTStream *)stream
    {
        NSLog(@"Now publishing.");
    }

Upon an asynchronous error in publishing the stream, the following delegate method is called:

    - (void)publisher:(OTPublisherKit*)publisher
    streamDestroyed:(OTStream *)stream
    {
        if ([_subscriber.stream.streamId isEqualToString:stream.streamId])
        {
            [self cleanupSubscriber];
        }

        [self cleanupPublisher];
    }

Subscribing to another client's audio-video stream
--------------------------------------------------

The [OTSessionDelegate session:streamCreated:] message is sent when a new stream is created in
the session. The app implements this delegate method with the following:

    - (void)session:(OTSession*)session
    streamCreated:(OTStream *)stream
    {
        NSLog(@"session streamCreated (%@)", stream.streamId);

        if (nil == _subscriber)
        {
            [self doSubscribe:stream];
        }
    }

The method is passed an OTStream object (defined by the OpenTok iOS SDK), representing the stream
that another client is publishing. Although this app assumes that only one other client is
connecting to the session and publishing.) The method checks to see if the app is already
subscribing to a stream (if the `_subscriber` property is set). If not, the session calls `[self doSubscribe:stream]`, passing in the OTStream object (for the new stream):

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

The method initializes an OTSubscriber object (`_subscriber`), used to subscribe to the stream,
passing in the OTStream object to the initialization method. It also sets `self` to implement the
OTSubscriberDelegate interface, which is sent messages related to the subscriber.

It then calls `[OTSession subscribe:error:]` to have the app to subscribe to the stream.

When the app starts receiving the subscribed stream, the
`[OTDSubscriberDelegate subscriberDidConnectToStream:]` message is sent. The implementation of the
delegate method adds view of the subscriber stream (defined by the `view` property of the OTSubscriber object) as a subview of the `_subscriberView` UIView object, defined in the main
storyboard:

    - (void)subscriberDidConnectToStream:(OTSubscriberKit*)subscriber
    {
        NSLog(@"subscriberDidConnectToStream (%@)",
              subscriber.stream.connection.connectionId);
        [_subscriber.view setFrame:CGRectMake(0, 0, _subscriberView.bounds.size.width,
                                              _subscriberView.bounds.size.height)];
        [_subscriberView addSubview:_subscriber.view];
        _subscriberAudioBtn.hidden = NO;

        _chatTextInputView.hidden = NO;
    }

It also displays the input text field for the text chat. The app hides this field until
you can view the other client starts publishing a stream in the session.

Muting the publisher and subscriber
-----------------------------------

When the user clicks the toggle publisher audio button, the `[self togglePublisherMic]`
method is called:

   -(void)togglePublisherMic
    {
        _publisher.publishAudio = !_publisher.publishAudio;
        if (_publisher.publishAudio) {
            [_publisherAudioBtn setTitle: @"Mute mic" forState:UIControlStateNormal];
        } else {
            [_publisherAudioBtn setTitle: @"Unute mic" forState:UIControlStateNormal];
        }
    }

The `publishAudio` property of the OTPublisher object is set to a Boolean value indicating whether
the publisher is publishing audio or not. The method toggles the setting when the user clicks the
button.

Similarly, the `subscribeToAudio` property of the OTSubscriber object is a Boolean value indicating
whether the local iOS device is playing back the subscribed stream's audio or not. When the user
clicks the toggle audio button for the Subscriber, the following method is called:

    -(void)toggleSubscriberAudio
    {
        _subscriber.subscribeToAudio = !_subscriber.subscribeToAudio;
    }

Changing the camera used by the publisher
-----------------------------------------

When the user clicks the toggle camera button, the `[self swapCamra]` method is called:

   -(void)swapCamera
    {
        if (_publisher.cameraPosition == AVCaptureDevicePositionFront) {
            _publisher.cameraPosition = AVCaptureDevicePositionBack;
        } else {
            _publisher.cameraPosition = AVCaptureDevicePositionFront;
        }
    }

Setting the `cameraPosition` property of the OTPublisher object sets the camera used by
the publisher. The `AVCaptureDevicePositionFront` and `AVCaptureDevicePositionBack`
constants are defined in the [AVCaptureDevice] [4] class.

Recording the session to an archive
-----------------------------------

When the user clicks the Start Recording and Stop Recording buttons, the app calls the
[self startArchive:] and [self startArchive:] methods. These call web services that call
server-side code start and stop archive recordings.
(See [Setting the archiving web service URLs](#setting-the-archiving-web-service-urls).)

When archive recording starts, the implementation of the
`[OTSessionDelegate session:archiveStartedWithId:name:]` method is called:

    - (void)     session:(OTSession*)session
    archiveStartedWithId:(NSString *)archiveId
                    name:(NSString *)name
    {
        NSLog(@"session archiving started with id:%@ name:%@", archiveId, name);
        _archiveId = archiveId;
        _archivingIndicatorImg.hidden = NO;
        [_archiveControlBtn setTitle: @"Stop recording" forState:UIControlStateNormal];
        _archiveControlBtn.hidden = NO;
        [_archiveControlBtn addTarget:self
                               action:@selector(stopArchive)
                     forControlEvents:UIControlEventTouchUpInside];
    }

This causes the `_archivingIndicatorImg` image (defined in the main storyboard) to be displayed.
The method stores the archive ID (identifying the archive) to an `archiveId` property.
The method also changes the archiving control button text to change to "Stop recording".

When the user clicks the Stop Recording button, the app passes the archive ID along to the
web service that stops the archive recording.

When archive recording stops, the implementation of the
`[OTSessionDelegate session:archiveStartedWithId:name:]` method is called:

    - (void)     session:(OTSession*)session
    archiveStoppedWithId:(NSString *)archiveId
    {
        NSLog(@"session archiving stopped with id:%@", archiveId);
        _archivingIndicatorImg.hidden = YES;
        [_archiveControlBtn setTitle: @"View archive" forState:UIControlStateNormal];
        _archiveControlBtn.hidden = NO;
        [_archiveControlBtn addTarget:self
                               action:@selector(loadArchivePlaybackInBrowser)
                     forControlEvents:UIControlEventTouchUpInside];
    }

This causes the `_archivingIndicatorImg` image (defined in the main storyboard) to be
displayed. It also changes the archiving control button text to change to "View archive".
When the user clicks this button, the `[self loadArchivePlaybackInBrowser:]` method
opens a web page (in Safari) that displays the archive recording.

Using the signaling API to implement text chat
----------------------------------------------

When the user enters text in the text chat input text field, the '[self sendChatMessage:]
method is called:

    - (void) sendChatMessage
    {
        OTError* error = nil;
        [_session signalWithType:@"chat"
                          string:_chatTextInputView.text
                      connection:nil error:&error];
        if (error) {
            NSLog(@"Signal error: %@", error);
        } else {
            NSLog(@"Signal sent: %@", _chatTextInputView.text);
        }
        _chatTextInputView.text = @"";
    }

This method calls the `[OTSession signalWithType:string:connection:]` method. This
method sends a message to clients connected to the OpenTok session. Each signal is
defined by a `type` string identifying the type of message (in this case '"chat")
and a string containing the message.

When another client connected to the session (in this app, there is only one) sends
a message, the implementation of the `[OTSessionDelegate session:receivedSignalType:string:]`
method is called:

    - (void)session:(OTSession*)session receivedSignalType:(NSString*)type fromConnection:(OTConnection*)connection withString:(NSString*)string {
        NSLog(@"Received signal %@", string);
        Boolean fromSelf = NO;
        if ([connection.connectionId isEqualToString:session.connection.connectionId]) {
            fromSelf = YES;
        }
        [self logSignalString:string fromSelf:fromSelf];
    }

This method checks to see if the signal was sent by the local iOS client or by the other
client connected to the session:

    Boolean fromSelf = NO;
    if ([connection.connectionId isEqualToString:session.connection.connectionId]) {
        fromSelf = YES;
    }

The `session` argument represents your clients OTSession object. The OTSession object has
a `connection` property with a `connectionId` property. The `connection` argument represents
the connection of client sending the message. If these match, the signal was sent by the
local iOS app.

The method calls the `[self logSignalString:]` method which displays the message string in
the text chat scroll view.

This app uses the OpenTok signaling API to implement text chat. However, you can use the
signaling API to send messages to other clients (individually or collectively) connected to
the session.

Other resources
---------------

TODO


[1]: https://tokbox.com/opentok/libraries/client/ios/
[2]: https://tokbox.com/opentok/tutorials/create-session/#media-mode
[3]: https://dashboard.tokbox.com
[4]: https://developer.apple.com/library/mac/documentation/AVFoundation/Reference/AVCaptureDevice_Class
