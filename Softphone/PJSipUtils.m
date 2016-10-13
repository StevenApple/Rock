//
//  PJSipUtils.m
//  Softphone
//
//  Created by Alex Gotev on 02/12/14.
//  Copyright (c) 2014 voismart. All rights reserved.
//

#import "PJSipUtils.h"

@implementation PJSipRemoteContactInfo
@synthesize displayName;
@synthesize sipURI;
@end

@implementation PJSipUtils

AVAudioPlayer *ringtonePlayer;

+(PJSipUtils *)sharedInstance {
    static dispatch_once_t once;
    static PJSipUtils *instance;
    dispatch_once(&once, ^{
        instance = [[PJSipUtils alloc] init];
        
        //Initialize ringtone audio player
        NSString *path = [NSString stringWithFormat:@"%@/ringtone.mp3", [[NSBundle mainBundle] resourcePath]];
        ringtonePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:nil];
        ringtonePlayer.numberOfLoops = -1; //Infinite loops
        
        //Make sure the system follows our playback status
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[AVAudioSession sharedInstance] setActive: YES error: nil];
        
        //Necessary to be able to play the ringtone in background
        // http://stackoverflow.com/questions/7619794/play-music-in-the-background-using-avaudioplayer
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        
        [ringtonePlayer prepareToPlay];
    });
    return instance;
}

+(pj_str_t)fromNSString:(NSString *)str
{
    return pj_str((char *)[str cStringUsingEncoding:NSUTF8StringEncoding]);
}

+(NSString *)fromPJString:(const pj_str_t *)pjString
{
    NSString *result = [NSString alloc];
    result = [result initWithBytesNoCopy:pjString->ptr
                                  length:pjString->slen
                                encoding:NSUTF8StringEncoding
                            freeWhenDone:NO];
    return result;
}

+(PJSipRemoteContactInfo *)getSipRemoteContactInfo:(const pj_str_t *)pjString
{
    NSString *str = [PJSipUtils fromPJString:pjString];
    
    PJSipRemoteContactInfo *info = [[PJSipRemoteContactInfo alloc] init];
    NSRange searchedRange = NSMakeRange(0, [str length]);
    NSError *error = nil;
    
    NSRegularExpression *displayNameAndRemoteUriPattern = [NSRegularExpression regularExpressionWithPattern:@"^\"([^\"]+).*?sip\\:(.*?)>$"
                                                                                                    options:0
                                                                                                      error:&error];
    
    NSRegularExpression *remoteUriPattern = [NSRegularExpression regularExpressionWithPattern:@"^.*?sip\\:(.*?)>$"
                                                                                      options:0
                                                                                        error:&error];
    
    NSTextCheckingResult *match = [displayNameAndRemoteUriPattern firstMatchInString:str options:0 range:searchedRange];
    if (match.range.location != NSNotFound) {
        info.displayName = [str substringWithRange:[match rangeAtIndex:1]];
        info.sipURI = [str substringWithRange:[match rangeAtIndex:2]];
    } else {
        match = [remoteUriPattern firstMatchInString:str options:0 range:searchedRange];
        info.displayName = @"";
        info.sipURI = [str substringWithRange:[match rangeAtIndex:1]];
    }
    
    
    return info;
}

-(void)startRingTone {
    [ringtonePlayer play];
}

-(void)stopRingTone {
    [ringtonePlayer stop];
    ringtonePlayer.currentTime = 0; //Set sound back to the beginning
}

@end
