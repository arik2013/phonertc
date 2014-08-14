#import "PhoneRTCPlugin.h"
#import <AVFoundation/AVFoundation.h>

@implementation PhoneRTCPlugin
@synthesize localVideoView;
@synthesize remoteVideoView;
@synthesize remoteVideoTrack;

- (void)setDescription: (CDVInvokedUrlCommand*)command
{
    self.sendMessageCallbackId = command.callbackId;

    NSError *error;
    NSDictionary *arguments = [NSJSONSerialization
                               JSONObjectWithData:[[command.arguments objectAtIndex:0] dataUsingEncoding:NSUTF8StringEncoding]
                               options:0
                               error:&error];

    if (self.webRTC) {
        // Get description has already been called. This is the caller
        NSString *sdp = [arguments objectForKey:@"sdp"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                                 (unsigned long)NULL), ^(void) {
            [self.webRTC receiveAnswer:sdp];
        });
    } else {
        // This is the callee
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
        [pluginResult setKeepCallbackAsBool:true];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendMessage:) name:@"SendMessage" object:nil];
        NSString *turnServerHost = [[arguments objectForKey:@"turn"] objectForKey:@"host"];
        NSString *turnUsername = [[arguments objectForKey:@"turn"] objectForKey:@"username"];
        NSString *turnPassword = [[arguments objectForKey:@"turn"] objectForKey:@"password"];
        NSString *sdp = [arguments objectForKey:@"sdp"];
        RTCICEServer *stunServer = [[RTCICEServer alloc]
                                    initWithURI:[NSURL URLWithString:@"stun:stun.l.google.com:19302"]
                                    username: @""
                                    password: @""];
        RTCICEServer *turnServer = [[RTCICEServer alloc]
                                    initWithURI:[NSURL URLWithString:turnServerHost]
                                    username: turnUsername
                                    password: turnPassword];
        self.webRTC = [[PhoneRTCDelegate alloc] initWithDelegate:self andIsInitiator:NO andICEServers:@[stunServer, turnServer]];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                                 (unsigned long)NULL), ^(void) {
            [self.webRTC receiveOffer:sdp];
        });

    }
}

- (void)getDescription: (CDVInvokedUrlCommand*)command
{
    self.sendMessageCallbackId = command.callbackId;

    NSError *error;
    NSDictionary *arguments = [NSJSONSerialization
                               JSONObjectWithData:[[command.arguments objectAtIndex:0] dataUsingEncoding:NSUTF8StringEncoding]
                               options:0
                               error:&error];

    BOOL doVideo = NO;
    if ([arguments objectForKey:@"video"]) {
        NSDictionary *localVideo = [[arguments objectForKey:@"video"] objectForKey:@"localVideo"];
        NSDictionary *remoteVideo = [[arguments objectForKey:@"video"] objectForKey:@"remoteVideo"];
        localVideoView = [[RTCEAGLVideoView alloc] initWithFrame:CGRectMake([[localVideo objectForKey:@"x"] intValue], [[localVideo objectForKey:@"y"] intValue], [[localVideo objectForKey:@"width"] intValue], [[localVideo objectForKey:@"height"] intValue])];
        localVideoView.hidden = YES;
        localVideoView.userInteractionEnabled = NO;
        [self.webView.superview addSubview:localVideoView];

        remoteVideoView = [[RTCEAGLVideoView alloc] initWithFrame:CGRectMake([[remoteVideo objectForKey:@"x"] intValue], [[remoteVideo objectForKey:@"y"] intValue], [[remoteVideo objectForKey:@"width"] intValue], [[remoteVideo objectForKey:@"height"] intValue])];
        remoteVideoView.hidden = YES;
        remoteVideoView.userInteractionEnabled = NO;
        [self.webView.superview addSubview:remoteVideoView];
        if (remoteVideoTrack) {
            remoteVideoView.videoTrack = remoteVideoTrack;
            remoteVideoView.hidden = NO;
            [self.webView.superview bringSubviewToFront:remoteVideoView];
            [self.webView.superview bringSubviewToFront:localVideoView];
        }
        doVideo = YES;
    }

    if (self.webRTC) {
        // callee
        [self.webRTC getDescription];
    } else {
        // caller. create self.webrtc
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
        [pluginResult setKeepCallbackAsBool:true];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendMessage:) name:@"SendMessage" object:nil];
        NSString *turnServerHost = [[arguments objectForKey:@"turn"] objectForKey:@"host"];
        NSString *turnUsername = [[arguments objectForKey:@"turn"] objectForKey:@"username"];
        NSString *turnPassword = [[arguments objectForKey:@"turn"] objectForKey:@"password"];
        RTCICEServer *stunServer = [[RTCICEServer alloc]
                                    initWithURI:[NSURL URLWithString:@"stun:stun.l.google.com:19302"]
                                    username: @""
                                    password: @""];
        RTCICEServer *turnServer = [[RTCICEServer alloc]
                                    initWithURI:[NSURL URLWithString:turnServerHost]
                                    username: turnUsername
                                    password: turnPassword];
        self.webRTC = [[PhoneRTCDelegate alloc] initWithDelegate:self andIsInitiator:YES andICEServers:@[stunServer, turnServer]];
        [self.webRTC getDescription];
    }
}

- (void)call:(CDVInvokedUrlCommand*)command
{
    self.sendMessageCallbackId = command.callbackId;

    BOOL isInitator = [[command.arguments objectAtIndex:0] boolValue];
	NSString *turnServerHost = (NSString *)[command.arguments objectAtIndex:1];
	NSString *turnUsername = (NSString *)[command.arguments objectAtIndex:2];
	NSString *turnPassword = (NSString *)[command.arguments objectAtIndex:3];
    BOOL doVideo = false;
    if ([command.arguments count] > 4 && [command.arguments objectAtIndex:4] != [NSNull null]) {
        NSDictionary *localVideo = [[command.arguments objectAtIndex:4] objectForKey:@"localVideo"];
        NSDictionary *remoteVideo = [[command.arguments objectAtIndex:4] objectForKey:@"remoteVideo"];
        localVideoView = [[RTCEAGLVideoView alloc] initWithFrame:CGRectMake([[localVideo objectForKey:@"x"] intValue], [[localVideo objectForKey:@"y"] intValue], [[localVideo objectForKey:@"width"] intValue], [[localVideo objectForKey:@"height"] intValue])];
        localVideoView.hidden = YES;
        localVideoView.userInteractionEnabled = NO;
        [self.webView.superview addSubview:localVideoView];

        remoteVideoView = [[RTCEAGLVideoView alloc] initWithFrame:CGRectMake([[remoteVideo objectForKey:@"x"] intValue], [[remoteVideo objectForKey:@"y"] intValue], [[remoteVideo objectForKey:@"width"] intValue], [[remoteVideo objectForKey:@"height"] intValue])];
        remoteVideoView.hidden = YES;
        remoteVideoView.userInteractionEnabled = NO;
        [self.webView.superview addSubview:remoteVideoView];

        doVideo = true;
    }
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
    [pluginResult setKeepCallbackAsBool:true];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendMessage:) name:@"SendMessage" object:nil];
    RTCICEServer *stunServer = [[RTCICEServer alloc]
                                initWithURI:[NSURL URLWithString:@"stun:stun.l.google.com:19302"]
                                username: @""
                                password: @""];
    RTCICEServer *turnServer = [[RTCICEServer alloc]
                                initWithURI:[NSURL URLWithString:turnServerHost]
                                username: turnUsername
                                password: turnPassword];
    self.webRTC = [[PhoneRTCDelegate alloc] initWithDelegate:self andIsInitiator:isInitiator andICEServers:@[stunServer, turnServer]];
    if (isInitiator) {
        [self.webRTC getDescription];
    }
//    [self.webRTC onICEServers:@[stunServer, turnServer]];
}

- (void)updateVideoPosition:(CDVInvokedUrlCommand*)command
{
    // This will update the position of the video elements when the page moves
    NSDictionary *localVideo = [[command.arguments objectAtIndex:0] objectForKey:@"localVideo"];
    NSDictionary *remoteVideo = [[command.arguments objectAtIndex:0] objectForKey:@"remoteVideo"];
    localVideoView.frame = CGRectMake([[localVideo objectForKey:@"x"] intValue], [[localVideo objectForKey:@"y"] intValue], [[localVideo objectForKey:@"width"] intValue], [[localVideo objectForKey:@"height"] intValue]);
    remoteVideoView.frame = CGRectMake([[remoteVideo objectForKey:@"x"] intValue], [[remoteVideo objectForKey:@"y"] intValue], [[remoteVideo objectForKey:@"width"] intValue], [[remoteVideo objectForKey:@"height"] intValue]);
}

- (void)receiveMessage:(CDVInvokedUrlCommand*)command
{
    NSString *message = [command.arguments objectAtIndex:0];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             (unsigned long)NULL), ^(void) {
        [self.webRTC receiveMessage:message];
    });
}

- (void)disconnect:(CDVInvokedUrlCommand*)command
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             (unsigned long)NULL), ^(void) {
        [self.webRTC disconnect];
    });
}

- (void)sendMessage:(NSNotification *)notification {
	NSData *message = [notification object];
    NSDictionary *jsonObject=[NSJSONSerialization
                              JSONObjectWithData:message
                              options:NSJSONReadingMutableLeaves
                              error:nil];

    NSLog(@"SENDING MESSAGE: %@", [[NSString alloc] initWithData:message encoding:NSUTF8StringEncoding]);
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                  messageAsDictionary:jsonObject];
    [pluginResult setKeepCallbackAsBool:true];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.sendMessageCallbackId];
}

- (void)addLocalVideoTrack:(RTCVideoTrack *)track {
    NSLog(@"addLocalStream 1");
    localVideoView.videoTrack = track;
    localVideoView.hidden = NO;
    [self.webView.superview bringSubviewToFront:localVideoView];
}

- (void)addRemoteVideoTrack:(RTCVideoTrack *)track {
    NSLog(@"addRemoteStream 1");
    if (remoteVideoView) {
        remoteVideoView.videoTrack = track;
        remoteVideoView.hidden = NO;
        [self.webView.superview bringSubviewToFront:remoteVideoView];
        [self.webView.superview bringSubviewToFront:localVideoView];
    } else {
        remoteVideoTrack = track;
    }
}

- (void)resetUi {
    NSLog(@"Reset Ui");
    self.localVideoView.videoTrack = nil;
    self.remoteVideoView.videoTrack = nil;
    localVideoView.hidden = YES;
    [localVideoView removeFromSuperview];
    remoteVideoView.hidden = YES;
    [remoteVideoView removeFromSuperview];
    localVideoView = nil;
    remoteVideoView = nil;
    remoteVideoTrack = nil;
}

- (void)callComplete {
    NSLog(@"Call Complete");
    self.webRTC.delegate = nil;
    self.webRTC = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
