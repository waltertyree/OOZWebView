//
//  OOZWebView.h
//
//  Created by Roberto Brega on 4/19/10.
//  Copyright 2010 OneOverZero GmbH. All rights reserved.
//	Modifications by Walter Tyree in October 2010.
//	Copyright 2010 Tyree Apps, LLC all rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface OOZWebView : UIViewController <UIWebViewDelegate,MFMailComposeViewControllerDelegate>{
	
	NSMutableData *receivedData;
	NSURLConnection *connection;
	
	BOOL userInteractionEnabled;
	NSString *resourceFilename;
	NSString *resourceURL;
	NSString *baseURL;
	NSString *navControllerBackgroundImage;
	NSString *navControllerTitle;
	
	
	IBOutlet UIWebView *webView;
	IBOutlet UIView *navControllerTitleView;
	IBOutlet UIImageView *navControllerBackgroundImageView;
	IBOutlet UILabel *navControllerTitleLabel;
	IBOutlet UIButton *backButton; //Added by TA July
	IBOutlet UIActivityIndicatorView *activityIndicator; //Added by TA October
}

@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSURLConnection *connection;

@property BOOL userInteractionEnabled;
@property (nonatomic, retain) NSString *resourceFilename;
@property (nonatomic, retain) NSString *resourceURL;
@property (nonatomic, retain) NSString *baseURL;
@property (nonatomic, retain) NSString *navControllerBackgroundImage;
@property (nonatomic, retain) NSString *navControllerTitle;

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIView *navControllerTitleView;
@property (nonatomic, retain) IBOutlet UIImageView *navControllerBackgroundImageView;
@property (nonatomic, retain) IBOutlet UILabel *navControllerTitleLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator; //Added by TA October

-(id)initWithTabInfo:(NSDictionary *)tabInfo topLevelTab:(NSDictionary *)topLevelTab;
-(IBAction)backOne:(id)sender; //Added by TA
-(void)displayLocalResource; //Added by TA
- (void) sendEmailWithSubject:(NSString *)subject body:(NSString *)body to:(NSString *)toPerson cc:(NSString *)ccPerson; //Added to handle Mail


@end

