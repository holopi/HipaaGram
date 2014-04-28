//
//  SignInViewController.h
//  HIPAAgram
//
//  Created by Josh Ault on 4/28/14.
//  Copyright (c) 2014 Catalyze Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SignInDelegate <NSObject>

- (void)signInSuccessful;

@end

@interface SignInViewController : UIViewController<UITextFieldDelegate>
@property (strong, nonatomic) id<SignInDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *txtPhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnRegister;
@property (weak, nonatomic) IBOutlet UIButton *btnSignIn;
- (IBAction)signIn:(id)sender;
- (IBAction)registerUser:(id)sender;

@end
