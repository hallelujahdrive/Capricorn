using Gdk;
using Gtk;

class Tab:EventImage{

  //コンストラクタ  
  //icon_nameから画像を設定
  public Tab.from_icon_name(string icon_name,IconSize icon_size){
    image.set_from_icon_name(icon_name,icon_size);
  }

  //pixbufのset
  public void set_from_pixbuf(Pixbuf pixbuf){
    image.set_from_pixbuf(pixbuf);
  }
}
