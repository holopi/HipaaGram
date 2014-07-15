//
//  SignInViewController.m
//  HIPAAgram
//
//  Created by Josh Ault on 4/28/14.
//  Copyright (c) 2014 Catalyze Inc. All rights reserved.
//

#import "SignInViewController.h"
#import "Catalyze.h"

@interface SignInViewController ()

@end

@implementation SignInViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBarHidden = YES;
    
    [Catalyze setApiKey:@"ios io.catalyze.HipaaGram e16cd572-5a77-4cdf-b9f3-33092da85d0c" applicationId:@"ab2a7a91-bc8e-4159-87c5-8e51f6fcc70b"];
    [Catalyze setLoggingLevel:kLoggingLevelDebug];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)enableRegistration {
    _btnRegister.alpha = 1.0f;
    _btnRegister.userInteractionEnabled = YES;
    
    [_btnSignIn setTitleColor:_btnSignIn.backgroundColor forState:UIControlStateNormal];
    _btnSignIn.backgroundColor = [UIColor whiteColor];
    
    [UIView animateWithDuration:0.3 animations:^{
        _txtPhoneNumber.alpha = 1.0f;
        _txtPhoneNumber.userInteractionEnabled = YES;
        
        CGRect frame = _btnSignIn.frame;
        frame.origin.y = _btnRegister.frame.origin.y + _btnRegister.frame.size.height + 8;
        [_btnSignIn setFrame:frame];
    }];
}

- (void)disableRegistration {
    [UIView animateWithDuration:0.3 animations:^{
        _txtPhoneNumber.alpha = 0.0f;
        _txtPhoneNumber.userInteractionEnabled = NO;
        
        CGRect frame = _btnSignIn.frame;
        frame.origin.y = _btnRegister.frame.origin.y;
        [_btnSignIn setFrame:frame];
    } completion:^(BOOL finished) {
        _btnRegister.alpha = 0.0f;
        _btnRegister.userInteractionEnabled = NO;
        
        _btnSignIn.backgroundColor = [_btnSignIn titleColorForState:UIControlStateNormal];
        [_btnSignIn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }];
}

- (IBAction)signIn:(id)sender {
    if (_btnRegister.alpha == 1.0f) {
        [self disableRegistration];
    } else if ([[NSUserDefaults standardUserDefaults] valueForKey:kUserUsername]) {
        [CatalyzeUser logInWithUsernameInBackground:[[NSUserDefaults standardUserDefaults] valueForKey:kUserUsername] password:_txtPassword.text block:^(int status, NSString *response, NSError *error) {
            if (status == 404) {
                [self enableRegistration];
            } else {
                if (error) {
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Invalid username / password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                } else {
                    [_delegate signInSuccessful];
                }
            }
        }];
    } else {
        [self enableRegistration];
    }
}

- (IBAction)registerUser:(id)sender {
    if (_txtPhoneNumber.text.length == 0 || _txtPassword.text.length == 0) {
        return;
    }
    Name *name = [[Name alloc] init];
    name.firstName = @"HipaaGram";
    name.lastName = @"User";
    
    Email *email = [[Email alloc] init];
    email.primary = [self randomEmail];
    
    [CatalyzeUser signUpWithUsernameInBackground:_txtPhoneNumber.text email:email name:name password:_txtPassword.text block:^(int status, NSString *response, NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Could not sign up: %@", error.localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        } else {
            NSDictionary *body = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            [[NSUserDefaults standardUserDefaults] setValue:[body valueForKey:@"usersId"] forKey:@"usersId"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSUserDefaults standardUserDefaults] setValue:email.primary forKey:kUserEmail];
            [[NSUserDefaults standardUserDefaults] setValue:_txtPhoneNumber.text forKey:kUserUsername];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self addToContacts:_txtPhoneNumber.text usersId:[body valueForKey:@"usersId"]];
            
            [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Please activate your account and then sign in" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            [self disableRegistration];
        }
    }];
}

- (void)addToContacts:(NSString *)username usersId:(NSString *)usersId {
    CatalyzeObject *contact = [CatalyzeObject objectWithClassName:@"contacts"];
    [contact setValue:username forKey:@"username"];
    [contact setValue:usersId forKey:@"usersId"];
    [contact createInBackgroundWithBlock:^(BOOL succeeded, int status, NSError *error) {
        if (!succeeded) {
            NSLog(@"Was not added to the contacts custom class!");
        }
    }];
}

// from http://stackoverflow.com/questions/2633801/generate-a-random-alphanumeric-string-in-cocoa
- (NSString *)randomEmail {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyz0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:10];
    
    for (int i=0; i<10; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    
    return [NSString stringWithFormat:@"josh+%@@catalyze.io", randomString];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
