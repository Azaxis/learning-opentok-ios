OpenTok iOS SDK Getting Started Sample App
==========================================

This sample app shows how to accomplish basic tasks using the OpenTok iOS SDK.
It connects the user with another client so that they can share an OpenTok audio-video
chat session. Additionally, the app uses the OpenTok iOS SDK to implement the following:

* Controls for muting the audio of each participant
* A control for switching the camera used (between the front and back)
* Text chat for the participants
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

4. Copy the SampleConfig.h file to a Config.h file.

   Copy the contents of the SampleConfig.h file to the clipboard. Then select
   File > New > File (Command-N). In the dialog that is displayed, select
   Header File, click Next, and save the file as Config.h.

  The next section describes how setting values for the constants defined in this file.

## Getting an OpenTok session ID, token, and API key

An OpenTok session connects different clients letting them share audio-video streams and
send messages. Clients in the same session can include iOS, Android, and web browsers.

**Session IDs** -- Each client that connects to the session needs the session ID, which identifies
the session. Think of a session as a room, in which clients meet. Depending on the requirements of your application, you will either reuse the same session (and session ID) repeatedly or generate
new session IDs for new groups of clients.

*Important:* This demo application assumes that only two clients -- the local iOS client and another
client -- will connect in the same OpenTok session. For test purposes, you can reuse the same
session ID each time two clients connect. However, in a production application, your server-side
code must create a unique session ID for each pair of clients. In other applications, you may want
to connect many clients in one OpenTok session (for instance, a meeting room) and connect others
in another session (another meeting room). For examples of apps that connect users in different
ways, see the OpenTok ScheduleKit, Presence Kit, and Link Kit [Starter Kit apps] [2].

Since this app uses the OpenTok archiving feature to record the session, the session must be set
to use the `routed` media mode, indicating that it will use the OpenTok Media Router. The OpenTok
Media Router provides other advanced features (see [The OpenTok Media Router and media modes] [3]).
If your application does not require the features provided by the OpenTok Media Router, you can set
the media mode to `relayed`.

**Token** -- The client also needs a token, which grants them access to the session. Each client is
issued a unique token when they connect to the session. Since the user publishes an audio-video stream to the session, the token generated must include the publish role (the default). For more
information about tokens, see the OpenTok [Token creation overview] [4].

**API key** -- The API key identifies your OpenTok developer account.

Upon starting up, the application calls the `[self getSessionCredentials:]` method (defined in the
ViewController.m file). This method calls a web service that provides an OpenTok session ID, API key, and token to be used by the client. Set URL of the web service in the `kSessionCredentialsUrl`
constants in the Config.h file (see the previous section)

    define SESSION_CREDENTIALS_URL @"http://YOUR-SERVER-URL/session"

The web service returns an HTTP response that includes the session ID, the token, and API key
formatted as JSON data:

    {
      "sessionId": "2_MX40NDQ0MzEyMn5-fn4",
      "apiKey": "12345",
      "token": "T1==cGFydG5lcl9pZD00jg="
    }

For sample PHP server code that serves up these credentials, see the Getting Started PHP sample
application. (TODO: Add a link.)

For test purposes, you can assign hard-coded test session IDs to the following constant declarations
in the Config.h file:

    #define API_KEY @"2_MX40NDQ0MzEyMn5-fn4"
    #define SESSION_ID "12345"
    #define TOKEN @"T1==cGFydG5lcl9pZD00jg="

You can obtain your API key as well as test values for the session ID and token at the
[OpenTok dashboard] [5]. If you set these hard-coded values, the application uses these values
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

    #define START_ARCHIVE_URL @"http://YOUR-SERVER-URL/start/"
    #define STOP_ARCHIVE_URL @"http://YOUR-SERVER-URL/stop/"
    #define PLAYBACK_ARCHIVE_URL @"http://YOUR-SERVER-URL/"

If you do not set these strings, the *Start recording*, *Stop Recording*, and *View archive*
buttons will not be available in the app.

See the PHP Getting Started sample for sample server-side PHP code for OpenTok archiving.
(TODO: Add a link.)

Testing the app
---------------

Now that you have configured the app to get the OpenTok session ID, token, and API key (see the
previous section), you can test the application:

1. In XCode, launch the app in a connected iOS device or in the iOS simulator.

2. On first run, the app asks you for access to the camera:

     Getting Started would like to Access the Camera: Don't Allow / OK

   iOS OS requires apps to automatically ask the user to grant camera permission to an app.

   The published stream appears in the lower-lefthand corner of the video view. (The main storyboard
   of the app defines many of the views and UI controls used by the app.)

3. Now close the app and find the test.html file in the root of the project. You will use the
   test.html file (in located in the root directory of this project), to connect to the OpenTok
   session and publish an audio-video stream from a web browser:

   * Edit the test.html file and set the `sessionCredentialsUrl` variable to match the
     `ksessionCredentialsUrl` property used in the iOS app. Or -- if you are using hard-coded
     session ID, token, and API key settings -- set the `apiKey`,`sessionId`, and `token` variables.

   * Add the test.html file to a web server. (You cannot run WebRTC videos in web pages loaded
     from the desktop.)

   * In a browser, load the test.html file from the web server.

4. Run the iOS app again. The app will send an audio-video stream to the web client and receive
   the web client's stream.

5. Click the mute mic button (below the video views).

   This mutes the microphone and prevents audio from being published. Click the button again to
   resume publishing audio.

6. Click the mute mic button in the subscribed stream view.

   This mutes the local playback of the subscribed stream.

7. Click the swap camera button (below the video views).

   This toggles the camera used (between front and back) for the published stream.

8. Click in the text chat input field (labeled "Enter text chat message here"), enter a text
   chat message and tap the Return button.

   The text chat message is sent to the web client. You can also send a chat message from the web
   client to the iOS client.

9. Tap the *Start recording* button.

   This starts recording the audio video streams on the OpenTok Media Server.

10. Click the *Stop recording* button to stop the recording.

11. Click the *View recording* button to view the recording in the web browser.

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

The OTSession object (`_session`), defined by the OpenTok iOS SDK, represents the OpenTok session
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

It then adds the publisher's view, which contains its video, as a subview of the
`_publisherView` UIView element, defined in the main storyboard.

    [_publisher.view setFrame:CGRectMake(0, 0, _publisherView.bounds.size.width,
                                       _publisherView.bounds.size.height)];
    [_publisherView addSubview:_publisher.view];

This app sets `self` to implement the OTPublisherDelegate interface and receive publisher-related
events.

Upon successfully publishing the stream, the implementation of the
`[OTPublisherDelegate publisher:streamCreated]`  method is called:

    - (void)publisher:(OTPublisherKit *)publisher
    streamCreated:(OTStream *)stream
    {
        NSLog(@"Now publishing.");
    }

If the publisher stops sending its stream to the session, the implementation of the
`[OTPublisherDelegate publisher:streamDestroyed]` method is called:

    - (void)publisher:(OTPublisherKit*)publisher
    streamDestroyed:(OTStream *)stream
    {
        [self cleanupPublisher];
    }

The `[self cleanupPublisher:]` method removes the publisher's view (its video) from its
superview:

    - (void)cleanupPublisher {
        [_publisher.view removeFromSuperview];
        _publisher = nil;
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
connecting to the session and publishing, the method checks to see if the app is already
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
you start viewing the other client's audio-video stream.

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
constants are defined in the [AVCaptureDevice] [6] class.

Other resources
---------------

See the following:

* [API reference] [7] -- Provides details on the OpenTok iOS SDK API
* [Tutorials] [8] -- Includes conceptual information and code samples for all OpenTok features
* [Sample code] [9] (Also included in the OpenTok iOS SDK download) -- Includes sample apps
  that show more features of the OpenTok iOS SDK

[1]: https://tokbox.com/opentok/libraries/client/ios/
[2]: https://tokbox.com/opentok/starter-kits/
[3]: https://tokbox.com/opentok/tutorials/create-session/#media-mode
[4]: https://tokbox.com/opentok/tutorials/create-token/
[5]: https://dashboard.tokbox.com
[6]: https://developer.apple.com/library/mac/documentation/AVFoundation/Reference/AVCaptureDevice_Class
[7]: https://tokbox.com/opentok/libraries/client/ios/reference/
[8]: https://tokbox.com/opentok/tutorials/
[9]: https://github.com/opentok/opentok-ios-sdk-samples