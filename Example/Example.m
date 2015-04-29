/*
 Example.m
 
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

#import "Example.h"

#import "ACTcpStream.h"

@interface Example () <ACTcpStreamServerDelegate>

@property (nonatomic) BOOL isServer;
@property (nonatomic) BOOL isClient;
@property (nonatomic, strong) NSString *hostname;
@property (nonatomic) int port;

@end

@implementation Example

- (instancetype) initServerWithPort:(int)port
{
    self = [super init];
    if (self)
    {
        _isServer = YES;
        _isClient = NO;
        _port = port;
    }
    return self;
}

- (instancetype) initClientWithHostname:(NSString *)hostname port:(int)port
{
    self = [super init];
    if (self)
    {
        _isServer = NO;
        _isClient = YES;
        _port = port;
        _hostname = hostname;
    }
    return self;
}

- (void)run
{
    if (self.isServer)
        [self runServer];
    else
        [self runClient];
}

- (void)runClient
{
    ACTcpStreamClient *client;
    client = [[ACTcpStreamClient alloc] initWithHostname:self.hostname
                                                    port:self.port];
    ACTcpStreamConnection *connection = [client connect];
    
    if (!connection)
    {
        NSLog(@"Couldn't connect");
        return;
    }
    
    NSFileHandle *kbd = [NSFileHandle fileHandleWithStandardInput];
    uint8_t buffer[1024];
    NSInteger len = 0;
    
    while (connection.isConnected)
    {
        @autoreleasepool
        {
            fprintf(stdout, "input: ");
            
            // get some input from user - stdin
            
            NSData *inputData = [kbd availableData];
            
            // send the input to the server
            len = [connection.writeStream write:inputData.bytes
                                maxLength:inputData.length];
            if (len == -1)
            {
                NSLog(@"Error writing to stream: %@", connection.writeStream.streamError);
                continue;
            }
            
            
            NSLog(@"written %li bytes", (long)len);
            
            // receive data from server
            
            
            len = [connection.readStream read:buffer maxLength:1024];
            
            if (len == -1)
            {
                NSLog(@"Error reading from stream: %@", connection.readStream.streamError);
                continue;
            }
            
            fprintf(stdout, "read (%li): %s", (long)len,  buffer);
        }
    }
    
    NSLog(@"No longer connected");
}

- (void)runServer
{
    ACTcpStreamServer *server;
    server = [[ACTcpStreamServer alloc] initWithListeningPort:self.port];
    server.delegate = self;
    
    [server startListening];
    
    [[NSRunLoop currentRunLoop] run];
}

- (void)tcpStreamServer:(ACTcpStreamServer *)server
     receivedConnection:(ACTcpStreamConnection *)connection
{
    uint8_t buffer[1024];
    NSInteger len = 0;
    
    while (connection.isConnected)
    {
        // we are an echo server
        // read data and then send the data back
        
        NSLog(@"Waiting for data from client...");
        
        len = [connection.readStream read:buffer maxLength:1024];
        
        if (len == -1)
        {
            NSLog(@"Error reading from stream: %@", connection.readStream.streamError);
            continue;
        }
        
        fprintf(stdout, "received (%li): %s", (long)len, buffer);
        
        len = [connection.writeStream write:buffer
                            maxLength:len];
        
        if (len == -1)
        {
            NSLog(@"Error writing to stream: %@", connection.writeStream.streamError);
            continue;
        }
    }
    
    NSLog(@"No longer connected");
}

@end
