//---------------------------------------------------------------------------

#include <vcl.h>
#include <fstream.h>
#include <windows.h>
#include <process.h>
#pragma hdrstop

#include "Interfaz_Timidity.h"

//---------------------------------------------------------------------------

#pragma package(smart_init)

int Ejecuta_Timidity_Reproduccion(String timi_exe, String Amplificacion_Volumen,String EFchorus,String EFreverb,String EFdelay,String frecuency,String Ruta_Patch_File,String Ruta_Midi)
{
String arg1="-int";//opciones de inferfaz
String arg2="-a";//activar antialiasing
String arg3="-p";//polifonia
String arg4="256(a)";
String arg5="-U";//Unload instruments entre cancion y cancion
String arg6="A"+Amplificacion_Volumen;
String arg7="Ww";//mas opciones de inferfaz
String arg8="EFchorus="+EFchorus;
String arg9="EFreverb="+EFreverb;
String arg10="EFdelay="+EFdelay;
String arg11="s"+frecuency;
String arg12="-P";//patch file
String arg13=Ruta_Patch_File;
int valor_spawn;
if (Ruta_Patch_File=="none")
{
  valor_spawn=spawnl(P_NOWAIT	,timi_exe.c_str(),timi_exe.c_str(),arg1.c_str(),arg2.c_str(),arg3.c_str(),arg4.c_str(),arg5.c_str(),arg6.c_str(),arg7.c_str(),arg8.c_str(),arg9.c_str(),arg10.c_str(),arg11.c_str(),Ruta_Midi.c_str(),NULL);
}
else
{
  valor_spawn=spawnl(P_NOWAIT	,timi_exe.c_str(),timi_exe.c_str(),arg1.c_str(),arg2.c_str(),arg3.c_str(),arg4.c_str(),arg5.c_str(),arg6.c_str(),arg7.c_str(),arg8.c_str(),arg9.c_str(),arg10.c_str(),arg11.c_str(),arg12.c_str(),arg13.c_str(),Ruta_Midi.c_str(),NULL);
}
return valor_spawn;
}
//---------------------------------------------------------------------------

int Ejecuta_Timidity_Conversion(String timi_exe, String Amplificacion_Volumen,String EFchorus,String EFreverb,String EFdelay,String frecuency,String Ruta_Patch_File,String Ruta_Midi)
{
String arg1="-int";//opciones de inferfaz
String arg2="-a";//activar antialiasing
String arg3="-p";//polifonia
String arg4="256(a)";
String arg5="-U";//Unload instruments entre cancion y cancion
String arg6="A"+Amplificacion_Volumen;
String arg7="Ww";//mas opciones de inferfaz
String arg8="EFchorus="+EFchorus;
String arg9="EFreverb="+EFreverb;
String arg10="EFdelay="+EFdelay;
String arg11="s"+frecuency;
String arg11b="-OwS";
String arg12="-P";//patch file
String arg13=Ruta_Patch_File;
int valor_spawn;
if (Ruta_Patch_File=="none")
{
  valor_spawn=spawnl(P_NOWAIT,timi_exe.c_str(),timi_exe.c_str(),arg1.c_str(),arg2.c_str(),arg3.c_str(),arg4.c_str(),arg5.c_str(),arg6.c_str(),arg7.c_str(),arg8.c_str(),arg9.c_str(),arg10.c_str(),arg11.c_str(),arg11b.c_str(),Ruta_Midi.c_str(),NULL);
}
else
{
  valor_spawn=spawnl(P_NOWAIT,timi_exe.c_str(),timi_exe.c_str(),arg1.c_str(),arg2.c_str(),arg3.c_str(),arg4.c_str(),arg5.c_str(),arg6.c_str(),arg7.c_str(),arg8.c_str(),arg9.c_str(),arg10.c_str(),arg11.c_str(),arg12.c_str(),arg13.c_str(),arg11b.c_str(),Ruta_Midi.c_str(),NULL);
}
return valor_spawn;
}