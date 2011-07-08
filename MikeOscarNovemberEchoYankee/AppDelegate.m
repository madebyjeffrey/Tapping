//
//  MikeOscarNovemberEchoYankeeAppDelegate.m
//  MikeOscarNovemberEchoYankee
//
//  Created by Jeffrey Drake on 11-06-13.
//  Copyright 2011 N/A. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate


@synthesize window=_window, board;

void ToneInterruptionListener(void *inClientData, UInt32 inInterruptionState)
{
}
 
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error = nil;
    BOOL result = NO;
    
    result = [session setActive: YES error: &error];
    
    if (result == NO) {
        if (error) {
            NSLog(@"Could not initialize the audio system: %@", [error localizedDescription]);            
        } else {
            NSLog(@"Could not initialize the audio system.");
        }
    }
    
    session.delegate = self;
    
    
//    OSStatus result = AudioSessionInitialize(NULL, NULL, ToneInterruptionListener, (void*)self);
//    OSStatus result = AudioSessionInitialize(NULL, NULL, ToneInterruptionListener, (__bridge self);
/*    if (result == kAudioSessionNoError)
    {
        UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
        AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
    }
*/
    
    // Override point for customization after application launch.
    self.window = [[[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] applicationFrame]] autorelease];
    [self.window makeKeyAndVisible];

    
    self.board = [[[BoardController alloc] initWithNibName: nil bundle:nil] autorelease];
    [self.window addSubview: self.board.view];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)beginInterruption {
    
}

- (void)endInterruption {

}

- (void)endInterruptionWithFlags:(NSUInteger)flags {
    
}

- (void)inputIsAvailableChanged:(BOOL)isInputAvailable {
    
}

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

@end
