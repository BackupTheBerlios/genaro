//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop
USERES("Interfaz_Genaro.res");
USEFORM("FormularioPrincipal.cpp", Form1);
USEUNIT("Interfaz_Prolog.cpp");
USEUNIT("Unidad_Nexo.cpp");
USEUNIT("Interfaz_Haskell.cpp");
USE("Interfaz_Genaro.todo", ToDo);
USEFORM("FormParametrosTimidity.cpp", Form2);
USEUNIT("Interfaz_Timidity.cpp");
//---------------------------------------------------------------------------
WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int)
{
  try
  {
     Application->Initialize();
     Application->CreateForm(__classid(TForm1), &Form1);
     Application->CreateForm(__classid(TForm2), &Form2);
     Application->Run();
  }
  catch (Exception &exception)
  {
     Application->ShowException(&exception);
  }
  return 0;
}
//---------------------------------------------------------------------------
