/*
 main.m
 
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

#import <Foundation/Foundation.h>
#import <getopt.h>
#include <netinet/in.h>

#import "ACTcpStreamClient.h"

BOOL isServer = NO;
BOOL isClient = NO;
NSString *hostname = nil;
int port = 0;

int process_args(int argc, const char** argv);
void print_usage(const char *appname);
void client_processing(ACTcpStreamClient *client);
void server_processing(int port);

int main(int argc, const char ** argv)
{
    @autoreleasepool
    {
        if (process_args(argc, argv) == 0)
        {
            // check if all required parameters are given
            if (// we need to be server or client
                (isServer && isClient) ||
                // if we are a client, we require the hostname to connect to
                (isClient && !hostname) ||
                // we need a port to connect or listen to
                port == 0)
            {
                print_usage(argv[0]);
                return 0;
            }
            
            NSLog(@"We are %@", isClient ? @"Client" : @"Server");
            if (isClient)
                NSLog(@"hostname: %@", hostname);
            NSLog(@"port: %li", (long)port);
            
            if (isClient)
            {
                ACTcpStreamClient *client = [ACTcpStreamClient tcpStreamWithHostname:hostname port:port];
                client_processing(client);
            }
            else if (isServer)
            {
                server_processing(port);
            }
        }
        else
        {
            print_usage(argv[0]);
            return 0;
        }
        
    }
    return 0;
}

void print_usage(const char *appname)
{
    NSString *usage = [NSString stringWithFormat:@"\n"
    
    "Usage:\n"
    "%s (--server --port <port> | --client --hostname <host> --port <port>)\n\n"
    
    "Options:\n"
    "-s --server     Run in server mode.\n"
    "-c --client     Run in client mode.\n"
    "-p --port       Port to connect to if running as client, port to bind to "
                     "if running as server.\n"
    "-h --hostname   The hostname to connect to.\n\n"
                       , appname];
    
    fprintf(stdout, "%s", [usage cStringUsingEncoding:NSASCIIStringEncoding]);
}

int process_args(int argc, const char** argv)
{
    static struct option longopts[] =
    {
        { "server", no_argument, NULL, 's' },
        { "client", no_argument, NULL, 'c' },
        { "hostname", required_argument, NULL, 'h'},
        { "port", required_argument, NULL, 'p'},
        { NULL, 0, NULL, 0 }
    };
    
    int c;
    
    // parse all arguments with getopt_long
    while ((c = getopt_long (argc, (char * const *)argv, "csh:p:", longopts, NULL)) != -1)
    {
        switch (c)
        {
            case 'c':
                isClient = YES;
                break;
            case 's':
                isServer = YES;
                break;
            case 'h':
                hostname = [NSString stringWithCString:optarg encoding:NSASCIIStringEncoding];
                break;
            case 'p':
            {
                NSString *p = [NSString stringWithCString:optarg encoding:NSASCIIStringEncoding];
                
                port = p.intValue;
                
                break;
            }
            default:
                return -1; // error -> there is an undefined argument
                break;
        }
    }
    
    // error if there are arguments that are not options
    if (optind < argc)
    {
        for (int index = optind; index < argc; index++)
        {
            NSLog(@"Non-option argument %s\n", argv[index]);
        }
        return -1;
    }
    
    return 0;
}

void client_processing(ACTcpStreamClient *client)
{
    ACTcpStreamClientConnect ret = [client connect];
    
    if (ret == ACTcpStreamClientConnectSuccess)
        NSLog(@"sucessfully connected");
    
    if (!client.isConnected)
    {
        NSLog(@"not connected!!!");
    }
    
    int len = 1024;
    uint8_t * buffer = (uint8_t *)malloc(sizeof(uint8_t) * len);
    bzero(buffer, len);
    
    [client.readStream read:buffer maxLength:len];
    
    fprintf(stdout, "read: %s", buffer);
    free(buffer);
}

void server_processing(int port)
{
    struct sockaddr_in srv;
    int connectSocket; // connect socket
    int dataSocket; // data socket
    int opt = 1; // socket options
    
    int ret = 0;
    
    // init struct
    bzero(&srv, sizeof(srv)); // fill struct with zeros
    srv.sin_family = AF_INET;
    srv.sin_addr.s_addr = INADDR_ANY;
    srv.sin_port = htons(port);
    
    // init connect socket
    connectSocket = socket(AF_INET, SOCK_STREAM, 0);
    setsockopt(connectSocket, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(int));
    ret = bind(connectSocket, (struct sockaddr *)&srv, sizeof(srv));
    
    if (ret != 0) {
        NSLog(@"Error binding port");
        abort();
    }
    
    ret = listen(connectSocket, 20);
    
    if (ret != 0) {
        NSLog(@"Error listening on socket");
        abort();
    }
    
    printf("server ready for incomming connections\n");
    
    while (true) {
        struct sockaddr_in data;
        unsigned int size;
        
        // wait for incomming connection
        dataSocket = accept(connectSocket, (struct sockaddr *)&data, &size);
        
        if (dataSocket > 0) { // < 0 ==> Error
            
            NSLog(@"accepted incomming connection");
        } else {
            NSLog(@"Error accepting incomming connection");
        }
    }
}
