//
//  OOZWebView.m
//
//  Created by Roberto Brega on 4/19/10.
//  Copyright 2010 OneOverZero GmbH. All rights reserved.
//

#import "OOZWebView.h"

@implementation OOZWebView

// ivars
@synthesize receivedData;
@synthesize connection;
@synthesize userInteractionEnabled;
@synthesize resourceFilename;
@synthesize resourceURL;
@synthesize baseURL;
@synthesize navControllerTitle;
@synthesize navControllerBackgroundImage;

// outlets
@synthesize webView;
@synthesize navControllerTitleView;
@synthesize navControllerBackgroundImageView;
@synthesize navControllerTitleLabel;

#pragma mark -
#pragma mark Initialize for TapLynx

-(id)initWithTabInfo:(NSDictionary *)tabInfo topLevelTab:(NSDictionary *)topLevelTab {
	// cache navcontroller backgroundimage (TapLynx compatible)
	self.navControllerBackgroundImage = [tabInfo objectForKey:@"NavController_backgroundImage"];
	// cache navcontroller title (TapLynx compatible)
	self.navControllerTitle = [tabInfo objectForKey:@"Title"];
	// cache resource filename  (TapLynx compatible)
	self.resourceFilename = [tabInfo objectForKey:@"resourceFilename"];
	// cache resource URL (new)
	self.resourceURL = [tabInfo objectForKey:@"resourceURL"];
	// cache base URL (new)
	self.baseURL = [tabInfo objectForKey:@"baseURL"];
	// cache userteraction enabled (new)
	self.userInteractionEnabled = ![tabInfo objectForKey:@"userInteractionDisabled"];
	// return self
	return [self initWithNibName:@"OOZWebView" bundle:nil];
}

#pragma mark -
#pragma mark Lifetime of ciew controller

- (void)viewWillAppear:(BOOL)animated
{
	// set navcontroller backgroundimage (TapLynx compatible)
	if ((self.navControllerBackgroundImage!=nil) && ([self.navControllerBackgroundImage length]>0)) {
		[self.navControllerBackgroundImageView setImage:[UIImage imageNamed:self.navControllerBackgroundImage]];
	} else {
		[self.navControllerBackgroundImageView setHidden:YES];
	}
	// set navcontroller title (TapLynx compatible)
	if ((self.navControllerTitle!=nil) && ([self.navControllerTitle length]>0)) {
		[self.navControllerTitleLabel setText:self.navControllerTitle];
	} else {
		[self.navControllerTitleLabel setHidden:YES];
	}
	// set titleview
	self.navigationItem.titleView = self.navControllerTitleView;
}

- (void)backOne:(id)sender{
	if ([webView canGoBack]) {
		// There's a valid webpage to go back to, so go there
		[webView goBack];
	} else {
		// You've reached the end of the line, so reload your own data
		// First hide he back button
		backButton.hidden = YES;
		// if a remote url is specified, try to fetch 
		if ((self.resourceURL!=nil) && ([self.resourceURL length]>0)) {
			NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:self.resourceURL]];
			NSURLConnection *tempConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
			self.connection = tempConnection;
			[tempConnection release];
			if (self.connection != nil) {
				self.receivedData = [[NSMutableData data] retain];
			} else {
				[self displayLocalResource];
			}
			
		} else {
			[self displayLocalResource];
		}
	}
}

- (void)displayLocalResource
{
	
	NSString *filePath = [[NSBundle mainBundle] pathForResource:[[self.resourceFilename lastPathComponent] stringByDeletingPathExtension] ofType:[self.resourceFilename pathExtension]];
	NSString* data = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
	[self.webView loadHTMLString:data baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];
}

- (void)viewDidLoad
{
	self.webView.delegate = self;
	// set navcontroller backgroundimage (TapLynx compatible)
	if ((self.navControllerBackgroundImage!=nil) && ([self.navControllerBackgroundImage length]>0)) {
		[self.navControllerBackgroundImageView setImage:[UIImage imageNamed:self.navControllerBackgroundImage]];
	} else {
		[self.navControllerBackgroundImageView setHidden:YES];
	}
	// set navcontroller title (TapLynx compatible)
	if ((self.navControllerTitle!=nil) && ([self.navControllerTitle length]>0)) {
		[self.navControllerTitleLabel setText:self.navControllerTitle];
	} else {
		[self.navControllerTitleLabel setHidden:YES];
	}
	// set titleview
	self.navigationItem.titleView = self.navControllerTitleView;
	// if a remote url is specified, try to fetch 
	if ((self.resourceURL!=nil) && ([self.resourceURL length]>0)) {
		NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:self.resourceURL]] ;
		NSURLConnection *tempConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self] ;
		self.connection = tempConnection;
		[tempConnection release];
		if (self.connection != nil) {
			self.receivedData = [[NSMutableData data] retain];
		} else {
			[self displayLocalResource];
		}
		//[connection release];
	} else {
		[self displayLocalResource];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
	if ((self.baseURL==nil) || ([self.baseURL length]==0)) {
		[self.webView loadData:self.receivedData MIMEType:@"text/html" textEncodingName: @"UTF-8" baseURL:[[NSURL URLWithString:self.resourceURL] baseURL]];
	} else {
		[self.webView loadData:self.receivedData MIMEType:@"text/html" textEncodingName: @"UTF-8" baseURL:[NSURL URLWithString:self.baseURL]];
	}
	[self.webView setUserInteractionEnabled:self.userInteractionEnabled];
	[self.webView setScalesPageToFit:YES];
    // release the connection, and the data object
   // [connection release];
   //[receivedData release];

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // release the connection, and the data object
    //[connection release];
    // receivedData is declared as a method instance elsewhere
   
    // load placeholder
	[self displayLocalResource];
}
#pragma mark -
#pragma mark UIWebView Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		backButton.hidden = NO;
	}
	return YES;
}



#pragma mark -
#pragma mark Memory management

- (void)dealloc 
{
	[receivedData release];
	[connection release];
	// ivars
	self.resourceFilename = nil;
	self.resourceURL = nil;
	self.baseURL = nil;
	self.navControllerBackgroundImage = nil;
	self.navControllerTitle = nil;
	self.webView = nil;
	self.navControllerTitleView = nil;
	self.navControllerBackgroundImageView = nil;
	self.navControllerTitleLabel = nil;
	// super
	[super dealloc];
}

@end