//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop
USERES("BEditor.res");
USEFORM("EditorB.cpp", Form1);
USEUNIT("TiposAbstractos.cpp");
USE("BEditor.todo", ToDo);
//---------------------------------------------------------------------------
WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int)
{
        try
        {
                 Application->Initialize();
                 Application->CreateForm(__classid(TForm1), &Form1);
     Application->Run();
        }
        catch (Exception &exception)
        {
                 Application->ShowException(&exception);
        }
        return 0;
}
//---------------------------------------------------------------------------
