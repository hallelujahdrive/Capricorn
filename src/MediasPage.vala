using Gdk;
using Gtk;

using ImageUtils;
using UriUtils;

[GtkTemplate(ui="/org/gtk/capricorn/ui/medias_page.ui")]
class MediasPage:Frame{
  [GtkChild]
  private Grid medias_grid;
  
  [GtkCallback]
  private void close_button_clicked_cb(Button close_button){
    this.destroy();
  }
  
  public Label tab=new Label("Medias");
  public MediasPage(media[] media_array,Config config){
    for(int i=0;i<media_array.length;i++){
      Image image=new Image.from_animation(config.loading_animation_icon_pixbuf);
      medias_grid.attach(image,0,i,1,1);
      print("media_url:%s\n",media_array[i].media_url);
      get_media_pixbuf_async(media_array[i].media_url,(obj,res)=>{
        Pixbuf pixbuf=get_media_pixbuf_async.end(res);
        //pixbuf.save("/home/chiharu/debug.png","png");
        image.set_from_pixbuf(pixbuf);
      });
    }
    medias_grid.show_all();
  }
}
