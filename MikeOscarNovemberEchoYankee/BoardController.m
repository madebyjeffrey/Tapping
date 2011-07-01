//
//  BoardController.m
//  MikeOscarNovemberEchoYankee
//
//  Created by Jeffrey Drake on 11-06-13.
//  Copyright 2011 N/A. All rights reserved.
//

#import "BoardController.h"


@implementation BoardController

@synthesize board, tones;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //kit = [[[AKManager alloc] init] autorelease];
        //audioFile = [[[AKAudio alloc] init] autorelease];
        
        //NSBundle *bundle = [NSBundle mainBundle];
        
//        self.tone = [Tone toneWithFrequency: 440.0];
/*        self.tones = [NSMutableArray arrayWithObjects: [Tone toneWithFrequency: 261.626],
                                                       [Tone toneWithFrequency: 293.66],
                                                       [Tone toneWithFrequency: 329.63],
                                                       [Tone toneWithFrequency: 392.00],
                                                       [Tone toneWithFrequency: 440.00],
                                                       [Tone toneWithFrequency: 523.25],
                                                       [Tone toneWithFrequency: 587.33], nil]; */
        
        self.tones = [NSMutableArray arrayWithObjects: [Tone toneWithFrequency: 349.23],
                      [Tone toneWithFrequency: 440],
                      [Tone toneWithFrequency: 493.88],
                      [Tone toneWithFrequency: 523.25],
                      [Tone toneWithFrequency: 659.26],
                      [Tone toneWithFrequency: 698.46], nil];

        
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    self.board = [[BoardView alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    self.view = self.board;
    
    [self.board setDelegate: self];
    
    self.view.layer.contents = (id)[UIImage imageNamed: @"MosaicTexture.png"].CGImage;
    
    
}

- (void) sliceTouched: (int) n {
    NSLog(@"Slice %d touched", n);
  
  //  [audioFile play];
//    [self.board setButtonPressed: n];
    
//    [[ToneKit sharedToneKit] playTone: 440];
    
    [[self.tones objectAtIndex: n] play];
    
    
}

- (void) sliceUntouched: (int) n {
    
    NSLog(@"Slice %d untouched", n);
//    [self.board setButtonNormal: n];
    
//    [[ToneKit sharedToneKit] stop];
    [[self.tones objectAtIndex: n] stop];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.view setNeedsLayout];
    //    [self.canvas setNeedsDisplay]; // does not call it the display function
} 


@end
