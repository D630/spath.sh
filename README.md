Some shell subroutines to shorten a string, which represents a file path name.

```
Usage
    Spath::Do <ARG1> <str>      Shorten the string, if necessary. The return
                                status is 1, if not
    Spath::GetCols() <ARG1>     Determine the current terminal width

Arguments
    <ARG1>                      ( : | <name> )
    :                           Print the result to stdout
    <name>                      Name of the variable to have the result in store
    <str>                       String

Environment variables
    SPATH_MARK                  Prompt mark in shortened paths. Default
                                is " ... "
    SPATH_KEEP                  na
    SPATH_LENGTH                Value to calculate the maximal length of the
                                path; to begin the shortening. Default is 35
```
