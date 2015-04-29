/*
 ACTcpStreamClient.m
 
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

#import "ACTcpStreamClient.h"

@interface ACTcpStreamClient ()

@property (nonatomic, strong) NSString *hostname;
@property (nonatomic) NSInteger port;

@end

@implementation ACTcpStreamClient

- (instancetype) initWithHostname:(NSString *)hostname port:(int)port
{
    self = [super init];
    if (self)
    {
        _hostname = hostname;
        _port = port;
    }
    return self;
}

#pragma mark - public

- (ACTcpStreamConnection *) connect
{
    CFWriteStreamRef write;
    CFReadStreamRef read;
    UInt32 port = (UInt32)self.port;
    
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (__bridge CFStringRef)self.hostname, port, &read, &write);
    
    if (read == NULL || write == NULL)
    {
        if (read != NULL)
            CFBridgingRelease(read);
        
        if (write != NULL)
            CFBridgingRelease(write);
        
        return nil;
    }
    
    Boolean successRead = CFReadStreamOpen(read);
    Boolean successWrite = CFWriteStreamOpen(write);
    
    if (!successRead || !successWrite)
    {
        CFBridgingRelease(read);
        CFBridgingRelease(write);
        return nil;
    }
    
    ACTcpStreamConnection *connection;
    connection = [[ACTcpStreamConnection alloc] initWithWriteStream:write
                                                         readStream:read];
    
    return connection;
}

@end
