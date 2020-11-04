//
//  ViewController.m
//  iPA Patcher
//
//  Created by Brandon Plank on 10/16/20.
//

#import "ViewController.h"

@implementation ViewController

NSString *ipaPath = @"";
NSMutableArray *dylibPath;

bool ipa_chosen = false;
bool dylib_chosen = false;
bool isDeb = false;

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    // Update the view, if already loaded.
}
void Msg(NSString *message, BOOL error){
    NSAlert *alert = [[NSAlert alloc] init];
    if(error){
        [alert setMessageText:@"Error"];
        [alert setInformativeText:message];
        [alert addButtonWithTitle:@"Ok"];
        [alert runModal];
    } else {
        [alert setMessageText:@"Notice"];
        [alert setInformativeText:message];
        [alert addButtonWithTitle:@"Ok"];
        [alert runModal];
    }
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
                    Msg(@"The file was not a ipa!", true);
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
        printf("File selector canceled/failed\n");
    }
}

- (IBAction)choose_deb_dylib:(id)sender {
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
                    Msg(@"The file was not a dylib or deb!", true);
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
        printf("File selector canceled/failed\n");
    }
}

- (IBAction)build:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.buildIPAOut.title = @"Patching.";
    });
    if(patch_ipa(ipaPath, dylibPath, isDeb, false, NULL) != IPAPATCHER_SUCCESS){
        dispatch_async(dispatch_get_main_queue(), ^{
            Msg(@"The patching process has failed", true);
            self.buildIPAOut.title = @"Failed.";
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            Msg(@"The iPA has been patched!", false);
            self.buildIPAOut.title = @"Patched.";
        });
    }
}

@end
