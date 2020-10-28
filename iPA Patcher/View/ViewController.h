//
//  ViewController.h
//  iPA Patcher
//
//  Created by Brandon Plank on 10/16/20.
//

#import <Cocoa/Cocoa.h>
#include <stdio.h>
#include <stdlib.h>
#include "patcher.h"

@interface ViewController : NSViewController
@property (weak) IBOutlet NSButton *buildIPAOut;
@property (weak) IBOutlet NSButton *chooseIPAOut;
@property (weak) IBOutlet NSButton *chooseDylibOut;
@property (weak) IBOutlet NSTextField *statusText;

void Msg(NSString *message, BOOL error);
@end

