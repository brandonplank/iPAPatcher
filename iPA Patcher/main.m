//
//  main.m
//  iPA Patcher
//
//  Created by Brandon Plank on 10/16/20.
//

#import <Cocoa/Cocoa.h>
#include "patcher.h"

void help(){
    printf("usage: iPAPatcher -c <../../app.ipa> <dylib|deb> <Directory/name.ipa>\n");
    exit(0);
}

bool isdeb = false;

int main(int argc, const char * argv[]) {
    printf("iPAPatcher by Brandon Plank(@_bplank)\n");
    NSString *command = [NSString stringWithUTF8String:argv[1]];
    if(![command  isEqual: @"-c"]){
        return NSApplicationMain(argc, argv);
    } else {
        if(DEBUG == DEBUG_ON){
            for(int i = 0; i<argc; i++){
                printf("%s\n", argv[i]);
            }
        }
        NSString *app_path = [NSString stringWithUTF8String:argv[2]];
        NSString *dylib_deb = [NSString stringWithUTF8String:argv[3]];
        NSString *out_path = [NSString stringWithUTF8String:argv[4]];
        if(!app_path || !dylib_deb || !out_path){
            help();
        }
        NSArray *check = [dylib_deb componentsSeparatedByString:@"."];
        if(![check.lastObject isEqual: @"dylib"] && ![check.lastObject isEqual:@"deb"]){
            printf("not a dylib or a deb file\n");
            exit(0);
        }
        NSArray *check2 = [out_path componentsSeparatedByString:@"."];
        if(![check2.lastObject isEqual: @"ipa"]){
            printf("not a ipa\n");
            exit(0);
        }
        if([check.lastObject isEqual:@"deb"]){
            isdeb = true;
        } else {
            isdeb = false;
        }
        
        NSMutableArray *dylibPath;
        
        dylibPath = [[NSMutableArray alloc] init];
        [dylibPath insertObject:dylib_deb atIndex:0];
        
        patch_ipa(app_path, dylibPath, isdeb, true, out_path);
    }
}
