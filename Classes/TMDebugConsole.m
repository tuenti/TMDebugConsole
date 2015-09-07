//
//  TMDebugConsole.h
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

#import "TMDebugConsole.h"

static TMDebugConsole *sharedInstance;

static NSTimeInterval const kTMDebugConsoleMessageBufferingTime = 0.2;

static NSUInteger const kTMDebugConsoleMaximumMessageLength = 512;
static NSUInteger const kTMDebugConsoleMaximumMessages = 100;

static CGFloat const kTMDebugConsoleBackgroundAlpha = 0.9f;

static NSString *const kTMDebugConsoleDateFormat = @"HH:mm:ss.SSS";
static NSString *const kTMDebugConsoleMessageFormat = @"%@\n%@";
static NSString *const kTMDebugConsoleMessageTruncationIndicator = @"…";

static NSString *const kTMDebugConsoleTableViewCell = @"TMDebugConsoleTableViewCell";
static NSString *const kTMDebugConsoleTableViewFont = @"Courier";
static NSInteger const kTMDebugConsoleTableViewMainSection = 0;
static NSInteger const kInfiniteLines = 0;

static CGFloat const kTMDebugConsoleButtonsHeight = 44.;
static CGFloat const kTMDebugConsoleButtonsPadding = 6.;
static CGFloat const  kTMDebugConsoleHalfButtonsPadding = kTMDebugConsoleButtonsPadding / 2.f;

static CGFloat const kTMDebugConsoleTableViewCellTopMarging = 20.;
static CGFloat const kTMDebugConsoleTableViewCellBottomarging = kTMDebugConsoleButtonsHeight + kTMDebugConsoleButtonsPadding;
static CGFloat const kTMDebugConsoleTableViewCellVerticalSpacing = 5.;
static CGFloat const kTMDebugConsoleTableViewCellHorizontalPadding = 25.;

static NSString *const kTMDebugConsoleCloseButton = @"Close";
static NSString *const kTMDebugConsoleClearButton = @"Clear";
static NSString *const kTMDebugConsolePauseButtonPause = @"Pause";
static NSString *const kTMDebugConsolePauseButtonContinue = @"Paused";

@interface TMDebugConsole () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSMutableArray *messagesPendingToBeAdded;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIFont *fontForMessages;

@property (nonatomic, strong) UIScrollView *previousScrollViewWithScrollsToTopActivated;

@property (nonatomic, assign, getter = isPaused) BOOL paused;

@property (nonatomic, strong) NSArray *buttons;

@end

@interface TMDebugConsoleButton : UIButton

@end

@implementation TMDebugConsole

#pragma mark - Singleton implementation

+ (TMDebugConsole *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Initialization, deallocation and setup

- (instancetype)init
{
	if (!(self = [super init])) return nil;

	[self setUp];

	return self;
}

- (void)dealloc
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)setUp
{
	[self setUpMessagesArrays];
	[self setUpFontForMessages];
	[self setUpDateFormatter];

	[self setUpTableView];
	[self setUpButtons];
}

- (void)setUpMessagesArrays
{
	_messages = [NSMutableArray array];
	_messagesPendingToBeAdded = [NSMutableArray array];
}

- (void)setUpTableView
{
	_tableView = [[UITableView alloc] init];
	_tableView.backgroundColor = [UIColor blackColor];
	_tableView.alpha = kTMDebugConsoleBackgroundAlpha;
	_tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	_tableView.scrollsToTop = YES;
	_tableView.allowsSelection = NO;

	_tableView.delegate = self;
	_tableView.dataSource = self;

	[_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kTMDebugConsoleTableViewCell];

	if ([_tableView respondsToSelector:@selector(setSeparatorInset:)])
	{
		// iOS 7 only
		[_tableView setSeparatorInset:UIEdgeInsetsZero];
	}

	_tableView.contentInset = UIEdgeInsetsMake(kTMDebugConsoleTableViewCellTopMarging,
											   0,
											   kTMDebugConsoleTableViewCellBottomarging,
											   0);
}

- (void)setUpButtons
{
	_buttons = [self addButtons:3];
	[self setUpButton:_buttons[0] withTitle:kTMDebugConsolePauseButtonPause action:@selector(togglePauseButton:)];
	[self setUpButton:_buttons[1] withTitle:kTMDebugConsoleClearButton action:@selector(clearButtonTapped)];
	[self setUpButton:_buttons[2] withTitle:kTMDebugConsoleCloseButton action:@selector(closeButtonTapped)];
}

- (NSArray *)addButtons:(NSUInteger)buttonCount
{
	NSMutableArray *buttons = [NSMutableArray arrayWithCapacity:buttonCount];
	for (NSUInteger buttonIndex = 0; buttonIndex < buttonCount; buttonIndex++)
	{
		TMDebugConsoleButton *button = [[TMDebugConsoleButton alloc] init];
		[buttons addObject:button];
		[_tableView addSubview:button];
	}

	return [buttons copy];
}

- (void)setUpButton:(TMDebugConsoleButton *)button withTitle:(NSString *)title action:(SEL)action
{
	[button setTitle:title forState:UIControlStateNormal];
	[button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
}

- (void)setUpFontForMessages
{
	_fontForMessages = [UIFont fontWithName:kTMDebugConsoleTableViewFont size:12];
}

- (void)setUpDateFormatter
{
	_dateFormatter = [[NSDateFormatter alloc] init];
	_dateFormatter.dateFormat = kTMDebugConsoleDateFormat;
}

#pragma mark - DDLogger

- (void)logMessage:(DDLogMessage *)logMessage
{
    NSString *logMsg = [formatter formatLogMessage:logMessage];
    
    if (logMsg)
    {
        logMessage->logMsg = logMsg;
        [self scheduleLogMessage:logMessage];
    }
}

- (void)scheduleLogMessage:(DDLogMessage *)logMessage
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.messagesPendingToBeAdded addObject:logMessage];
		
		if ([self isPaused]) return;
		
		[self performSelector:@selector(flushPendingMessages)
				   withObject:nil
				   afterDelay:kTMDebugConsoleMessageBufferingTime];
	});
}

- (void)flushPendingMessages
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];

	NSArray *pendingMessages = [self.messagesPendingToBeAdded copy];
	[self.messagesPendingToBeAdded removeObjectsInArray:pendingMessages];

	[self addPendingMessages:pendingMessages];
}

- (void)addPendingMessages:(NSArray *)pendingMessages
{
	[self.messages addObjectsFromArray:pendingMessages];

	if (self.messages.count >= kTMDebugConsoleMaximumMessages)
	{
		NSRange messagesToDelete = NSMakeRange(kTMDebugConsoleMaximumMessages - 1, self.messages.count - kTMDebugConsoleMaximumMessages);
		[self.messages removeObjectsInRange:messagesToDelete];
	}

	[self.tableView reloadData];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTMDebugConsoleTableViewCell
															forIndexPath:indexPath];

    DDLogMessage *message = self.messages[self.messages.count - indexPath.row - 1];
    cell.textLabel.text = [self textForMessage:message];
    cell.textLabel.numberOfLines = kInfiniteLines;
	cell.textLabel.textColor = [self colorForMessage:message];
    cell.textLabel.font = self.fontForMessages;
	cell.textLabel.lineBreakMode = NSLineBreakByCharWrapping;
    cell.backgroundColor = [UIColor clearColor];

	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDLogMessage *message = self.messages[self.messages.count - indexPath.row - 1];
    NSString *messageText = [self textForMessage:message];
    CGSize maximumMessageSize = CGSizeMake(self.tableView.bounds.size.width - kTMDebugConsoleTableViewCellHorizontalPadding, CGFLOAT_MAX);
    CGSize messageSize = [messageText boundingRectWithSize:maximumMessageSize
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{NSFontAttributeName: self.fontForMessages}
                                                   context:nil].size;
    
    return messageSize.height + kTMDebugConsoleTableViewCellVerticalSpacing;
}

#pragma mark - Message-dependent properties

- (NSString *)textForMessage:(DDLogMessage *)message
{
    NSMutableString *logMessage = [message->logMsg mutableCopy];
	CFStringTrimWhitespace((CFMutableStringRef)logMessage);

	NSString *formattedTime = [self.dateFormatter stringFromDate:message->timestamp];

	NSString *formattedMessage = [NSString stringWithFormat:kTMDebugConsoleMessageFormat, formattedTime, logMessage];
	if ([formattedMessage length] > kTMDebugConsoleMaximumMessageLength)
	{
		NSString *truncatedMessage = [formattedMessage substringToIndex:kTMDebugConsoleMaximumMessageLength];
		formattedMessage = [truncatedMessage stringByAppendingString:kTMDebugConsoleMessageTruncationIndicator];
	}

	return formattedMessage;
}

- (UIColor *)colorForMessage:(DDLogMessage *)message
{
	UIColor *colorForMessage;

	if (message->logFlag == LOG_FLAG_ERROR)
	{
		colorForMessage = [UIColor redColor];
	}
	else if (message->logFlag == LOG_FLAG_WARN)
	{
		colorForMessage = [UIColor orangeColor];
	}
	else
	{
		colorForMessage = [UIColor whiteColor];
	}
	return colorForMessage;
}

#pragma mark - Showing / hiding the console

- (void)showInView:(UIView *)view
{
	[self disablePreviousScrollViewScrollsToTop];

	[self attatchToView:view];
}

- (UIScrollView *)disablePreviousScrollsToTopFromView:(UIView *)view
{
	static UIScrollView *previousScrollViewWithScrollsToTopActivated;

	for (UIView *subview in view.subviews)
	{
		previousScrollViewWithScrollsToTopActivated = [self disablePreviousScrollsToTopFromView:subview];

		if (previousScrollViewWithScrollsToTopActivated) return previousScrollViewWithScrollsToTopActivated;

		if ([subview respondsToSelector:@selector(scrollsToTop)]
			&& [(UIScrollView *)subview scrollsToTop]) return (UIScrollView *)subview;
	}
	return nil;
}

- (void)hide
{
    [self.tableView removeFromSuperview];
	[self enablePreviousScrollViewScrollsToTop];
}

- (BOOL)isShown
{
	return (self.tableView.superview != nil);
}

#pragma mark - Layout

- (void)attatchToView:(UIView *)view
{
	self.tableView.frame = view.bounds;
    [view addSubview:self.tableView];

	[self scrollTableViewToTop];
}

- (void)scrollTableViewToTop
{
	if ([self.messages count] == 0)
	{
		[self scrollViewDidScroll:self.tableView];
		return;
	}

	NSIndexPath *firstRowIndexPath = [NSIndexPath indexPathForRow:0
														inSection:kTMDebugConsoleTableViewMainSection];

	[self.tableView scrollToRowAtIndexPath:firstRowIndexPath
						  atScrollPosition:UITableViewScrollPositionTop
								  animated:NO];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	CGFloat buttonWidth = (self.tableView.bounds.size.width / [self.buttons count]) - kTMDebugConsoleButtonsPadding;
	CGFloat buttonY = self.tableView.contentOffset.y + self.tableView.bounds.size.height - kTMDebugConsoleButtonsHeight - kTMDebugConsoleHalfButtonsPadding;

	[self.buttons enumerateObjectsUsingBlock:^(TMDebugConsoleButton *button, NSUInteger buttonIndex, BOOL *stop) {
		CGFloat buttonX = (kTMDebugConsoleHalfButtonsPadding * (buttonIndex + 1)
						   + buttonWidth * buttonIndex
						   + kTMDebugConsoleHalfButtonsPadding * buttonIndex);
		button.frame = CGRectMake(buttonX, buttonY, buttonWidth, kTMDebugConsoleButtonsHeight);
	}];
}

#pragma mark - Multiple UIScrollView with scrollsToTop enabled handling

- (void)disablePreviousScrollViewScrollsToTop
{
	self.previousScrollViewWithScrollsToTopActivated = [self disablePreviousScrollsToTopFromView:self.tableView.superview];
	[self.previousScrollViewWithScrollsToTopActivated setScrollsToTop:NO];
}

- (void)enablePreviousScrollViewScrollsToTop
{
	[self.previousScrollViewWithScrollsToTopActivated setScrollsToTop:YES];
}

#pragma mark - Button handling

- (void)clearButtonTapped
{
	BOOL wasPaused = [self isPaused];
	self.paused = YES;

	[self setUpMessagesArrays];
	[self.tableView reloadData];

	self.paused = wasPaused;
}

- (void)togglePauseButton:(TMDebugConsoleButton *)pauseButton
{
	self.paused = !self.paused;

	pauseButton.selected = self.paused;

	if (pauseButton.selected)
	{
		[pauseButton setTitle:kTMDebugConsolePauseButtonContinue forState:UIControlStateNormal];
	}
	else
	{
		[pauseButton setTitle:kTMDebugConsolePauseButtonPause forState:UIControlStateNormal];
		dispatch_async(dispatch_get_main_queue(), ^{
			[self flushPendingMessages];
		});
	}
}

- (void)closeButtonTapped
{
	[self hide];
}

@end

static CGFloat const kDebugConsoleButtonBorderWdith = 1.0;
static CGFloat const kDebugConsoleButtonCornerRadius = 3.0;
static CGFloat const kDebugConsoleButtonTitleFontSize = 16.0;

@implementation TMDebugConsoleButton

- (instancetype)init
{
	if (!(self = [super init])) return nil;

	[self setUp];

	return self;
}

- (void)setUp
{
	self.layer.cornerRadius = kDebugConsoleButtonCornerRadius;
	self.layer.borderWidth = kDebugConsoleButtonBorderWdith ;
	self.layer.borderColor = [[UIColor whiteColor] CGColor];
	self.layer.masksToBounds = YES;

	[self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[self setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];

	UIImage *backgroundImageForNormalState = [self imageWithColor:[UIColor clearColor]];
	UIImage *backgroundImageForSelectedState = [self imageWithColor:[UIColor whiteColor]];

	[self setBackgroundImage:backgroundImageForNormalState forState:UIControlStateNormal];
	[self setBackgroundImage:backgroundImageForSelectedState forState:UIControlStateSelected];

	self.titleLabel.font = [UIFont systemFontOfSize:kDebugConsoleButtonTitleFontSize];
}

- (UIImage *)imageWithColor:(UIColor *)color
{
	__attribute__((objc_precise_lifetime)) UIColor *_color = color;

	CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
	UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
	CGContextRef context = UIGraphicsGetCurrentContext();

	CGContextSetFillColorWithColor(context, [_color CGColor]);
	CGContextFillRect(context, rect);

	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return image;
}

@end
