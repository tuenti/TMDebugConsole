//
//  TMDebugConsoleMessage.h
//  Messenger
//
//  Created by cestebanez on 07/09/15.
//  Copyright (c) 2015 Tuenti Technologies S.L. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMDebugConsoleMessage : NSObject

@property (nonatomic, copy, readonly) NSString *logMessage;
@property (nonatomic, readonly) NSDate *timestamp;
@property (nonatomic, readonly) int logFlag;

- (instancetype)initWithLogMessage:(NSString *)logMessage timestamp:(NSDate *)timestamp logFlag:(int)logFlag;

@end
