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
    NSWorkspace *ws = [NSWorkspace sharedWorkspace];
    NSArray *apps = [ws runningApplications];
    for (NSRunningApplication *app in apps)
    {
        NSBundle *bundle = [NSBundle bundleWithURL:[app bundleURL]];
        NSDictionary *info = [bundle infoDictionary];
        NSString *version = info[@"CFBundleShortVersionString"];
        if(version != nil){
            [_app_version setStringValue:version];
        }
    }
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

- (IBAction)help:(id)sender {
    NSString *help_message = [NSString stringWithFormat:@"IPAPatcher\nMIT License\nCopyright (c) 2020 Brandon Plank\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\nTHE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.\n\noptool\nCopyright (c) 2014, Alex Zielenski All rights reserved.\nRedistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:\n* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.\n* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.\nTHIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS \"AS IS\" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.\n\nSubstituite\nSome files in this repository contain their own licensing info in a header:\nsubstrate.h, which is based on an older version of CydiaSubstrate, is under LGPLv3, and substitute.h and the generated files are in the public domain.  (So if you want to take advantage of the more lax permission below, you can't use the Substrate compatibility layer; also, the Debian package includes the obligatory copy of the (L)GPLv3.)\nFor all other files:\nCopyright Nicholas Allegra (comex)\nThis library is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.\n** You may optionally consider the license amended with the following special exception: When statically linking, it is not necessary to include materials specifically for relinking with a modified version of the library (i.e. subsection 6a of the LGPLv2.1, or subsection 4d0 of version 3.0).\nThis library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more details.\nYou should not have received a copy of the GNU Lesser General Public License along with this library, as it can easily be found on the World Wide Web.  If, due to a temporal anomaly, you are trapped in some time period after 1999 (the release date of the LGPL v2.1) but before 1991 (the debut of the Web), you may get a copy by writing to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA.  For all other users, not having to distribute all 5,000 words of the thing may be considered another optional license exception."];
    dispatch_async(dispatch_get_main_queue(), ^{
        Msg(help_message, false);
    });
}
@end
