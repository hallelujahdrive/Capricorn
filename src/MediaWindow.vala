using Gdk;
using Gtk;

[GtkTemplate(ui="/org/gtk/capricorn/ui/media_window.ui")]
class MediaWindow:Gtk.Window{
  private int num_;
  private Array<PhotoBox> photo_box_array_;
  private Config config_;
  
  private Pixbuf resized_pixbuf;
  
  [GtkChild]
  private Box left_button_box;
  
  [GtkChild]
  private ListStore liststore;
  private TextIter iter;
  
  [GtkChild]
  private EntryBuffer entrybuffer;
  
  private IconButton prev_button;
  private IconButton next_button;
  
  //Widget
  [GtkChild]
  private Image image;
  
  public MediaWindow(int num,Array<PhotoBox> photo_box_array,Config config){
    num_=num;
    photo_box_array_=photo_box_array;
    config_=config;
    
    prev_button=new IconButton(config_.prev_pixbuf,null,null);
    next_button=new IconButton(config_.next_pixbuf,null,null);
        
    left_button_box.pack_start(prev_button,false,false,0);
    left_button_box.pack_start(next_button,false,false,0);
    
    set_button_sensitive();
    
    image.set_from_pixbuf(photo_box_array.index(num).pixbuf);
    
    //シグナルハンドラ
    prev_button.clicked.connect(()=>{
      num_-=1;
      image.set_from_pixbuf(photo_box_array.index(num_).pixbuf);
      set_button_sensitive();
      return true;
    });
    
    next_button.clicked.connect(()=>{
      num_+=1;
      image.set_from_pixbuf(photo_box_array.index(num_).pixbuf);
      set_button_sensitive();
      return true;
    });
  }
  
  private void set_button_sensitive(){
    if(num_==0){
      prev_button.set_sensitive(false);
    }else{
      prev_button.set_sensitive(true);
    }
    if(num_==photo_box_array_.length-1){
      next_button.set_sensitive(false);
    }else{
      next_button.set_sensitive(true);
    }
  }
}
