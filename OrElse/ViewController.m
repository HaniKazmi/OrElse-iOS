//
//  ViewController.m
//  OrElse
//
//  Created by Hani Kazmi on 05/08/2014.
//  Copyright (c) 2014 Hani Kazmi. All rights reserved.
//

#import "ViewController.h"
#import <Parse/Parse.h>

@interface ViewController ()

@end

@implementation ViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    FBLoginView *loginView = [[FBLoginView alloc] init];
    loginView.readPermissions = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location", @"read_friendlists", @"friends_hometown", @"friends_birthday",@"friends_location", @"user_friends", @"publish_actions"];
    [self.view addSubview:loginView];
   // [self loginButtonTouchHandler:nil];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

- (IBAction)loginButtonTouchHandler:(id)sender  {
    // The permissions requested from the user
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils initializeFacebook];
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
       // [_activityIndicator stopAnimating]; // Hide loading indicator
        
        if (!user) {
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
            }

        }}];
}

- (IBAction)sendMessageButtonHandler:(id)sender  {
    // The permissions requested from the user
    FBRequest* friendsRequest = [FBRequest requestForGraphPath:@"/me/taggable_friends"];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
         
     //   NSLog([result description]);
    }];
    
//    FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
    
    [FBWebDialogs
     presentRequestsDialogModallyWithSession:[FBSession activeSession]
     message:@"Work"
     title:@"Hello"
     parameters:nil
     handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
         if (error) {
             // Error launching the dialog or sending the request.
             NSLog(@"Error sending request.");
         } else {
             if (result == FBWebDialogResultDialogNotCompleted) {
                 // User clicked the "x" icon
                 NSLog(@"User canceled request.");
             } else {
                 // Handle the send request callback
                 NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                 if (![urlParams valueForKey:@"request"]) {
                     // User clicked the Cancel button
                     NSLog(@"User canceled request.");
                 } else {
                     // User clicked the Send button
                     NSString *requestID = [urlParams valueForKey:@"request"];
                     NSLog(@"Request ID: %@", requestID);
                 }
             }
         }
     }];
//    params.link =
//    [NSURL URLWithString:@"https://developers.facebook.com/docs/ios/share/"];
//    params.name = @"OrElse";
//    params.caption = @"Hi Ammaar.";
//    params.picture = [NSURL URLWithString:@"http://i.imgur.com/g3Qc1HN.png"];
//    params.linkDescription = @"Did this work?";
//    
//    [FBDialogs presentMessageDialogWithLink:[NSURL URLWithString:@"https://developers.facebook.com/ios"]
//                                    handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
//                                        if(error) {
//                                            // An error occurred, we need to handle the error
//                                            // See: https://developers.facebook.com/docs/ios/errors
//                                            NSLog([NSString stringWithFormat:@"Error messaging link: %@", error.description]);
//                                        } else {
//                                            // Success
//                                            NSLog(@"result %@", results);
//                                        }
//                                    }];

}

@end
