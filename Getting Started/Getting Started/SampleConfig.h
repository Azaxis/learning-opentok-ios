//
//  Config.h
//  Getting Started
//
//  Created by Swartz on 12/1/14.
//  Copyright (c) 2014 OpenTok. All rights reserved.
//

#ifndef Getting_Started_Config_h
#define Getting_Started_Config_h

/*
 Set SESSION_CREDENTIALS_URL to the URL for your web service that returns
 the OpenTok session ID, API key, and token to be used by this client.
 The web service should return the data as JSON in the following form:
 
 {
 "sessionId":"2_MX40NDQ0MzEyMn5-fn4",
 "apiKey":"12345",
 "token":"T1==cGFydG5lcl9pZD00jg="
 }
 
 Set START_ARCHIVE_URL to the URL for your webservice that starts recording
 the session to an OpenTok archive:
 
 Set STOP_ARCHIVE_URL to the URL for your webservice that stops recording
 the session to an OpenTok archive:
 
 Set PLAYBACK_ARCHIVE_URL to the URL for your the page that plays back archive
 recordings. Append the URL with a query string containing the archive ID:
 */

#define SESSION_CREDENTIALS_URL @"http://YOUR-SERVER-URL/session"
#define START_ARCHIVE_URL @"http://YOUR-SERVER-URL/start/"
#define STOP_ARCHIVE_URL @"http://YOUR-SERVER-URL/stop/"
#define PLAYBACK_ARCHIVE_URL @"http://YOUR-SERVER-URL/"

/*
 For test purposes, if you do not have a webservice set up to provide OpenTok
 session information, you can set the following to your OpenTok API key,
 a test session ID, and a test token, which you can obtain at the OpenTok
 dashboard: https://dashboard.tokbox.com
 
 Each of these should be set as strings (not nil), such as @"abcdef"
 */

#define API_KEY nil
#define SESSION_ID nil
#define TOKEN nil

#endif
