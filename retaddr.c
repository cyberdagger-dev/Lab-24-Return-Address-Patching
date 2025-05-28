#include <windows.h>
#include <stdio.h>

/*
Find a gadget by searching the text section of a given module

@ Params
    Module      - A pointer to the base of the module to search through
    GadgetBytes - A string representing the hex bytes of the gadget
    GadgetAddr  - A pointer to a pointer; it will be populated if a gadget is successfully found

@ Return
    1 for success, 0 for failure
*/
BOOLEAN FindGadget( PBYTE Module, LPSTR GadgetBytes, PVOID* GadgetAddr )
{
    if ( !GadgetAddr ) {
        return FALSE;
    }

    PIMAGE_NT_HEADERS   NT   = Module + ( ( PIMAGE_DOS_HEADER ) Module )->e_lfanew;
    PVOID               Base = Module + IMAGE_FIRST_SECTION( NT )->VirtualAddress; 
    DWORD               Size = IMAGE_FIRST_SECTION( NT )->SizeOfRawData;
    DWORD               SzGt = strlen( GadgetBytes );

    // Iterate through the .text section and find a gadget
    for ( PBYTE current = Base; current <= Base + Size-SzGt; current++ ) {
        if ( !memcmp( current, GadgetBytes, SzGt ) ) {
            *GadgetAddr = current;
            return TRUE;
        }
    }

    return FALSE;
}

void main()
{
    PVOID Gadget = NULL;

    // 0xffd3 is a `call r12` gadget; the code Spoof function is implemented for that
    if ( !FindGadget( GetModuleHandleA( "ntdll.dll" ), "\x41\xff\xd4", &Gadget ) ) {
        printf( "We could not find a gadget!" );
        return;
    }

    MessageBoxA( NULL, "Normal MessageBox call", "WKLSEC", MB_OK );
    Patch( Sleep, 1, Gadget, 1000 * 5 );
    Patch( MessageBoxA, 4, Gadget, NULL, "WKLSEC", "WKLSEC", MB_OK );
}