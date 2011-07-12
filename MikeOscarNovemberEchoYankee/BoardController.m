//
//  BoardController.m
//  MikeOscarNovemberEchoYankee
//
//  Created by Jeffrey Drake on 11-06-13.
//  Copyright 2011 N/A. All rights reserved.
//

#import "BoardController.h"

//#include <arm_neon.h>

@interface BoardController ()
@property (retain) NSMutableArray *notes;
@end

@implementation BoardController

@synthesize board, notes;


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
        
        self.notes = [NSMutableArray arrayWithObjects: [Note noteWithFrequency: 349.23],
                      [Note noteWithFrequency: 440],
                      [Note noteWithFrequency: 493.88],
                      [Note noteWithFrequency: 523.25],
                      [Note noteWithFrequency: 659.26],
                      [Note noteWithFrequency: 698.46], nil];

/*        self.tones = [NSMutableArray arrayWithObjects: [Tone toneWithFrequency: 440 phase: 0],
                      [Tone toneWithFrequency: 440*2 phase: 0],
                      [Tone toneWithFrequency: 440*3 phase: 0],
                      [Tone toneWithFrequency: 440*4 phase: 0],
                      [Tone toneWithFrequency: 440*5 phase: 0],
                      [Tone toneWithFrequency: 440*6 phase: 0], nil]; */
/*
        float inputX[4] = { 2, 4, 8, 16 };
        float inputY[4] = { 2, 4, 8, 16 };
        float resultZ[4] = { 0, 0, 0, 0 };
        
        float32x4_t sample1, sample2, result;
        
        sample1 = vld1q_f32(inputX);
        sample2 = vld1q_f32(inputY);
        
        result = vmulq_f32(sample1, sample2);
        
        vst1q_f32(resultZ, result);

        NSLog(@"Result: %f, %f, %f, %f", resultZ[0], resultZ[1], resultZ[2], resultZ[3]);
*/
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
    self.board = [[[BoardView alloc] initWithFrame: [[UIScreen mainScreen] bounds]] autorelease];
    self.view = self.board;
    
    [self.board setDelegate: self];
    
    self.view.layer.contents = (__bridge id)[UIImage imageNamed: @"MosaicTexture.png"].CGImage;
    
    
}

- (void) sliceTouched: (int) n {
//    NSLog(@"Slice %d touched", n);
  
  //  [audioFile play];
//    [self.board setButtonPressed: n];
    
//    [[ToneKit sharedToneKit] playTone: 440];
    
    [[self.notes objectAtIndex: n] play];
    
    
}

- (void) sliceUntouched: (int) n {
    
 //   NSLog(@"Slice %d untouched", n);
//    [self.board setButtonNormal: n];
    
//    [[ToneKit sharedToneKit] stop];
    [[self.notes objectAtIndex: n] stop];
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



