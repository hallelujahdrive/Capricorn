using Gdk;
using Gtk;

using ImageUtil;
using TwitterUtil;

[GtkTemplate(ui="/org/gtk/capricorn/ui/media_window.ui")]
class MediaWindow:Gtk.Window{
  private int num;
  private unowned Array<PhotoBox> photo_box_array;
  
  private Pixbuf resized_pixbuf;
  
  //widget
  [GtkChild]
  private Viewport viewport;  
  
  [GtkChild]
  private Box left_button_box;
  
  [GtkChild]
  private Box right_button_box;
  
  [GtkChild]
  private ComboBox combobox;
  
  [GtkChild]
  private ListStore liststore;
  private TreeIter iter;
  
  [GtkChild]
  private EntryBuffer entrybuffer;
  
  private IconButton prev_button;
  private IconButton next_button;
  
  [GtkChild]
  private Image image;
  
  //コールバック
  [GtkCallback]
  private void combobox_changed_cb(){
    if(combobox.get_active_iter(out iter)){
      Value val;
      liststore.get_value(iter,1,out val);
      set_pixbuf((double)val);
    }
  }
  
  //エントリへの入力で拡大率設定
  [GtkCallback]
  private void combobox_entry_activate_cb(){
    double mag=double.parse(entrybuffer.text);
    
    if(mag<12.5){
      mag=12.5;
    }
    set_pixbuf(mag/100);
    entrybuffer.set_text((uchar[])("%.1f%%".printf(mag)));
  }
  
  public MediaWindow(int num,Array<PhotoBox> photo_box_array){
    this.num=num;
    this.photo_box_array=photo_box_array;
   
    prev_button=new IconButton(PREV_ICON,null,null,IconSize.LARGE_TOOLBAR);
    next_button=new IconButton(NEXT_ICON,null,null,IconSize.LARGE_TOOLBAR);
        
    left_button_box.pack_start(prev_button,false,false,0);
    left_button_box.pack_start(next_button,false,false,0);
    
    set_button_sensitive();

    //シグナルハンドラ
    this.show.connect_after(()=>{
      set_default_size_pixbuf();
    });
    
    prev_button.clicked.connect(()=>{
      this.num-=1;
      set_default_size_pixbuf();
      set_button_sensitive();
      return true;
    });
    
    next_button.clicked.connect(()=>{
      this.num+=1;
      set_default_size_pixbuf();
      set_button_sensitive();
      return true;
    });
  }
  
  //ボタンのsensitiveを設定
  private void set_button_sensitive(){
    if(num==0){
      prev_button.set_sensitive(false);
    }else{
      prev_button.set_sensitive(true);
    }
    if(num==photo_box_array.length-1){
      next_button.set_sensitive(false);
    }else{
      next_button.set_sensitive(true);
    }
  }
  
  //デフォルトの倍率
  private void set_default_size_pixbuf(){
    double mag;
    Allocation allocation;
    
    viewport.get_allocation(out allocation);
    if(photo_box_array.index(num).pixbuf.width<=allocation.width&&photo_box_array.index(num).pixbuf.height<=allocation.height){
      combobox.active=3;
      mag=1;
    }else{
      double w_mag=(double)allocation.width/photo_box_array.index(num).pixbuf.width;
      double h_mag=(double)allocation.height/photo_box_array.index(num).pixbuf.height;
      mag=w_mag<h_mag?w_mag:h_mag;
      entrybuffer.set_text((uchar[])"%.1f%%".printf(mag*100));
    }
    set_pixbuf(mag);
  }
  
  //pixbufのセット
  private void set_pixbuf(double mag){
    resized_pixbuf=scale_pixbuf_with_magnifaction(mag,photo_box_array.index(num).pixbuf);
    image.set_from_pixbuf(resized_pixbuf);
  }
}
