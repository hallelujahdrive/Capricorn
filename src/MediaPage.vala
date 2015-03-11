using Gdk;
using Gtk;

using ImageUtil;
using TwitterUtil;
using URIUtil;

[Compact]
[GtkTemplate(ui="/org/gtk/capricorn/ui/media_page.ui")]
public class MediaPage:Frame{
  private unowned media[] _media_array;

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
      for(int i=0;i<_media_array.length;i++){
        photo_box_array.index(i).change_allocated_height(height);
      }
    }
    return true;
  }
  
  //open_url_buttonのクリック
  [GtkCallback]
  private void open_url_button_clicked_cb(Button open_url_button){
    for(int i=0;i<_media_array.length;i++){
      open_url(_media_array[i].expanded_url);
    }
  }
  
  //閉じる
  [GtkCallback]
  private void close_button_clicked_cb(Button close_button){
    this.destroy();
  }
  
  public MediaPage(TweetNode tweet_node,media[] media_array){
    _media_array=media_array;
    
    tweet_node_box.add(tweet_node);

    //media_arrayからの画像の読み込み
    for(int i=0;i<_media_array.length;i++){
      PhotoBox photo_box=new PhotoBox(i,_media_array[i].media_url,open_media_window);
      photo_box_array.append_val(photo_box);
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
