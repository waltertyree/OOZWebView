//
//  OOZWebView.m
//
//  Created by Roberto Brega on 4/19/10.
//  Copyright 2010 OneOverZero GmbH. All rights reserved.
//	Modifications by Walter Tyree in October 2010.
//	Copyright 2010 Tyree Apps, LLC all rights reserved.
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
@synthesize activityIndicator;

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
#pragma mark Handle mailto: links
// Handling mailto links is extracted from Stephan Burlot's github repo https://github.com/sburlot/browserviewcontroller
//  Created by Stephan Burlot, Coriolis Technologies, http://www.coriolis.ch on 29.10.09.
//
// This work is licensed under the Creative Commons Attribution License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by/3.0/
// or send a letter to Creative Commons, 171 Second Street, Suite 300, San Francisco, California, 94105, USA.
//
- (void) sendEmailWithSubject:(NSString *)subject body:(NSString *)body to:(NSString *)toPerson cc:(NSString *)ccPerson
{
/*	NetworkStatus internetConnectionStatus;
	NetworkStatus remoteHostStatus;
	
	remoteHostStatus         = [[Reachability sharedReachability] remoteHostStatus];
	internetConnectionStatus = [[Reachability sharedReachability] internetConnectionStatus];
	if ((internetConnectionStatus == NotReachable) && (remoteHostStatus == NotReachable)) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", nil)
														message:NSLocalizedString(@"You have no internet connection.", nil) 
													   delegate:nil 
											  cancelButtonTitle:NSLocalizedString(@"OK", nil) 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
*/	
#if	!TARGET_IPHONE_SIMULATOR
	if (![MFMailComposeViewController canSendMail]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", nil)
														message:NSLocalizedString(@"Your iPhone is not configured to send emails.", nil) 
													   delegate:nil 
											  cancelButtonTitle:NSLocalizedString(@"OK", nil) 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
#endif
	
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	
	picker.mailComposeDelegate = self;
	
	[picker setToRecipients:[NSArray arrayWithObject:toPerson]];
	[picker setCcRecipients:[NSArray arrayWithObject:ccPerson]];
	[picker setSubject:subject];
	
	[picker setMessageBody:body isHTML:NO];
	
	[self presentModalViewController:picker animated:YES];
	[picker release];
}

//==========================================================================================
// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{
	NSString *alertMessage = nil;
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			break;
		case MFMailComposeResultSaved:
			break;
		case MFMailComposeResultSent:
			alertMessage = NSLocalizedString(@"Your message has been sent.", nil);
			break;
		case MFMailComposeResultFailed:
			alertMessage = NSLocalizedString(@"Your message could not be sent.", nil);
			break;
		default:
			alertMessage = NSLocalizedString(@"Your message could not be sent.", nil);
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
	if (alertMessage != nil) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sending Email", nil) 
														message:alertMessage 
													   delegate:nil 
											  cancelButtonTitle:NSLocalizedString(@"OK", nil)
											  otherButtonTitles:nil,nil];
		[alert show];
		[alert release];
	}
	
}

//==========================================================================================
- (void) sendMailWithURL:(NSURL *)url
{
	// method to split an url "mailto:sburlot@coriolis.ch?cc=info@coriolis.ch&subject=Hello%20From%20iPhone&body=The message's first paragraph.%0A%0aSecond paragraph.%0A%0AThird Paragraph."
	// into separate elements
	
	NSString *toPerson = @"";
	NSString *ccPerson = @"";;
	NSString *subject = @"";
	NSString *body = @"";
	
	NSMutableString *urlString = [NSMutableString stringWithString:[url absoluteString]];
	[urlString replaceOccurrencesOfString:@"mailto:" withString:@"" options:0 range:NSMakeRange(0, [urlString length])];
	
	if ([urlString rangeOfString:@"?"].location != NSNotFound) {
		toPerson = [[urlString componentsSeparatedByString:@"?"] objectAtIndex:0];
		NSString *query = [[urlString componentsSeparatedByString:@"?"] objectAtIndex:1];
		
		if (query && [query length]) {
			NSArray *itemsOfURL = [query componentsSeparatedByString:@"&"];
			for (NSString *queryItem in itemsOfURL) {
				NSArray *queryElements = [queryItem componentsSeparatedByString:@"="];
				NSLog(@"queryElements: %@", queryElements);
				if ([[queryElements objectAtIndex:0] isEqualToString:@"to"])
					toPerson = [[queryElements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				if ([[queryElements objectAtIndex:0] isEqualToString:@"cc"])
					ccPerson = [[queryElements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				if ([[queryElements objectAtIndex:0] isEqualToString:@"subject"])
					subject = [[queryElements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				if ([[queryElements objectAtIndex:0] isEqualToString:@"body"])
					body = [[queryElements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			}
		}
	} else {
		toPerson = urlString;
	}
	
	NSLog(@"to: %@", toPerson);
	NSLog(@"cc: %@", ccPerson);
	NSLog(@"subject: %@", subject);
	NSLog(@"body: %@", body);
	[self sendEmailWithSubject:subject body:body to:toPerson cc:ccPerson];
	
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
// Back button functionality added by TA
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
	[activityIndicator stopAnimating]; //Added in October to turn off UIActivity Indicator Spinner
	NSString *filePath = [[NSBundle mainBundle] pathForResource:[[self.resourceFilename lastPathComponent] stringByDeletingPathExtension] ofType:[self.resourceFilename pathExtension]];
	NSString* data = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
	[self.webView loadHTMLString:data baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];
}

- (void)viewDidLoad
{
		[activityIndicator startAnimating]; //Added in October to start the UIActivity Indicator Spinner
	self.webView.delegate = self; //Added by TA
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
	[activityIndicator stopAnimating]; //TA Added in October to turn off spinner
   	NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
	if ((self.baseURL==nil) || ([self.baseURL length]==0)) {
		[self.webView loadData:self.receivedData MIMEType:@"text/html" textEncodingName: @"UTF-8" baseURL:[[NSURL URLWithString:self.resourceURL] baseURL]];
	} else {
		[self.webView loadData:self.receivedData MIMEType:@"text/html" textEncodingName: @"UTF-8" baseURL:[NSURL URLWithString:self.baseURL]];
	}
	[self.webView setUserInteractionEnabled:self.userInteractionEnabled];
	[self.webView setScalesPageToFit:YES];
 

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
   
	[activityIndicator stopAnimating]; //TA Added in October to turn off spinner
    	// load placeholder
	[self displayLocalResource];
}
#pragma mark -
#pragma mark UIWebView Delegate

//TA added delegate method to check to see if the user clicked a hyperlink so we could show the back button
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
	
	NSURL *url = [request URL];
	
	if ([[url scheme] isEqualToString:@"mailto"]) {
		[self sendMailWithURL:url];
		return NO;
	}
	
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		backButton.hidden = NO;
		[activityIndicator startAnimating];
	}
	return YES;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[activityIndicator stopAnimating];
}



#pragma mark -
#pragma mark Memory management

- (void)dealloc 
{
	//Took the release out of the code above and moved it down here to account for an edge memory leak.
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
