//
//  TweakController.m
//  LingTweak
//
//  Created by John on 1/4/13.
//  Copyright (c) 2013 ling. All rights reserved.
//

#import "TweakController.h"
#import "BLAuthentication.h"


#define kBackupSHcmd @"cp /etc/hosts ~"

@implementation TweakController



- (NSString *)runCommand:(NSString *)commandToRun
{
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
    
    NSArray *arguments = [NSArray arrayWithObjects:
                          @"-c" ,
                          [NSString stringWithFormat:@"%@", commandToRun],
                          nil];
    NSLog(@"run command: %@",commandToRun);
    [task setArguments: arguments];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *output;
    output = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    return output;
}


- (void)openUrl:(NSString *)webUrl
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:webUrl]];
}


- (IBAction)showHiddenFiles:(id)sender
{
    [self runCommand:@"defaults write com.apple.finder AppleShowAllFiles -bool true"];
    [self runCommand:@"killAll Finder"];
}

- (IBAction)HideHiddenFiles:(id)sender
{
    [self runCommand:@"defaults write com.apple.finder AppleShowAllFiles -bool false"];
    [self runCommand:@"killAll Finder"];
}




- (void)alertWithMessage:(NSString *)message
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@""];
    [alert setInformativeText:message];
    [alert runModal];
    [alert release];
}

- (IBAction)buttonPressed:(id)sender
{
    
    
    //bakup first.
    //[self runCommand:kBackupSHcmd];
    
    
    id blTmp = [BLAuthentication sharedInstance];
    
    NSString *myCommand = [[NSString alloc] initWithString:@"/bin/cp"];
    
    NSLog(@"%@",[[NSBundle mainBundle] bundlePath]);
    
    NSString *srcPath = [NSString stringWithFormat:@"%@/Contents/Resources/hosts-patched",[[NSBundle mainBundle] bundlePath]];
    
    NSArray *para = [[NSArray alloc] initWithObjects:srcPath, @"/etc/hosts", nil];
    
    [blTmp authenticate:myCommand];
    
    if([blTmp isAuthenticated:myCommand] == true) {
        NSLog(@"Authenticated");
        [blTmp executeCommandSynced:myCommand withArgs:para];
        
        [self alertWithMessage:@"成功!现在可以安装Adobe产品了"];
        
    } else
    {
        [self alertWithMessage:@"安装失败,请重新安装补丁!"];
    }
    
    [myCommand release];
    [para release];
}


- (IBAction)checkForUpdate:(id)sender
{
    [self openUrl:@"http://www.lingsky.com"];
}


@end
