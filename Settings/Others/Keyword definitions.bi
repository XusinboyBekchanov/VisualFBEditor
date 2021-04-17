'Intrinsic define (macro value) set by the compiler
'Substitutes the compiler date in a literal string ("mm-dd-yyyy" format) where used.
#define __DATE__

'Intrinsic define (macro value) set by the compiler
'Substitutes the compiler date in a literal string ("yyyy-mm-dd" format) where used. This format is in line with ISO 8601 and can be used for lexicographical date comparisons.
#define __DATE_ISO__

'Intrinsic define set by the compiler
'Define created at compile time if the the compilation target is 64bit, otherwise undefined.
#define __FB_64BIT__

'Intrinsic define (macro value) set by the compiler
'Substituted with the number of arguments passed in on the command line.
#define __FB_ARGC__

'Intrinsic define (macro value) set by the compiler
'Substituted with a pointer to a list of pointers to the zero terminated command line arguments passed in on the command line.
#define __FB_ARGV__

'Intrinsic define set by the compiler
'Define created at compile time if the compilation target uses the ARM CPU architecture, otherwise undefined.
#define __FB_ARM__

'Intrinsic define set by the compiler
'Returns a string equal to "intel" or "att" depending on whether inline assembly blocks should use the Intel format or the GCC/AT&T format.
#define __FB_ASM__

'Intrinsic define set by the compiler
'Defined to either "gas" or "gcc", depending on which backend was specified via -gen.
#define __FB_BACKEND__

'Intrinsic define set by the compiler
'Define without a value created at compile time if compiling for a big endian target.
#define __FB_BIGENDIAN__

'Intrinsic define (macro string) set by the compiler
'Substituted with the quoted string containing the date (MM-DD-YYYY) the compiler was built on.
#define __FB_BUILD_DATE__

'Intrinsic define set by the compiler
'Define without a value created at compile time in the Cygwin version of the compiler, or when the -target cygwin command line option is used.
#define __FB_CYGWIN__

'Intrinsic define set by the compiler
'Define without a value created at compile time in the Darwin version of the compiler, or when the -target darwin command line option is used.
#define __FB_DARWIN__

'Intrinsic define (macro value) set by the compiler
'Indicates if the the generate debug information option -g or the enable intrinsic define __FB_DEBUG__ option.
#define __FB_DEBUG__

'Intrinsic define set by the compiler
'Define without a value created at compile time if compiling for the DOS target.
#define __FB_DOS__

'Intrinsic define (macro value) set by the compiler
'Indicates if -e, -ex, -exx, -earray, -enullptr, -elocation, -edebug, -edebuginfo or -eassert was specified on the compiler command line at the time of compilation of a module.
#define __FB_ERR__

'Intrinsic define set by the compiler
'Defined as "fast" if SSE fast arithmetics is enabled, or "precise" otherwise.
#define __FB_FPMODE__

'Intrinsic define set by the compiler
'Defined as "sse" if SSE floating point arithmetics is enabled, or "x87" otherwise.
#define __FB_FPU__

'Intrinsic define set by the compiler
'Define without a value created at compile time in the FreeBSD version of the compiler, or when the -target freebsd command line option is used.
#define __FB_FREEBSD__

'Intrinsic define set by the compiler
'Defined to true (-1) if -gen gcc is used, or false (0) otherwise.
#define __FB_GCC__

'Intrinsic define (macro value) set by the compiler
'Indicates if the executable subsystem option '-s gui' was specified on the command line at the time of compilation.
#define __FB_GUI__

'Intrinsic define (macro value) set by the compiler
'Indicates which language compatibility option was set at the time of compilation of a module.
#define __FB_LANG__

'Intrinsic define set by the compiler
'Define without a value created at compile time when compiling to the Linux target.
#define __FB_LINUX__

'Intrinsic define set by the compiler
'__FB_MAIN__ is defined in the main module and not defined in other modules.
#define __FB_MAIN__

'Macro function to test minimum compiler version
'
'Parameters
'
'   major
'       minimum major version to test
'
'   minor
'       minimum minor version to test
'
'   patch
'       minimum patch version to test
#define __FB_MIN_VERSION__(major, minor, patch)

'Intrinsic define (macro value) set by the compiler
'Indicates if the the multithreaded option -mt was specified on the command line at the time of compilation.
#define __FB_MT__

'Intrinsic define set by the compiler
'Define without a value created at compile time in the NetBSD version of the compiler, or when the -target netbsd command line option is used.
#define __FB_NETBSD__

'Intrinsic define set by the compiler
'Define without a value created at compile time in the OpenBSD version of the compiler, or when the -target openbsd command line option is used.
#define __FB_OPENBSD__

'Intrinsic define (macro value) set by the compiler
'Indicates if parameters to a Function or Sub are passed by reference as with ByRef, or by value as with ByVal by default when the by value / by reference specifier is not explicitly stated.
#define __FB_OPTION_BYVAL__

'Intrinsic define (macro value) set by the compiler
'Is defined as true (negative one (-1)) if a recent Option Dynamic statement or '$Dynamic meta-command was issued. Otherwise, it is defined as zero (0).
#define __FB_OPTION_DYNAMIC__

'Intrinsic define (macro value) set by the compiler
'Indicates if Option Explicit has been used previously in the source.
#define __FB_OPTION_EXPLICIT__

'Intrinsic define (macro value) set by the compiler
'Indicates if Option Explicit has been used previously in the source.
#define __FB_OPTION_GOSUB__

'Intrinsic define (macro value) set by the compiler
'Indicates if by default Function's and Sub's have module scope or global scope when not explicitly specified with Private or Public.
#define __FB_OPTION_PRIVATE__

'Intrinsic define (macro value) set by the compiler
'Indicates that the specified output file type on the compiler command line at the time of compilation is a shared library.
#define __FB_OUT_DLL__

'Intrinsic define (macro value) set by the compiler
'Indicates that the specified output file type on the compiler command line at the time of compilation is an executable.
#define __FB_OUT_EXE__

'Intrinsic define (macro value) set by the compiler
'Indicates that the specified output file type on the compiler command line at the time of compilation is a static library.
#define __FB_OUT_LIB__

'Intrinsic define (macro value) set by the compiler
'Indicates that the specified output file type on the compiler command line at the time of compilation is an object module.
#define __FB_OUT_OBJ__

'Intrinsic define set by the compiler
'Define created at compile time if the OS has filesystem behavior styled like common PC OSes, e.g. DOS, Windows, OS/2, Symbian OS, possibly others. Drive letters, backslashes, that stuff, otherwise undefined.
#define __FB_PCOS__

'Intrinsic define (macro string) set by the compiler
'Substituted by a signature of the compiler where used.
#define __FB_SIGNATURE__

'Intrinsic define set by the compiler
'Define without a value created at compile time if SSE floating point arithmetics is enabled.
#define __FB_SIGNATURE__

'Intrinsic define set by the compiler
'Define without a value created at compile time if SSE floating point arithmetics is enabled.
#define __FB_SSE__

'Intrinsic define set by the compiler
'Define created at compile time if the OS is reasonably enough like UNIX that you can call it UNIX, otherwise undefined.
#define __FB_UNIX__

'Intrinsic define set by the compiler
'Defined as the vectorisation level number set by the -vec command-line option.
#define __FB_VECTORIZE__

'Intrinsic define (macro value) set by the compiler
'Will return the major version of FreeBASIC currently being used.
#define __FB_VER_MAJOR__

'Intrinsic define (macro value) set by the compiler
'Will return the minor version of FreeBASIC currently being used.
#define __FB_VER_MINOR__

'Intrinsic define (macro value) set by the compiler
'Will return the patch/subversion/revision number the version of FreeBASIC currently being used.
#define __FB_VER_PATCH__

'Intrinsic define (macro value) set by the compiler
'Substituted by the version number of the compiler where used.
#define __FB_VERSION__

'Intrinsic define set by the compiler
'Define without a value created at compile time if compiling to the Win (32-bit or 64-bit) target.
#define __FB_WIN32__

'Intrinsic define set by the compiler
'Define without a value created at compile time when the -target xbox command line option is used.
#define __FB_XBOX__

'Intrinsic define (macro string) set by the compiler
'Substituted with the quoted source file name where used.
#define __FILE__

'Intrinsic define (macro string) set by the compiler
'Substituted with the non-quoted source file name where used.
#define __FILE_NQ__

'Intrinsic define (macro string) set by the compiler
'Substituted with the quoted name of the current function block where used.
#define __FUNCTION__

'Intrinsic define (macro string) set by the compiler
'Substituted with the non-quoted name of the current function block where used.
#define __FUNCTION_NQ__

'Intrinsic define (macro value) set by the compiler
'Substituted with the current line number of the source file where used.
#define __LINE__

'Intrinsic define (macro string) set by the compiler
'Set to the quoted absolute path of the source file at the time of compilation.
#define __PATH__

'Intrinsic define (macro value) set by the compiler
'Substitutes the compiler time in a literal string (24 clock, "hh:mm:ss" format) where used.
#define __TIME__

'Preprocessor conditional directive
'Asserts the truth of a conditional expression at compile time. If condition is false, compilation will stop with an error.
'
'Parameters
'   condition
'       A conditional expression that is assumed to be true
#define #assert condition

'Preprocessor directive to define a macro
'#define allows to declare text-based preprocessor macros.
#define #define identifier body
#define #define identifier( [ parameters ] ) body
#define #define identifier( [ parameters, ] Variadic_Parameter... ) body

'Preprocessor conditional directive
'#else can be added to an #if, #ifdef, or #ifndef block to provide an alternate result to the conditional expression.
#define #else

'Preprocessor conditional directive
'#elseif can be added to an #if block to provide an additional conditions.
#define #elseif

'Preprocessor conditional directive
'Ends a group of conditional directives
#define #endif

'Preprocessor directive to define a multiline macro
'#macro is the multi-line version of #define.
#define #endmacro

'Preprocessor diagnostic directive
'#error interrupts compiling to display error_text when compiler finds it, and then parsing continues. 
'Parameters
'   error_text
'       The display message
#define #error error_text

'Preprocessor conditional directive
'Conditionally includes statements at compile time.
#define #if (expression)

'Preprocessor conditional directive
'Conditionally includes statements at compile time.
#define #ifdef symbol

'Preprocessor conditional directive
'Conditionally includes statements at compile time.
#define #ifndef symbol

'Preprocessor directive
'Includes a library in the linking process as if the user specified -l libname on the command line.
#define #inclib "libname"

'Preprocessor statement to include contents of another source file
'#include inserts source code from another file at the point where the #include directive appears
#define #include [once] "file"

'Preprocessor statement to set the compiler dialect.
'If the -forcelang option was not given on the command line, #lang can be used to set the dialect for the source module in which it appears.
'
'Parameters
'   "lang"
'       The dialect to set, enclosed in double quotes, and must be one of "fb", "fblite", "qb", or "deprecated".
#define #lang "lang"

'Preprocessor statement to add a search path for libraries
'Adds a library search path to the linker's list of search paths as if it had been specified on the command line with the '-p' option.
#define #libpath "path"

'Preprocessor directive to set the current line number and file name
'Informs the compiler of a change in line number and file name and updates the __FILE__ and __LINE__ macro values accordingly.
#define #line number [ "name" ]

'Preprocessor directive to define a multiline macro
'#macro is the multi-line version of #define.
#define #macro identifier( [ parameters ] )
#define #macro identifier( [ parameters, ] Variadic_Parameter... )

'Preprocessor directive
'Allows the setting of compiler options inside the source code.
#define #pragma _option [ = value ]
#define #pragma push ( _option [, value ] )
#define #pragma pop ( _option )

'Preprocessor diagnostic directive
'Causes compiler to output text to screen during compilation.
#define #print text

'Preprocessor directive to undefine a macro
'Undefines a symbol previously defined with #define.
#define #undef symbol

'Metacommand to change the way arrays are allocated
''$Dynamic is a metacommand that specifies that any following array declarations are variable-length, whether they are declared with constant subscript ranges or not.
#define $Dynamic

'Metacommand statement to include contents of another source file
'$Include inserts source code from another file at the point where the $Include metacommand appears.
#define $Include [once]: 'file'

'Metacommand statement to include contents of another source file
'$Include inserts source code from another file at the point where the $Include metacommand appears.
#define $Include [once]: 'file'

'Metacommand statement to set the compiler dialect.
'If the -forcelang option was not given on the command line, $Lang can be used to set the dialect for the source module in which it appears.
'
'Parameters
'   "lang"
'       The dialect to set, enclosed in double quotes, and must be one of "fb", "fblite", "qb", or "deprecated".
#define $Lang: "lang"

'Metacommand to change the way arrays are allocated
''$Static is a metacommand that overrides the behavior of $Dynamic, that is, arrays declared with constant subscript ranges are fixed-length.
#define $Static

'Writes text to the screen
'Print outputs a list of values to the screen.
'
'Syntax
'   (Print | ?) [ expressionlist ] [ , | ; ]
'
'Parameters
'   expressionlist
'       list of items to print
#define ?

'Writes a list of values to a file or device
'Print # outputs a list of values to a text file or device.
'
'Parameters
'   filenum
'       The file number of a file or device opened for Output or Append.
'   expressionlist
'       List of values to write.
#define ?

'Outputs formatted text to the screen or output device
'Print to screen various expressions using a format determined by the formatstring parameter.
'
'Syntax
'   (Print | ?) # filenum, [ expressionlist ] [ , | ; ]
'
'Parameters
'   filenum
'       The file number of a file or device opened for Output or Append. (Alternatively LPrint may be used where appropriate, instead of Print #)
'   printexpressionlist
'       Optional preceding list of items to print, separated by commas (,) or semi-colons (;) (see Print for more details).
'   formatstring
'       Format string to use.
'   expressionlist
'       List of items to format, separated by semi-colons (;).
#define Using

'Calculates the absolute value of a number
'
'Parameters
'   number
'       Value to find the absolute value of.
Declare Function Abs ( ByVal number As Integer ) As Integer
Declare Function Abs ( ByVal number As UInteger ) As UInteger
Declare Function Abs ( ByVal number As Double ) As Double

'Declare abstract methods
'Abstract is a special form of Virtual. The difference is that abstract methods do not have a body, but just the declaration.
'
'Syntax
'   Type typename Extends base_typename
'       Declare Abstract Sub|Function|Property|Operator ...
'   End Type
#define Abstract



