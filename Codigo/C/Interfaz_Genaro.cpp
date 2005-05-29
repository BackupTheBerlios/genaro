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
USEUNIT("Tipos_Estructura.cpp");
USEFORM("UForm_Melodia.cpp", Form_Melodia);
USEFORM("Form_Editar_Progresion.cpp", Form3);
//---------------------------------------------------------------------------
WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int)
{
  try
  {
     Application->Initialize();
     Application->CreateForm(__classid(TForm1), &Form1);
     Application->CreateForm(__classid(TForm2), &Form2);
     Application->CreateForm(__classid(TForm_Melodia), &Form_Melodia);
     Application->CreateForm(__classid(TForm3), &Form3);
     Application->Run();
  }
  catch (Exception &exception)
  {
     Application->ShowException(&exception);
  }
  return 0;
}
//---------------------------------------------------------------------------
