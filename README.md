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
      "sessionId":"2_MX40NDQ0MzEyMn5-U3VuIE1heSAxMSAxMTo0Mzo0OSBQRFQgMjAxNH4wLjM0MDc4NDEzfn4",
      "apiKey":"44443122",
      "token":"T1==cGFydG5lcl9pZD00NDQ0MzEyMiZzaWc9MTVjZTFlNDgzNGYzODZmM2I5YzA4M2ZmMzQwODhiMDBmZTk1MWE4ZTpzZXNzaW9uX2lkPTJfTVg0ME5EUTBNekV5TW41LVUzVnVJRTFoZVNBeE1TQXhNVG8wTXpvME9TQlFSRlFnTWpBeE5INHdMak0wTURjNE5ERXpmbjQmY3JlYXRlX3RpbWU9MTQxNjQyNTQ2OCZub25jZT0wLjM5MTE1MzIwMzc4OTE0NDc1JnJvbGU9bW9kZXJhdG9yJmV4cGlyZV90aW1lPTE0MTY1MTE4Njg="
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
