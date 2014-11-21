OpenTok iOS SDK Getting Started Sample App
==========================================

This sample app shows how to accomplish basic tasks using the OpenTok iOS SDK.

First steps
-----------

1. Download the [OpenTok iOS SDK] [1].

2. Open the OpenTok-Getting-Started.xcodeproj file in Xcode.

3. Include the OpenTok.framework in the list of frameworks used by the app.
   From the OpenTok iOS SDK, you can drag the OpenTok.framework into the list of
   libraries in the Xcode project explorer for the app.

Test the app:

TODO. Note that the app asks you for access to the camera:

   Getting Started would like to Access the Camera: Don't Allow / OK

The user interface layout
-------------------------

TODO -- Briefly describe the UI controls in the main storyboard and how they will be used.

Getting an OpenTok session ID and token
---------------------------------------

Upon starting up, the application calls the `[getSessionCredentials]` method.
This method calls a web service that provides an OpenTok session ID, API key, and
token to be used by the client.

TODO -- describe these OpenTok concepts.

The web service returns an HTTP response with JSON data like the following:

    {
      "sessionId":"2_MX40NDQ0MzEyMn5-fn4",
      "apiKey":"12345",
      "token":"T1==cGFydG5lcl9pZD00jg="
    }

Connecting to the session
-------------------------

TODO

Publishing an audio video stream to the session
-----------------------------------------------

TODO

Subscribing to another client's audio-video stream
--------------------------------------------------

TODO

Muting the publisher and subscriber
-----------------------------------

TODO

Changing the camera used by the publisher
-----------------------------------------

TODO

Recording the session to an archive
-----------------------------------

TODO

Using the signaling API to implement text chat
----------------------------------------------

TODO



[1]: https://tokbox.com/opentok/libraries/client/ios/
