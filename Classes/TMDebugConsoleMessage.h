//
//  TMDebugConsoleMessage.h
//  Messenger
//
//  Created by cestebanez on 07/09/15.
//  Copyright (c) 2015 Tuenti Technologies S.L. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMDebugConsoleMessage : NSObject
{
	// The public variables below can be accessed directly (for speed).
	// For example: logMessage->logLevel

@public
	NSString *_logMessage;
	NSDate *_timestamp;
	int _logFlag;
}

- (instancetype)initWithLogMessage:(NSString *)logMessage timestamp:(NSDate *)timestamp logFlag:(int)logFlag;

@end
