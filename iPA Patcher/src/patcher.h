//
//  patcher.h
//  iPAPatcher
//
//  Created by Brandon Plank on 10/27/20.
//

#ifndef patcher_h
#define patcher_h

#import <Foundation/Foundation.h>
#import "ViewController.h"
#import <sys/ttycom.h>
#import <sys/ioctl.h>
#include <stdio.h>
#include <stdlib.h>
#include <dlfcn.h>
#import "defines.h"
#import "headers.h"
#import "operations.h"
#include "operations.h"
#include "defines.h"
#include "headers.h"
#include "NSData+Reading.h"
#include <SSZipArchive/SSZipArchive.h>
#include <STPrivilegedTask/STPrivilegedTask.h>

#define fileExists(file) [[NSFileManager defaultManager] fileExistsAtPath:@(file)]
#define IPAPATCHER_SUCCESS 1
#define IPAPATCHER_FAILURE -1
#define EMPTY_STR @""

#define DEBUG 0


#define DEBUG_ON 1
#define DEBUG_OFF 0

#define ZIP_PATH @"/usr/bin/zip"
#define CD_PATH @"/usr/bin/cd"
#define BASH_PATH @"/bin/bash"
#define BREW_PATH @"/usr/local/bin/brew"
#define DPKG_PATH @"/usr/local/bin/dpkg-deb"
#define CP_PATH @"/bin/cp"
#define INSTALL_NAME_TOOL_PATH @"/usr/bin/install_name_tool"

#define __FILENAME__ (__builtin_strrchr(__FILE__, '/') ? __builtin_strrchr(__FILE__, '/') + 1 : __FILE__)
#define ASSERT(test, message, fatal) do \
if (!(test)) { \
int saved_errno = errno; \
NSLog(@"ASSERT(%d:%s)@%s:%u[%s]\nError message: %@", saved_errno, #test, __FILENAME__, __LINE__, __FUNCTION__, message); \
} \
while (false)

int patch_ipa(NSString *ipa_path, NSMutableArray *dylib_or_deb, BOOL isDeb, BOOL commandLine, NSString *outPath);

#endif /* patcher_h */
