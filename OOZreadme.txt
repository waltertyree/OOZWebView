//
//  OOZWebView (v1.0)
//
//  Created by Roberto Brega on 4/19/10.
//  Copyright 2010 OneOverZero GmbH. All rights reserved.
//

Description: This plugin allows for the display of a remote HTML page inside a TapLynx tab. If no conncection can be established it can fallbacks to a local resource.

Configuration parameters for TapLynx "tab" (NCConfig.plist)
"Title": The title of the view
"NavController_backgroundImage": The image used as a background for the navigation controller (aka titlebar)
"ShortTitle": The title of the tab
"TabImageName": The name of the image used for the tab icon
"customViewControllerClass": "OOZWebView"
"resourceFilename": the name of the local resource that should be either a) loaded or b) fallback-to if no connection can be established
"resourceURL": the url of the remote resource that should be fetched and displayed
"baseURL": the base url, i.e. the absolute url that serves as a base for relative requests found inside "resourceURL"
"userInteractionDisabled": YES|NO - if YES it prevents scrolling (and link activation, of course)

Feedback is welcome at roberto.brega@oneoverzero.net