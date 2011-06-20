//
//  Audio.m
//  MikeOscarNovemberEchoYankee
//
//  Created by Jeffrey Drake on 11-06-19.
//  Copyright 2011 N/A. All rights reserved.
//

#import "AKAudio.h"


@implementation AKAudio

- (id) init {
    self = [super init];
    
    if (self) {
        ALenum error;
        
        // Generate buffer and source
        
        alGenBuffers(1, &buffer);
        
        error = alGetError();
        if (error != AL_NO_ERROR) {
            NSLog(@"Error Generating Buffers: %x", error);
            [self autorelease];
            return nil;
        }
        
        alGenSources(1, &source);
        if (error != AL_NO_ERROR) {
            NSLog(@"Error Generating Sources: %x", error);
            [self autorelease];
            return nil;
        }
        
        alGetError(); // clear errors
        
        
    }
    
    return self;
}

+ (AKAudio*) audioWithPath: (NSString*) path {
    AKAudio *audio = [[AKAudio alloc] init];
    
    return [audio autorelease];
}

- (void) dealloc {
    [super dealloc];
    
    // get rid of buffer and source
    // Delete the Sources
    alDeleteSources(1, &source);
	// Delete the Buffers
    alDeleteBuffers(1, &buffer);
}

- (void) openAudioWithPath: (NSString*) path {
    // We have a buffer and a source at this point - we should check them just to be sure
    
    void   *data = NULL;
    // Load File Data -> Adapted from oalTouch sample (By Apple)
    OSStatus            err = noErr;
    ExtAudioFileRef     extRef = NULL;
    
    // Open Audio File
    err = ExtAudioFileOpenURL((CFURLRef)[NSURL fileURLWithPath: path], &extRef);
    
    if (err) {
        NSLog(@"openAudioWithPath: Could not open file. Error = %ld", err);
        goto Exit;
    }
    
    // Get Data Format
    
    AudioStreamBasicDescription  format;
    UInt32                       formatSize = sizeof(format);

    err = ExtAudioFileGetProperty(extRef, kExtAudioFileProperty_FileDataFormat, &formatSize, &format);
    if (err) {
        NSLog(@"openAudioWithPath: Could not retrieve audio data format. Error = %ld", err);
        goto Exit;
    }
    
    if (format.mChannelsPerFrame > 2) {
        NSLog(@"openAudioWithPath: Unsupported Format, more than two channels");
        goto Exit; // should we throw error?
    }
    
    // Set to 16 Bit signed integer data
    AudioStreamBasicDescription  outputFormat;
    
    outputFormat.mSampleRate = format.mSampleRate;
    outputFormat.mChannelsPerFrame = format.mChannelsPerFrame;
    outputFormat.mFormatID = kAudioFormatLinearPCM;
    outputFormat.mBytesPerPacket = 2 * outputFormat.mChannelsPerFrame;
    outputFormat.mFramesPerPacket = 1;
    outputFormat.mBytesPerFrame = 2 * outputFormat.mChannelsPerFrame;
    outputFormat.mBitsPerChannel = 16;
    outputFormat.mFormatFlags = kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;
    
    // set the output format
    err = ExtAudioFileSetProperty(extRef, kExtAudioFileProperty_ClientDataFormat, sizeof(outputFormat), &outputFormat);
    
    if (err) {
        NSLog(@"openAudioWithPath: Could not set data format. Error = %ld", err);
        goto Exit;
    }
    
    SInt64  fileLength = 0; // in frames
    formatSize = sizeof(fileLength);
    err = ExtAudioFileGetProperty(extRef, kExtAudioFileProperty_FileLengthFrames, &formatSize, &fileLength);
    
    if (err) {
        NSLog(@"openAudioWithPath: Could not get length of audio. Error = %ld", err);
        goto Exit;
    }
    
    // Read data
    UInt32  dataSize = fileLength * outputFormat.mBytesPerFrame;
    data = malloc(dataSize);
    
    if (!data) {
        NSLog(@"openAudioWithPath: Could not allocate enough data.");
        goto Exit;
    }
    

    AudioBufferList dataBuffer;
    dataBuffer.mNumberBuffers = 1;
    dataBuffer.mBuffers[0].mDataByteSize = dataSize;
    dataBuffer.mBuffers[0].mNumberChannels = outputFormat.mChannelsPerFrame;
    dataBuffer.mBuffers[0].mData = data;
    
    err = ExtAudioFileRead(extRef, (UInt32*)&fileLength, &dataBuffer); // single threaded only!
    
    if (err) {
        free(data);
        NSLog(@"openAudioWithPath: Unable to read audio data. Error = %ld", err);
        goto Exit;
    }
    
    outDataSize = (ALsizei) dataSize;
    outDataFormat = (outputFormat.mChannelsPerFrame > 1) ? AL_FORMAT_STEREO16 : AL_FORMAT_MONO16;
    outSampleRate = (ALsizei)outputFormat.mSampleRate;
    
Exit:
    if (extRef) {
        ExtAudioFileDispose(extRef);   
    }

    sound_data = (void*)data;
}

- (void) buffer {
    
    if (!sound_data) {
        NSLog(@"buffer: No sound loaded");
        return;
    }

    typedef ALvoid	AL_APIENTRY	(*alBufferDataStaticProcPtr) (const ALint bid, ALenum format, ALvoid* data, ALsizei size, ALsizei freq);
    
    alBufferDataStaticProcPtr alBufferDataStaticProc = alcGetProcAddress(NULL, (const ALCchar*) "alBufferDataStatic");
    
    if (!alBufferDataStaticProc) {
        NSLog(@"buffer: Not able to retrieve buffering function.");
        return;
    }
    
    alBufferDataStaticProc(buffer, outDataFormat, sound_data, outDataSize, outSampleRate);

    ALenum  error = alGetError();
    if(error != AL_NO_ERROR) {
        NSLog(@"buffer: Unable to attach sound to buffer. Error = %x", error);
    }
    
    return;
}

- (void) source {
    ALenum error = AL_NO_ERROR;
	alGetError(); // Clear the error

    
    float radians = 0;
    float ori[] = {cos(radians + M_PI_2), sin(radians + M_PI_2), 0., 0., 0., 1.};
	// Set our listener orientation (rotation)
	alListenerfv(AL_ORIENTATION, ori);
    
    float listenerPosAL[] = {0, 0., 0};
	// Move our listener coordinates
	alListenerfv(AL_POSITION, listenerPosAL);
    
	// Turn Looping OFF
	alSourcei(source, AL_LOOPING, AL_FALSE);
	
	// Set Source Position
	float sourcePosAL[] = {0, 25, 0};
	alSourcefv(source, AL_POSITION, sourcePosAL);
	
	// Set Source Reference Distance
	alSourcef(source, AL_REFERENCE_DISTANCE, 50.0f);
	
    alGetError();
	// attach OpenAL Buffer to OpenAL Source
	alSourcei(source, AL_BUFFER, buffer);
	
	if((error = alGetError()) != AL_NO_ERROR) {
		NSLog(@"Error attaching buffer to source: %x\n", error);
		exit(1);
	}	


}

- (void) play {
	ALenum error;
	
	NSLog(@"Start!\n");
	// Begin playing our source file
	alSourcePlay(source);
	if((error = alGetError()) != AL_NO_ERROR) {
		NSLog(@"error starting source: %x\n", error);
	} else {
		// Mark our state as playing (the view looks at this)
//		self.isPlaying = YES;
	}
    
}



@end
