/*
 ACTcpStreamConnection.m
 
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

@interface ACTcpStreamConnection ()
{
    CFWriteStreamRef _write;
    CFReadStreamRef _read;
    int _socket;
}

@end

@implementation ACTcpStreamConnection

- (instancetype)initWithSocket:(int)socket
{
    self = [super init];
    if (self)
    {
        _socket = socket;
        _read = NULL;
        _write = NULL;
        
        CFStreamCreatePairWithSocket(kCFAllocatorDefault, socket, &_read, &_write);
        
        if (_read && _write)
        {
            // socket should be closed if streams are closed
            CFReadStreamSetProperty(_read, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
            CFWriteStreamSetProperty(_write, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
            
            Boolean success = CFReadStreamOpen(_read);
            success = CFWriteStreamOpen(_write);
            
            _readStream = (__bridge NSInputStream*)_read;
            _writeStream = (__bridge NSOutputStream*)_write;
        }
    }
    return self;
}

- (instancetype)initWithWriteStream:(CFWriteStreamRef)write readStream:(CFReadStreamRef)read
{
    self = [super init];
    if (self)
    {
        _socket = -1;
        _read = read;
        _write = write;
        
        _readStream = (__bridge NSInputStream*)_read;
        _writeStream = (__bridge NSOutputStream*)_write;
    }
    return self;
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
        // check if both streams are working
        BOOL a = self.readStream.streamStatus == NSStreamStatusClosed ||
        self.readStream.streamStatus == NSStreamStatusError ||
        self.readStream.streamStatus == NSStreamStatusNotOpen;
        
        BOOL b = self.writeStream.streamStatus == NSStreamStatusClosed ||
        self.writeStream.streamStatus == NSStreamStatusError ||
        self.writeStream.streamStatus == NSStreamStatusNotOpen;
        
        isConnected = !a && !b;
    }
    
    return isConnected;
}

#pragma mark - public

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
    
    _socket = -1;
}

#pragma mark - private

- (void)freeRead
{
    if (_read != NULL) {
        CFBridgingRelease(_read);
        _read = NULL;
    }
}

- (void)freeWrite
{
    if (_write != NULL) {
        CFBridgingRelease(_write);
        _write = NULL;
    }
}

@end
