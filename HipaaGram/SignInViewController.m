//
//  SignInViewController.m
//  HIPAAgram
//
//  Created by Josh Ault on 4/28/14.
//  Copyright (c) 2014 Catalyze Inc. All rights reserved.
//

#import "SignInViewController.h"
#import "Catalyze.h"
#import "ProxyAPI.h"

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
    
    [Catalyze setApiKey:@"ios hippa.gram bd57cdc8-0661-4bc0-a053-9ba0c025cb56" applicationId:@"91bb6477-1c23-4023-bab3-2844515e97d0"];
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
    } else if ([[NSUserDefaults standardUserDefaults] valueForKey:kUserEmail]) {
        [CatalyzeUser logInWithUsernameInBackground:[[NSUserDefaults standardUserDefaults] valueForKey:kUserEmail] password:_txtPassword.text block:^(int status, NSString *response, NSError *error) {
            if (status == 404) {
                [self enableRegistration];
            } else {
                if (error) {
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Invalid username/password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
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
            [[NSUserDefaults standardUserDefaults] setValue:email.primary forKey:kUserEmail];
            [[NSUserDefaults standardUserDefaults] setValue:_txtPhoneNumber.text forKey:kPhoneNumber];
            
            [self saveToProxy];
        }
    }];
}

- (void)saveToProxy {
    [ProxyAPI saveNewUserWthUsername:[[NSUserDefaults standardUserDefaults] valueForKey:kUserEmail] usersId:[[CatalyzeUser currentUser] usersId] phoneNumber:[[NSUserDefaults standardUserDefaults] valueForKey:kPhoneNumber] password:_txtPassword.text block:^(id response, int status, NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Could not sign up: %@", error.localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Please activate your account and then sign in" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            [self disableRegistration];
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
