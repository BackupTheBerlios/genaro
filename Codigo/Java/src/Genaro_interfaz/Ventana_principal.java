package Genaro_interfaz;

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import com.borland.jbcl.layout.*;
import javax.swing.border.*;
import javax.sound.sampled.*;

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
    contentPane.add(statusBar, BorderLayout.SOUTH);
    contentPane.add(jPanel1,  BorderLayout.CENTER);
    jPanel1.add(playButton, null);
    jPanel1.add(stopButton, null);
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
