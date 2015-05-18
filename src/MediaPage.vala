using Gdk;
using Gtk;
using Ruribitaki;

using ImageUtil;
using URIUtil;

[Compact]
[GtkTemplate(ui="/org/gtk/capricorn/ui/media_page.ui")]
public class MediaPage:Frame{
  private unowned medium[] media;

  private Array<PhotoBox> photo_box_array=new Array<PhotoBox>();
  
  private int height=0;
  
  //Widget
  [GtkChild]
  public Image tab;
  
  [GtkChild]
  private Viewport viewport;
  
  [GtkChild]
  private Grid media_grid;
  
  [GtkChild]
  private Box tweet_node_box;
  
  //CallBack
  //縦サイズの変更の取得
  [GtkCallback]
  private bool viewport_draw_after_cb(){
    if(height!=(height=viewport.get_allocated_height()-(int)media_grid.get_row_spacing()*2)){
      for(int i=0;i<media.length;i++){
        photo_box_array.index(i).change_allocated_height(height);
      }
    }
    return true;
  }
  
  //open_url_buttonのクリック
  [GtkCallback]
  private void open_url_button_clicked_cb(Button open_url_button){
    for(int i=0;i<media.length;i++){
      open_url(media[i].expanded_url);
    }
  }
  
  //閉じる
  [GtkCallback]
  private void close_button_clicked_cb(Button close_button){
    this.destroy();
  }
  
  public MediaPage(Node tweet_node,medium[] media,Config config){
    this.media=media;
    
    tweet_node_box.add(tweet_node);
    

    //media_arrayからの画像の読み込み
    for(int i=0;i<this.media.length;i++){
      photo_box_array.append_val(new PhotoBox(i,this.media[i].media_url,open_media_window,config));
      media_grid.attach(photo_box_array.index(i),i%2,i/2,1,1);
    }
  }
  
  private void open_media_window(int num){
    MediaWindow media_window=new MediaWindow(num,photo_box_array);
    media_window.show_all();
    
    //ページ破棄と一緒にウィンドウも破棄
    this.destroy.connect(()=>{
      media_window.destroy();
    });
  }
}
