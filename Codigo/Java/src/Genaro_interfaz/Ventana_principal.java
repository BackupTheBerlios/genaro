package Genaro_interfaz;

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import com.borland.jbcl.layout.*;
import javax.swing.border.*;
import javax.sound.sampled.*;
import java.io.*;

/**
 * <p>Título: </p>
 * <p>Descripción: </p>
 * <p>Copyright: Copyright (c) 2004</p>
 * <p>Empresa: </p>
 * @author sin atribuir
 * @version 1.0
 */

public class Ventana_principal extends JFrame implements Runnable{
  String rutaArchivoSonido = null;
  AudioInputStream audioInputStream;
  SourceDataLine sourceDataLine = null;
  int bufferSize;
  byte soundData[];
  Thread thread;
  boolean sampleStreaming = false;

  JPanel contentPane;
  JLabel statusBar = new JLabel();
  BorderLayout borderLayout1 = new BorderLayout();
  JPanel jPanel1 = new JPanel();
  JButton stopButton = new JButton();
  JButton playButton = new JButton();
  JButton cargarButton = new JButton();
  TitledBorder titledBorder1;
  JButton jButton1 = new JButton();
  JButton jButton2 = new JButton();

  //Construir el marco
  public Ventana_principal() {
    enableEvents(AWTEvent.WINDOW_EVENT_MASK);
    try {
      jbInit();
    }
    catch(Exception e) {
      e.printStackTrace();
    }
  }

  private void iniciarSonido(){
    java.io.File soundFile = new java.io.File(this.rutaArchivoSonido);
    try{
      this.audioInputStream = AudioSystem.getAudioInputStream(soundFile);
      if(this.audioInputStream.markSupported()){
        this.audioInputStream.mark(Integer.MAX_VALUE);
      }
      AudioFormat format = this.audioInputStream.getFormat();
      DataLine.Info audioInputStreamInfo =
          new DataLine.Info(SourceDataLine.class, format);
      if(AudioSystem.isLineSupported(audioInputStreamInfo)){
        sourceDataLine = (SourceDataLine) AudioSystem.getLine(audioInputStreamInfo);
        bufferSize = (int) (format.getFrameSize()*format.getFrameRate()/2.0f);
        this.statusBar.setText("Establecido tamaño del buffer a " + bufferSize);
        sourceDataLine.open(format, bufferSize);
        soundData = new byte[bufferSize];
      }
    }catch(UnsupportedAudioFileException e1){
      JOptionPane.showMessageDialog(null, "Fichero de audio no soportado","Error",JOptionPane.ERROR_MESSAGE);
    }catch(LineUnavailableException e2){
      JOptionPane.showMessageDialog(null, "Linea no soportada","Error",JOptionPane.ERROR_MESSAGE);
    }catch(java.io.IOException e3){
      JOptionPane.showMessageDialog(null, "Excepcion de entrada/salida","Error",JOptionPane.ERROR_MESSAGE);
    }
  }

  //Inicialización de componentes
  private void jbInit() throws Exception  {
    contentPane = (JPanel) this.getContentPane();
    titledBorder1 = new TitledBorder("");
    contentPane.setLayout(borderLayout1);
    this.setSize(new Dimension(400, 300));
    this.setTitle("Genaro");
    statusBar.setBorder(BorderFactory.createLoweredBevelBorder());
    statusBar.setText(" ");
    stopButton.setText("Stop");
    stopButton.addMouseListener(new Ventana_principal_stopButton_mouseAdapter(this));
    playButton.setText("Play");
    playButton.addMouseListener(new Ventana_principal_playButton_mouseAdapter(this));
    cargarButton.setText("Cargar");
    cargarButton.addActionListener(new Ventana_principal_cargarButton_actionAdapter(this));
    cargarButton.addMouseListener(new Ventana_principal_cargarButton_mouseAdapter(this));
    jButton1.setOpaque(true);
    jButton1.setText("jButton1");
    jButton1.addMouseListener(new Ventana_principal_jButton1_mouseAdapter(this));
    jButton2.setText("jButton2");
    jButton2.addActionListener(new Ventana_principal_jButton2_actionAdapter(this));
    contentPane.add(statusBar, BorderLayout.SOUTH);
    contentPane.add(jPanel1,  BorderLayout.CENTER);
    jPanel1.add(playButton, null);
    jPanel1.add(stopButton, null);
    jPanel1.add(jButton1, null);
    jPanel1.add(jButton2, null);
    contentPane.add(cargarButton, BorderLayout.NORTH);
  }
  //Modificado para poder salir cuando se cierra la ventana
  protected void processWindowEvent(WindowEvent e) {
    super.processWindowEvent(e);
    if (e.getID() == WindowEvent.WINDOW_CLOSING) {
      System.exit(0);
    }
  }

  void cargarButton_mouseClicked(MouseEvent e) {
    JFileChooser jFileChooser = new JFileChooser(".");
    int valorDevuelto = jFileChooser.showOpenDialog(this);
    if(valorDevuelto == JFileChooser.APPROVE_OPTION){
      this.rutaArchivoSonido = jFileChooser.getSelectedFile().getAbsolutePath();
      this.statusBar.setText("Cargado " + jFileChooser.getSelectedFile().getName());
      this.iniciarSonido();
    }
  }

  void playButton_mouseClicked(MouseEvent e) {
    if(sourceDataLine == null){
      JOptionPane.showMessageDialog(null, "Linea no disponible", "Error", JOptionPane.ERROR_MESSAGE);
      return;
    }
    thread = new Thread(this);
    sampleStreaming = true;
    thread.start();
  }

  void cargarButton_actionPerformed(ActionEvent e) {

  }

  void stopButton_mouseClicked(MouseEvent e) {
    sampleStreaming = false;
  }

  public void run(){
    sourceDataLine.start();
    int readBytes = 0;
    try{
      while(sampleStreaming){
        readBytes = audioInputStream.read(soundData, 0 , soundData.length);
        if(readBytes == -1){
          if(audioInputStream.markSupported()){
            audioInputStream.reset();
          }
          sourceDataLine.drain();
          sampleStreaming = false;
          break;
        }
        sourceDataLine.write(soundData, 0, readBytes);
      }
    }catch(java.io.IOException e1){
      JOptionPane.showMessageDialog(null, e1.toString(), "ERROR", JOptionPane.ERROR_MESSAGE);
    }
    sourceDataLine.stop();
  }

/*cosa cutre provisional*/
  void jButton1_mouseClicked(MouseEvent e) {
   /*lala*/
   String jarDeJasper = "-Cargar biblioteca jasper en java : " + "\n"
                          + "Herramientas->ConfigurarJdk"+ "\n"
                                 + "Añadir: el archivo C:/JBuilderX/jdk1.4/lib/jasper.jar";
   String ayudaDeJasper = "-Ayuda de Jasper : "+ "\n"
       +"C:/Archivos de programa/SICStus Prolog/doc/html/jasper/se/sics/jasper/sicstus.html";
   JOptionPane.showMessageDialog(this, jarDeJasper + "\n" + ayudaDeJasper);

  }

  void jButton2_actionPerformed(ActionEvent e)
  {
    String Ruta_codigo_haskell;
    String Ruta_haskell;
    String Ruta_prolog;
    String Ruta_codigo_prolog;
    FileReader fichero_conf;
    try
    {
      fichero_conf=new FileReader("configuracion.cfg");
      char[] buffer1;
      char[] buffer2;
      char[] buffer3;
      char[] buffer4;
      int tamano_string=0;
      tamano_string=fichero_conf.read();
      buffer1=new char[tamano_string];
      fichero_conf.read(buffer1,0,tamano_string);
      Ruta_prolog=new String(buffer1);

      tamano_string=fichero_conf.read();
      buffer2=new char[tamano_string];
      fichero_conf.read(buffer2,0,tamano_string);
      Ruta_codigo_prolog=new String(buffer2);

      tamano_string=fichero_conf.read();
      buffer3=new char[tamano_string];
      fichero_conf.read(buffer3,0,tamano_string);
      Ruta_haskell=new String(buffer3);

      tamano_string=fichero_conf.read();
      buffer4=new char[tamano_string];
      fichero_conf.read(buffer4,0,tamano_string);
      Ruta_codigo_haskell=new String(buffer4);

  /*    write public void write(String str,
                  int off,
                  int len)
           throws IOExceptionWrite a portion of a string. Overrides:write in class Writer Parameters:str - A Stringoff - Offset from which to start writing characterslen - Number of characters to write
*/
    }
    catch (IOException nohayfichero)
    {
      Ruta_prolog="";
      Ruta_codigo_haskell="";
      Ruta_haskell="";
      Ruta_codigo_prolog="";

      FileWriter fichero_escritura;
      try
      {
        fichero_escritura = new FileWriter("configuracion.cfg");
        //1- elegir archivo sicstus.exe
        JFileChooser jFileChooser1 = new JFileChooser(".");
        jFileChooser1.setDialogTitle(
            "Escoge la localización del programa \"sicstus.exe\"");
        int valorDevuelto = jFileChooser1.showOpenDialog(this);
        if (valorDevuelto == JFileChooser.APPROVE_OPTION)
        {
          Ruta_prolog = jFileChooser1.getSelectedFile().getAbsolutePath();
          fichero_escritura.write(Ruta_prolog.length());
          fichero_escritura.write(Ruta_prolog,0,Ruta_prolog.length());
        }
        //2- elegir el directorio del código prolog
        JFileChooser jFileChooser2 = new JFileChooser(".");
        jFileChooser2.setDialogTitle(
            "Escoge la localización del código que vais a emplear para prolog");
        valorDevuelto = jFileChooser2.showOpenDialog(this);
        if (valorDevuelto == JFileChooser.APPROVE_OPTION)
        {
          Ruta_codigo_prolog = jFileChooser2.getCurrentDirectory().getAbsolutePath();
          fichero_escritura.write(Ruta_codigo_prolog.length());
          fichero_escritura.write(Ruta_codigo_prolog,0,Ruta_codigo_prolog.length());
        }
        //3- localizacion runhugs.exe
        JFileChooser jFileChooser3 = new JFileChooser(".");
        jFileChooser3.setDialogTitle(
            "Escoge la localización del programa \"runhugs.exe\"");
        valorDevuelto = jFileChooser3.showOpenDialog(this);
        if (valorDevuelto == JFileChooser.APPROVE_OPTION)
        {
          Ruta_haskell = jFileChooser3.getSelectedFile().getAbsolutePath();
          fichero_escritura.write(Ruta_haskell.length());
          fichero_escritura.write(Ruta_haskell,0,Ruta_haskell.length());
        }
        //4- elegir el directorio del código haskell
        JFileChooser jFileChooser4 = new JFileChooser(".");
        jFileChooser4.setDialogTitle(
            "Escoge la localización del código que vais a emplear para haskell");
        valorDevuelto = jFileChooser4.showOpenDialog(this);
        if (valorDevuelto == JFileChooser.APPROVE_OPTION)
        {
          Ruta_codigo_haskell = jFileChooser4.getCurrentDirectory().getAbsolutePath();
          fichero_escritura.write(Ruta_codigo_haskell.length());
          fichero_escritura.write(Ruta_codigo_haskell,0,Ruta_codigo_haskell.length());
        }
        fichero_escritura.close();
      }
      catch (IOException excp)
      {System.out.println("error escribiendo fichero configuración");}
    }
    Interfaz_Prolog nuevo_int_prolog=new Interfaz_Prolog(Ruta_prolog,Ruta_codigo_prolog);
    nuevo_int_prolog.Ejecuta_Objetivo("generador_acordes.pl","genera_acordes(10,10,paralelo)");
    Interfaz_Haskell nuevo_int_haskell=new Interfaz_Haskell(Ruta_haskell,Ruta_codigo_haskell);
    nuevo_int_haskell.Ejecuta_Funcion("main.hsx");
  }

}

class Ventana_principal_cargarButton_mouseAdapter extends java.awt.event.MouseAdapter {
  Ventana_principal adaptee;

  Ventana_principal_cargarButton_mouseAdapter(Ventana_principal adaptee) {
    this.adaptee = adaptee;
  }
  public void mouseClicked(MouseEvent e) {
    adaptee.cargarButton_mouseClicked(e);
  }
}

class Ventana_principal_playButton_mouseAdapter extends java.awt.event.MouseAdapter {
  Ventana_principal adaptee;

  Ventana_principal_playButton_mouseAdapter(Ventana_principal adaptee) {
    this.adaptee = adaptee;
  }
  public void mouseClicked(MouseEvent e) {
    adaptee.playButton_mouseClicked(e);
  }
}

class Ventana_principal_cargarButton_actionAdapter implements java.awt.event.ActionListener {
  Ventana_principal adaptee;

  Ventana_principal_cargarButton_actionAdapter(Ventana_principal adaptee) {
    this.adaptee = adaptee;
  }
  public void actionPerformed(ActionEvent e) {
    adaptee.cargarButton_actionPerformed(e);
  }
}

class Ventana_principal_stopButton_mouseAdapter extends java.awt.event.MouseAdapter {
  Ventana_principal adaptee;

  Ventana_principal_stopButton_mouseAdapter(Ventana_principal adaptee) {
    this.adaptee = adaptee;
  }
  public void mouseClicked(MouseEvent e) {
    adaptee.stopButton_mouseClicked(e);
  }
}

class Ventana_principal_jButton1_mouseAdapter extends java.awt.event.MouseAdapter {
  Ventana_principal adaptee;

  Ventana_principal_jButton1_mouseAdapter(Ventana_principal adaptee) {
    this.adaptee = adaptee;
  }
  public void mouseClicked(MouseEvent e) {
    adaptee.jButton1_mouseClicked(e);
  }
}

class Ventana_principal_jButton2_actionAdapter implements java.awt.event.ActionListener {
  Ventana_principal adaptee;

  Ventana_principal_jButton2_actionAdapter(Ventana_principal adaptee) {
    this.adaptee = adaptee;
  }
  public void actionPerformed(ActionEvent e) {
    adaptee.jButton2_actionPerformed(e);
  }
}
