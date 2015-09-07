//
//  TMDebugConsoleMessage.m
//  Messenger
//
//  Created by cestebanez on 07/09/15.
//  Copyright (c) 2015 Tuenti Technologies S.L. All rights reserved.
//

#import "TMDebugConsoleMessage.h"

@implementation TMDebugConsoleMessage

- (instancetype)initWithLogMessage:(NSString *)logMessage timestamp:(NSDate *)timestamp logFlag:(int)logFlag
{
	self = [super init];
	if (self)
	{
		_logMessage = [logMessage copy];
		_timestamp = [timestamp copy];
		_logFlag = logFlag;
	}
	return self;
}

@end
