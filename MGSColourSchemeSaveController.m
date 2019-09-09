//
//  MGSColourSchemeSaveController.m
//  Fragaria
//
//  Created by Jim Derry on 3/21/15.
//
//

#import "MGSColourSchemeSaveController.h"


@interface MGSColourSchemeSaveController ()

@property (nonatomic, strong) IBOutlet NSTextField *schemeNameField;

@property (nonatomic, strong) IBOutlet NSButton *bCancel;
@property (nonatomic, strong) IBOutlet NSButton *bSave;

@property (nonatomic, assign) BOOL saveButtonEnabled;

@end

@implementation MGSColourSchemeSaveController {

    void (^completionBlock)(BOOL);
    void (^deleteCompletion)(BOOL);
}

/*
 * - init
 */
- (instancetype)init
{
#ifdef COCOAPODS
    if ((self = [self initWithWindowNibPath:[resourcesBundle pathForResource:@"MGSColourSchemeSave" ofType:@"nib"] owner:self]))
    {
    }
#else
    [NSBundle bundleForClass:[MGSColourSchemeSaveController class]];
    if ((self = [self initWithWindowNibName:@"MGSColourSchemeSave" owner:self]))
    {
    }
#endif

    return self;
}


/*
 * - awakeFromNib
 */
- (void)awakeFromNib
{
    [self.window setDefaultButtonCell:[self.bSave cell]];
}


#pragma mark - File Naming Sheet


/*
 * - showSchemeNameGetter:completion:
 */
- (void)showSchemeNameGetter:(NSWindow *)window completion:(void (^)(BOOL))aCompletionBlock
{
    completionBlock = aCompletionBlock;
    [NSApp beginSheet:self.window
       modalForWindow:window
        modalDelegate:self
       didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)
          contextInfo:nil];
}


/*
 * - closeSheet
 */
- (IBAction)closeSheet:(id)sender
{
    [NSApp endSheet:self.window];
    BOOL confirmed = sender != self.bCancel;

    if (confirmed)
    {
        NSCharacterSet *cleanCharacters = [NSCharacterSet characterSetWithCharactersInString:@"/\\?%*|\"<>"];
        self.fileName = [[self.schemeName componentsSeparatedByCharactersInSet:cleanCharacters] componentsJoinedByString:@""];
    }
    completionBlock(confirmed);
}


/*
 * - didEndSheet:returnCode:contextInfo:
 */
- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    [self.window orderOut:self];
}


/*
 * @property saveButtonEnabled
 */
+ (NSSet *)keyPathsForValuesAffectingSaveButtonEnabled
{
    return [NSSet setWithObject:@"schemeName"];
}

- (BOOL)saveButtonEnabled
{
    return (self.schemeName && [self.schemeName length] > 0);
}


#pragma mark - Delete Dialogue


/*
 * - showDeleteConfirmation:completion:
 */
- (void)showDeleteConfirmation:(NSWindow *)window completion:(void (^)(BOOL))aCompletionBlock
{
    deleteCompletion = aCompletionBlock;

    NSAlert *alert = [[NSAlert alloc] init];
    
#ifndef COCOAPODS
#define resourcesBundle  [NSBundle bundleForClass:[self class]]
#endif

    [alert addButtonWithTitle:NSLocalizedStringFromTableInBundle(@"Delete", nil, resourcesBundle,  @"String for delete button.")];
    [alert addButtonWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, resourcesBundle,  @"String for cancel button.")];
    [alert setMessageText:NSLocalizedStringFromTableInBundle(@"Delete the scheme?", nil, resourcesBundle,  @"String to alert.")];
    [alert setInformativeText:NSLocalizedStringFromTableInBundle(@"Deleted schemes cannot be restored.", nil, resourcesBundle,  @"String for alert information.")];
    [alert setAlertStyle:NSWarningAlertStyle];

#ifdef resourcesBundle
#undef resourcesBundle
#endif

    [alert beginSheetModalForWindow:window
                      modalDelegate:self
                     didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
                        contextInfo:nil];
}


/*
 * - alertDidEnd:contextInfo:
 */
- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    BOOL result = returnCode == NSAlertFirstButtonReturn;
    deleteCompletion(result);
}

@end
