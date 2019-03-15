//
//  DebuggerHelper.h
//  CardinalDebugToolkit
//
//  Created by Robin Kunde on 1/11/19.
//  Copyright © 2019 Cardinal Solutions. All rights reserved.
//

#include <stdbool.h>

// Returns true if the current process is being debugged (either
// running under the debugger or has a debugger attached post facto).
bool isDebuggerAttached(void);
