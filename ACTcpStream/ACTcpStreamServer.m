/*
 ACTcpStreamServer.m
 
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

#import "ACTcpStreamServer.h"

#include <netinet/in.h>

@implementation ACTcpStreamServer

- (instancetype)initWithListeningPort:(int)port
{
    self = [super init];
    if (self)
    {
        _listeningPort = port;
    }
    return self;
}

- (void)startListening
{
    struct sockaddr_in srv;
    __block int listeningSocket; // connect socket
    int opt = 1; // socket options
    
    int ret = 0;
    
    // init struct
    bzero(&srv, sizeof(srv)); // fill struct with zeros
    srv.sin_family = AF_INET;
    srv.sin_addr.s_addr = INADDR_ANY;
    srv.sin_port = htons(self.listeningPort);
    
    // init connect socket
    listeningSocket = socket(AF_INET, SOCK_STREAM, 0);
    setsockopt(listeningSocket, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(int));
    ret = bind(listeningSocket, (struct sockaddr *)&srv, sizeof(srv));
    
    if (ret != 0) {
        NSLog(@"Error binding port");
        abort();
    }
    
    ret = listen(listeningSocket, 20);
    
    if (ret != 0) {
        NSLog(@"Error listening on socket");
        abort();
    }
    
    printf("server ready for incomming connections\n");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        while (true) {
            struct sockaddr_in data;
            unsigned int size;
            
            // wait for incomming connection
            int clientSocket = accept(listeningSocket, (struct sockaddr *)&data, &size);
            
            if (clientSocket > 0) { // < 0 ==> Error
                
                NSLog(@"accepted incomming connection");
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    ACTcpStreamConnection *connection = [[ACTcpStreamConnection alloc] initWithSocket:clientSocket];
                    
                    if ([self.delegate respondsToSelector:@selector(tcpStreamServer:receivedConnection:)] &&
                        connection.isConnected)
                    {
                        [self.delegate tcpStreamServer:self receivedConnection:connection];
                    }
                });
                
            } else {
                NSLog(@"Error accepting incomming connection");
            }
        }
    });
}

@end
