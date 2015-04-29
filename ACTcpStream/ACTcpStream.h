/*
 ACTcpStream.h
 
 Created by Ralph-Gordon Paul on 29.04.15.
 -------------------------------------------------------------------------------
 The MIT License (MIT)
 
 Copyright (c) 2015 appcom interactive GmbH. All rights reserved.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 -------------------------------------------------------------------------------
 */

#import "ACTcpStreamConnection.h"
#import "ACTcpStreamServer.h"
#import "ACTcpStreamClient.h"

typedef enum : NSUInteger {
    //! Don't show any logs
    ACTcpStreamLogLevelOff = 0,
    //! Only shows Errors - Default on Release build
    ACTcpStreamLogLevelError,
    //! Shows more debug infos - Default on Debug build
    ACTcpStreamLogLevelDebug
} ACTcpStreamLogLevel;

@interface ACTcpStream : NSObject

@property (nonatomic) ACTcpStreamLogLevel logLevel;

/*!
 @brief A singleton ACTcpStream. Setting options here will affect all other
        ACTcpStream classes.
 */
+ (instancetype)defaultTcpStream;

@end