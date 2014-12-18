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
 Set SAMPLE_SERVER_BASE_URL to the base URL of the web server that implements
 the OpenTok PHP Getting Started Sample code (see the main README file.) This
 web service handles some OpenTok-related API calls, related to obtaining
 session IDs and tokens, and for working with archives.
 */

#define SAMPLE_SERVER_BASE_URL @"http://YOUR-SERVER-URL"

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
