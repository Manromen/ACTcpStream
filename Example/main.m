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

#import "Example.h"

// arguments for getopt
BOOL isServer = NO;
BOOL isClient = NO;
NSString *hostname = nil;
int port = 0;

//! prints the usage information to stdout
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

//! reads the command line parameters
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
    while ((c = getopt_long (argc, (char * const *)argv, "csh:p:", longopts,
                             NULL)) != -1)
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
                hostname = [NSString stringWithCString:optarg
                                              encoding:NSASCIIStringEncoding];
                break;
            case 'p':
            {
                NSString *p;
                p = [NSString stringWithCString:optarg
                                       encoding:NSASCIIStringEncoding];
                
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
            
            Example *example;
            
            if (isClient)
            {
                example = [[Example alloc] initClientWithHostname:hostname
                                                             port:port];
            }
            else if (isServer)
            {
                example = [[Example alloc] initServerWithPort:port];
            }
            
            [example run];
        }
        else
        {
            print_usage(argv[0]);
            return 0;
        }
        
    }
    return 0;
}
