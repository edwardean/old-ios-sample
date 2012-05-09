//
//  Evernote.m
//  
//  A simple application demonstrating the use of the Evernote API
//  on iOS.
//
//  Before running this sample, you must change the API consumer key
//  and consumer secret to the values that you received from Evernote.
//
//  Evernote API sample code is provided under the terms specified 
//  in the file LICENSE.txt which was included with this distribution.
//

#import "Evernote.h"


// Real applications authenticate with Evernote using OAuth, but for the
// purpose of exploring the API, you can get a developer token that allows
// you to access your own Evernote account. To get a developer token, visit 
// https://sandbox.evernote.com/api/DeveloperToken.action
NSString * const authToken  = @"your developer token";

NSString * const userStoreUri = @"https://sandbox.evernote.com/edam/user";

// NOTE: You must set the Application name and version
// used in the User-Agent
NSString * const applicationName = @"Evernote iOS Demo";
NSString * const applicationVersion = @"1.1";

@implementation Evernote

@synthesize noteStoreUri, noteStore;

/************************************************************
 *
 *  Implementing the singleton pattern
 *
 ************************************************************/

static Evernote *sharedEvernoteManager = nil;

/************************************************************
 *
 *  Accessing the static version of the instance
 *
 ************************************************************/

+ (Evernote *)sharedInstance {

    if (sharedEvernoteManager == nil) {        
        sharedEvernoteManager = [[Evernote alloc] init];
    }
    
    return sharedEvernoteManager;
    
}

-(id)init{
  self = [super init];
    
  return self;
}

/************************************************************
 *
 *  Connecting to the Evernote server using simple
 *  authentication
 *
 ************************************************************/

- (void) connect {
    
    if (noteStore == nil) 
    {      
        // In the case we are not connected we don't have an authToken
        // Instantiate the Thrift objects
        NSURL * NSURLuserStoreUri = [[[NSURL alloc] initWithString: userStoreUri] autorelease];
        
        THTTPClient *userStoreHttpClient = [[[THTTPClient alloc] initWithURL:  NSURLuserStoreUri] autorelease];
        TBinaryProtocol *userStoreProtocol = [[[TBinaryProtocol alloc] initWithTransport:userStoreHttpClient] autorelease];
        EDAMUserStoreClient *userStore = [[[EDAMUserStoreClient alloc] initWithProtocol:userStoreProtocol] autorelease];

        // Check that we can talk to the server
        bool versionOk = [userStore checkVersion: applicationName :[EDAMUserStoreConstants EDAM_VERSION_MAJOR] :    [EDAMUserStoreConstants EDAM_VERSION_MINOR]];
        
        if (!versionOk) {
            UIAlertView *alertDone = [[UIAlertView alloc] initWithTitle: @"Evernote" message: @"Incompatible Evernote API version" delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
            
            [alertDone show];
            [alertDone release];
            
            return;
        }
 
        noteStoreUri = [[[NSURL alloc] initWithString:[userStore getNoteStoreUrl:authToken]] autorelease];
        
        // Create the User-Agent
        UIDevice *device = [UIDevice currentDevice];
        NSString * userAgent = [NSString stringWithFormat:@"%@/%@;%@(%@)/%@", applicationName,applicationVersion, [device systemName], [device model], [device systemVersion]]; 
        
        // Initializing the NoteStore client
        THTTPClient *noteStoreHttpClient = [[[THTTPClient alloc] initWithURL:noteStoreUri userAgent: userAgent timeout:15000] autorelease];
        TBinaryProtocol *noteStoreProtocol = [[[TBinaryProtocol alloc] initWithTransport:noteStoreHttpClient] autorelease];
        noteStore = [[[EDAMNoteStoreClient alloc] initWithProtocol:noteStoreProtocol] retain];        
    }
}

/************************************************************
 *
 *  Listing all the user's notebooks
 *
 ************************************************************/

- (NSArray *) listNotebooks {   
    
    // Checking the connection
    [self connect];
    
    // Calling a function in the API
    NSArray *notebooks = [[NSArray alloc] initWithArray:[[self noteStore] listNotebooks:authToken] ];
    
    return notebooks;
}


/************************************************************
 *
 *  Searching for notes using a EDAM Note Filter
 *
 ************************************************************/

- (EDAMNoteList *) findNotes: (EDAMNoteFilter *) filter {
    // Checking the connection
    [self connect];
    
    
    // Calling a function in the API 
    return [noteStore findNotes:authToken:filter:0 :100];
}


/************************************************************
 *
 *  Loading a note using the guid
 *
 ************************************************************/

- (EDAMNote *) getNote: (NSString *) guid {
    // Checking the connection
    [self connect];
    
    // Calling a function in the API
    return [noteStore getNote:authToken :guid :true :true :true :true];
}


/************************************************************
 *
 *  Deleting a note using the guid
 *
 ************************************************************/

- (void) deleteNote: (NSString *) guid {
    // Checking the connection
    [self connect];

    // Calling a function in the API
    [noteStore deleteNote:authToken :guid];
}


/************************************************************
 *
 *  Creating a note
 *
 ************************************************************/

- (void) createNote: (EDAMNote *) note {
    // Checking the connection
    [self connect];

    // Calling a function in the API
    [noteStore createNote:authToken :note];
}

- (void)dealloc
{
    [noteStore release];
    [super dealloc];

}

@end
