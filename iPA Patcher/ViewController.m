//
//  ViewController.m
//  iPA Patcher
//
//  Created by Brandon Plank on 10/16/20.
//

#import "ViewController.h"
#include <stdio.h>
#include <stdlib.h>

@implementation ViewController

#define fileExists(file) [[NSFileManager defaultManager] fileExistsAtPath:@(file)]

NSString *ipaPath = @"";
NSMutableArray *dylibPath;

bool ipa_chosen = false;
bool dylib_chosen = false;
bool isDeb = false;

- (void)viewDidLoad {
    [super viewDidLoad];
    setuid(0);
    // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

void runCMD(NSString *command){
    printf("Running %s\n", [command UTF8String]);
    system([command UTF8String]);
}


NSString *cmdV(NSString *command) {

  FILE *fp;
  char path[1035];

  /* Open the command for reading. */
  fp = popen([command UTF8String], "r");
  if (fp == NULL) {
    printf("Failed to run command\n" );
    exit(1);
  }

  /* Read the output a line at a time - output it. */
  while (fgets(path, sizeof(path), fp) != NULL) {
    printf("%s", path);
  }

  /* close */
  pclose(fp);

  return [[NSString stringWithFormat:@"%s", path] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
}

NSArray *cmdVInArray(NSString *command) {
    NSMutableArray *wtfbrandon = [NSMutableArray array];
    FILE *fp;
    char path[1035];

    /* Open the command for reading. */
    fp = popen([command UTF8String], "r");
    if (fp == NULL) {
        printf("Failed to run command\n" );
        exit(1);
    }

    /* Read the output a line at a time - output it. */
    while (fgets(path, sizeof(path), fp) != NULL) {
        printf("cmdV: %s", path);
        NSString *formattedPath = [NSString stringWithFormat:@"%s", path];
        [wtfbrandon addObject:formattedPath];
    }

    /* close */
    pclose(fp);

    return [wtfbrandon copy];
}

void noticeMsg(NSString *message){
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Notice"];
    [alert setInformativeText:message];
    [alert addButtonWithTitle:@"Ok"];
    [alert runModal];
}

- (IBAction)patch:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^{
        if(getuid() != 0){
            dispatch_async(dispatch_get_main_queue(), ^{
                errorMsg(@"You are not running as root!\nTo run as root, drag the iPAPatcher.app/Contents/MacOS/iPAPatcher into a terminal window with the command sudo.\nExample:\n \"sudo /Users/brandonplank/Desktop/iPAPatcher.app/Contents/MacOS/iPAPatcher\"");
            });
            return;
        }
        if(!fileExists("/usr/bin/install_name_tool") || !fileExists("/usr/bin/otool") || !fileExists("/usr/bin/plutil") || !fileExists("/usr/bin/plutil")){
            dispatch_async(dispatch_get_main_queue(), ^{
                errorMsg(@"Please install the xcode command line tools!");
            });
            return; // Error handle later
        }
        if([ipaPath  isEqual: @""] || [dylibPath  isEqual: @""]){
            dispatch_async(dispatch_get_main_queue(), ^{
                errorMsg(@"Please select all the correct files.");
            });
            return; // Error handle later
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.buildIPAOut.title = @"Patching.";
        });
        NSBundle *Bundle = [NSBundle mainBundle];
        NSString *opToolPath= [Bundle pathForResource:@"optool" ofType:@""];
        opToolPath = [[NSString stringWithFormat:@"%@", opToolPath] stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
        NSMutableArray *format1 = [NSMutableArray arrayWithArray:[opToolPath componentsSeparatedByString:@"/"]];
        [format1 removeObjectAtIndex:format1.count-1];
        NSString *resPath = @"";
        for(int i = 0; i<format1.count; i++){
            NSString *formattedPath = [NSString stringWithFormat:@"%@/", format1[i]];
            resPath = [resPath stringByAppendingString:formattedPath];
        }
        resPath = [[NSString stringWithFormat:@"%@", resPath] stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
        printf("respurce path: %s\n", [resPath UTF8String]);
        printf("optool %s\n", [opToolPath UTF8String]);
        NSString *tempPath = [NSString stringWithFormat:@"%@temp", resPath];
        tempPath = [[NSString stringWithFormat:@"%@", tempPath] stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
        NSString *cmd = [NSString stringWithFormat:@"mkdir %@", tempPath];
        system([cmd UTF8String]);
        
        //do deb work to get actual dylib.
        
        NSArray *dylibPathFinder;
        [dylibPath replaceObjectAtIndex:0 withObject:[[NSString stringWithFormat:@"%@", dylibPath[0]] stringByReplacingOccurrencesOfString:@" " withString:@"\\ "]];
        printf("fixed dylib path: %s\n", [dylibPath[0] UTF8String]);
        
        if(isDeb){
            cmd = @"";
            if(!fileExists("/usr/local/bin/dpkg")){
                dispatch_async(dispatch_get_main_queue(), ^{
                    errorMsg(@"Please install dpkg!");
                });
                cmd = [NSString stringWithFormat:@"rm -rf %@", tempPath];
                system([cmd UTF8String]);
                return;
            }
            cmd = [NSString stringWithFormat:@"/usr/local/bin/dpkg -x %@ %@/deb/", [[NSString stringWithFormat:@"%@", dylibPath[0]] stringByReplacingOccurrencesOfString:@"\n" withString:@""] ,tempPath];
            system([cmd UTF8String]);
            NSString *wavecheck = [NSString stringWithFormat:@"%@/deb/Library/MobileSubstrate/DynamicLibraries", tempPath];
            if(!fileExists([wavecheck UTF8String])){
                dispatch_async(dispatch_get_main_queue(), ^{
                    errorMsg(@"The tweak you entered is not in the correct format.");
                });
                return;
            }
            cmd = [NSString stringWithFormat:@"ls %@/deb/Library/MobileSubstrate/DynamicLibraries/*.dylib", tempPath];

            dylibPathFinder = cmdVInArray(cmd);
            NSLog(@"The array or dylibs un-formatted: %@", dylibPathFinder);
            
            for(int i=0;i<dylibPathFinder.count;i++){
                printf("%s\n", [dylibPathFinder[i] UTF8String]);
                NSArray *duh = [dylibPathFinder[i] componentsSeparatedByString:@"/"];
                dylibPath[i] = [[NSString stringWithFormat:@"%@/deb/Library/MobileSubstrate/DynamicLibraries/%@", tempPath, duh.lastObject] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            }
        }
        
        ipaPath = [[NSString stringWithFormat:@"%@", ipaPath] stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
  
        cmd = [NSString stringWithFormat:@"unzip -oqq %@ -d %@", ipaPath, tempPath];
        
        runCMD(cmd);
        cmd = [NSString stringWithFormat:@"(set -- \"%@/Payload/\"*.app; echo \"$1\")", tempPath];
        
        
        NSString *appPath = cmdV(cmd);
        
        printf("%s\n", [appPath UTF8String]);
        
        cmd = [NSString stringWithFormat:@"plutil -convert xml1 -o - %@/Info.plist|grep -A1 Exec|tail -n1|cut -f2 -d\\>|cut -f1 -d\\<", appPath];
        
        printf("%s\n", [cmd UTF8String]);
        
        NSString *binaryPath = cmdV(cmd);
        
        printf("%s\n", [binaryPath UTF8String]);
        
        cmd = [NSString stringWithFormat:@"mkdir %@/Dylibs && mkdir %@/Frameworks", appPath, appPath];
        system([cmd UTF8String]);
        
        NSString *subpath1 = [NSString stringWithFormat:@"%@", [Bundle pathForResource:@"libsubstitute.0" ofType:@"dylib"]];
        subpath1 = [[NSString stringWithFormat:@"%@", subpath1] stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
        NSString *subpath2 = [NSString stringWithFormat:@"%@", [Bundle pathForResource:@"libsubstitute" ofType:@"dylib"]];
        subpath2 = [[NSString stringWithFormat:@"%@", subpath2] stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
        NSString *substrate = [NSString stringWithFormat:@"%@", [Bundle pathForResource:@"CydiaSubstrate" ofType:@"framework"]];
        substrate = [[NSString stringWithFormat:@"%@", substrate] stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
        printf("START====\n%s\n%s\n%s\n", [subpath1 UTF8String], [subpath2 UTF8String], [substrate UTF8String]);
        for(int i=0;i<dylibPath.count;i++){
            cmd = [NSString stringWithFormat:@"cp %@ %@/Dylibs", dylibPath[i], appPath];
            cmdV(cmd);
        }
        cmd = [NSString stringWithFormat:@"cp %@ %@/Dylibs",subpath1, appPath];
        cmdV(cmd);
        cmd = [NSString stringWithFormat:@"cp %@ %@/Dylibs", subpath2, appPath];
        cmdV(cmd);
        cmd = [NSString stringWithFormat:@"cp -r %@ %@/Frameworks", substrate, appPath];
        cmdV(cmd);
        
        
        
        for(int i=0;i<dylibPath.count;i++){
            NSArray *dylibNameArray = [dylibPath[i] componentsSeparatedByString:@"/"];
            NSLog(@"array:%@", dylibNameArray);
            NSString *dylibName = [NSString stringWithFormat:@"%@",dylibNameArray.lastObject];

            cmd = [NSString stringWithFormat:@"install_name_tool -change /usr/lib/libsubstrate.dylib @executable_path/Frameworks/CydiaSubstrate.framework/CydiaSubstrate %@/Dylibs/%@ && install_name_tool -change /Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate @executable_path/Frameworks/CydiaSubstrate.framework/CydiaSubstrate %@/Dylibs/%@", appPath, dylibName, appPath, dylibName];
            system([cmd UTF8String]);
            
            cmd = [NSString stringWithFormat:@"%@ install -c load -p @executable_path/Dylibs/%@ -t %@/%@", opToolPath, dylibName ,appPath, binaryPath];
            system([cmd UTF8String]);
        }

        cmd = [NSString stringWithFormat:@"%@ install -c load -p @executable_path/Frameworks/CydiaSubstrate.framework/CydiaSubstrate -t %@/%@", opToolPath, appPath, binaryPath];
        system([cmd UTF8String]);
        cmd = [NSString stringWithFormat:@"%@ install -c load -p @executable_path/Dylibs/libsubstitute.0.dylib -t %@/%@", opToolPath, appPath, binaryPath];
        system([cmd UTF8String]);
        cmd = [NSString stringWithFormat:@"%@ install -c load -p @executable_path/Dylibs/libsubstitute.dylib -t %@/%@", opToolPath, appPath, binaryPath];
        system([cmd UTF8String]);
        
        cmd = [NSString stringWithFormat:@"cd %@ && zip -r ~/Downloads/%@.ipa Payload/", tempPath, binaryPath];
        system([cmd UTF8String]);
        cmd = [NSString stringWithFormat:@"rm -rf %@", tempPath];
        runCMD(cmd);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.buildIPAOut.title = @"Done.";
            dispatch_async(dispatch_get_main_queue(), ^{
                noticeMsg(@"Patching finished, the new iPA should now be in your downloads folder!");
            });
        });
    });
}


- (IBAction)choose_ipa:(id)sender {
    NSOpenPanel *openipa = [NSOpenPanel openPanel];
    [openipa canChooseFiles];
    [openipa setAllowsMultipleSelection:NO];
    if([openipa runModal] == NSModalResponseOK){
        NSArray *urls = [openipa URLs];
        for(int i=0; i<[urls count]; i++){
            NSURL *oururl = urls[i];
            printf("%s\n", [oururl.path UTF8String]);
            NSArray *check = [oururl.path componentsSeparatedByString:@"."];
            if(![check.lastObject isEqual: @"ipa"]){
                printf("not a ipa\n");
                dispatch_async(dispatch_get_main_queue(), ^{
                    errorMsg(@"The file was not a ipa!");
                });
                return; // Not a ipa.
            }
            NSString *filename = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%@", [oururl.path componentsSeparatedByString:@"/"].lastObject]];
            _chooseIPAOut.title = filename;
            ipaPath = oururl.path;
            ipa_chosen = true;
        }
        if(ipa_chosen && dylib_chosen){
            self.buildIPAOut.enabled = true;
        }
    } else {
        printf("Modal failed :/\n");
    }
}

void errorMsg(NSString *message){
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Error"];
    [alert setInformativeText:message];
    [alert addButtonWithTitle:@"Ok"];
    [alert runModal];
}

- (IBAction)choose_dylib:(id)sender {
    NSOpenPanel *opendylib = [NSOpenPanel openPanel];
    [opendylib canChooseFiles];
    [opendylib setAllowsMultipleSelection:NO];
    
    
    if([opendylib runModal] == NSModalResponseOK){
        NSArray *urls = [opendylib URLs];
        for(int i=0; i<[urls count]; i++){
            NSURL *oururl = urls[i];
            printf("%s\n", [oururl.path UTF8String]);
            NSArray *check = [oururl.path componentsSeparatedByString:@"."];
            if(![check.lastObject isEqual: @"dylib"] && ![check.lastObject isEqual:@"deb"]){
                printf("not a dylib or a deb file\n");
                dispatch_async(dispatch_get_main_queue(), ^{
                    errorMsg(@"The file was not a dylib or deb!");
                });
                return; // Not a dylib or deb.
            }
            if([check.lastObject isEqual:@"deb"]){
                isDeb = true;
            } else {
                isDeb = false;
            }
            NSString *filename = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%@", [oururl.path componentsSeparatedByString:@"/"].lastObject]];
            _chooseDylibOut.title = filename;
            dylibPath = [[NSMutableArray alloc] init];
            [dylibPath insertObject:oururl.path atIndex:0];
            dylib_chosen = true;
        }
        if(ipa_chosen && dylib_chosen){
            self.buildIPAOut.enabled = true;
        }
    } else {
        printf("Modal failed :/\n");
    }
}

@end
