/* Included by gcc (build-native.bat: -Wc -include) in the C code of the IDE for Android.
   The library runs its constructors in the order of .init_array: there the main code of the IDE
   (__fb_DllMain_ctor) is before the constructors of the shared objects (_GLOBAL__I), so the main code
   used objects which were not constructed yet. With priorities the FB runtime is initialized first
   (fb_hRtInit counts its calls, fbrt0 calls it again later), then the shared objects, then the main code. */
void fb_hRtInit( void );
static void __fb_hRtInitFirst( void ) __attribute__(( constructor( 101 ) ));
static void __fb_hRtInitFirst( void ) { fb_hRtInit( ); }
#define _GLOBAL__I( v ) __attribute__(( constructor( 102 ) )) _GLOBAL__I_Priority( v )
