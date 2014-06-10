//
//  TMViewController.m
//
//  Copyright (c) 2014 Tuenti Technologies S.L. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "TMViewController.h"

#import "DDLog.h"
#import "TMDebugConsole.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface TMViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textToLog;

@end

@implementation TMViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder])
    {
        [DDLog addLogger:[TMDebugConsole sharedInstance]];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.textToLog becomeFirstResponder];
}

- (IBAction)logMessageAsInfo:(id)sender
{
    DDLogInfo(@"Info: %@", self.textToLog.text);
}

- (IBAction)logMessageAsError:(id)sender
{
    DDLogError(@"Error: %@", self.textToLog.text);
}

- (IBAction)showConsole:(id)sender
{
    [self.textToLog resignFirstResponder];
    [[TMDebugConsole sharedInstance] showInView:self.view];
}

@end
