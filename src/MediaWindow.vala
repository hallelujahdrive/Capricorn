using Gdk;
using Gtk;

[GtkTemplate(ui="/org/gtk/capricorn/ui/media_window.ui")]
class MediaWindow:Gtk.Window{
  private Pixbuf pixbuf;
  private Pixbuf resized_pixbuf;
  
  //Widget
  [GtkChild]
  private Image image;
  
  public MediaWindow(int num,Array<Pixbuf> pixbuf_array){
    image.set_from_pixbuf(pixbuf_array.index(num));
  }
}
