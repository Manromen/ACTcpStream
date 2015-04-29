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
{
    CFWriteStreamRef write;
    CFReadStreamRef read;
}

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
        
        write = NULL;
        read = NULL;
    }
    return self;
}

+ (instancetype) tcpStreamWithHostname:(NSString *)hostname port:(int)port
{
    return [[self alloc] initWithHostname:hostname port:port];
}

- (void)dealloc
{
    // we need to disconnect to free some system resources
    // and to free our used memory
    [self disconnect];
}

#pragma mark - getter / setter

- (BOOL) isConnected
{
    BOOL isConnected = NO;
    
    // check if we have streams
    if (self.readStream && self.writeStream)
    {
        // check if both streams are open
        isConnected = (self.readStream.streamStatus == NSStreamStatusOpen &&
                       self.writeStream.streamStatus == NSStreamStatusOpen);
    }
    
    return isConnected;
}

#pragma mark - public

- (ACTcpStreamClientConnect) connect
{
    // if we are connected - we just have to disconnect first
    // free resources etc.
    [self disconnect];
    
    UInt32 port = (UInt32)self.port;
    
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (__bridge CFStringRef)self.hostname, port, &read, &write);
    
    if (read == NULL || write == NULL)
    {
        [self freeRead];
        [self freeWrite];
        
        return ACTcpStreamClientConnectFailed;
    }
    
    Boolean success = CFWriteStreamOpen(write);
    _writeStream = (__bridge NSOutputStream*)write;
    
    success = CFReadStreamOpen(read);
    _readStream = (__bridge NSInputStream*)read;
    
    return ACTcpStreamClientConnectSuccess;
}

- (void) disconnect
{
    // close reading end
    [self.readStream close];
    _readStream = nil;
    [self freeRead];
    
    // close writing end
    [self.writeStream close];
    _writeStream = nil;
    [self freeWrite];
}

#pragma mark - private

- (void)freeRead
{
    if (read != NULL) {
        CFBridgingRelease(read);
        read = NULL;
    }
}

- (void)freeWrite
{
    if (write != NULL) {
        CFBridgingRelease(write);
        write = NULL;
    }
}

@end
