//
//  ViewController.m
//  OrElse
//
//  Created by Hani Kazmi on 05/08/2014.
//  Copyright (c) 2014 Hani Kazmi. All rights reserved.
//

#import "ViewController.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *taskTextField;
@property (weak, nonatomic) IBOutlet UITextField *DateTextField;


@end

@implementation ViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
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
    NSArray *permissionsArray = @[ @"user_about_me", @"user_friends", @"read_friendlists"];
    
    [PFFacebookUtils initializeFacebook];
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        
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
    PFUser *currentUser = [PFUser currentUser];
    PFObject *task = [PFObject objectWithClassName:@"Task"];
    task[@"task"] = self.taskTextField.text;
    task[@"date"] = self.DateTextField.text;
    task[@"creatorID"] = currentUser.username;
  
    
    [FBWebDialogs
     presentRequestsDialogModallyWithSession:[FBSession activeSession]
     message:@"Frape Me"
     title:@"OrElse"
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
                    task[@"supervisorID"] = urlParams[@"to%5B0%5D"];
                    [task saveInBackground];
                 }
             }
         }
     }];

}
- (IBAction)showMyTaks {
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection,
                                                           NSDictionary<FBGraphUser> *me,
                                                           NSError *error) {
        if(error) {

            return;
        }
        PFQuery *query = [PFQuery queryWithClassName:@"Task"];
        [query whereKey:@"supervisorID" equalTo:me.objectID];
        NSLog(@"My Task are %@", [query findObjects]);
    }];

    
}

@end
