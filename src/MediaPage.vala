using Gdk;
using Gtk;

using ImageUtils;
using UriUtils;

[GtkTemplate(ui="/org/gtk/capricorn/ui/media_page.ui")]
class MediaPage:Frame{
  private media[] media_array_;
    
  private Config config_;
  private SignalPipe signal_pipe_;
  
  private Array<PhotoBox> photo_box_array=new Array<PhotoBox>();
    
  private MediaWindow media_window;
  
  //Widget
  [GtkChild]
  public Image tab;
  
  [GtkChild]
  private Viewport viewport;
  
  [GtkChild]
  private Grid media_grid;
  
  [GtkChild]
  private Box tweet_node_box;
  
  [GtkCallback]
  private void open_url_button_clicked_cb(Button open_url_button){
    for(int i=0;i<media_array_.length;i++){
      open_url(media_array_[i].expanded_url);
    }
  }
  
  [GtkCallback]
  private void close_button_clicked_cb(Button close_button){
    this.destroy();
  }
  
  public MediaPage(media[] media_array,TweetNode tweet_node,Config config,SignalPipe signal_pipe){
    media_array_=media_array;
    config_=config;
    signal_pipe_=signal_pipe;
    
    tweet_node_box.add(tweet_node);
    
    //tabの画像のセット
    tab.set_from_pixbuf(config_.media_pixbuf);

    //media_arrayからの画像の読み込み
    for(int i=0;i<media_array_.length;i++){
      PhotoBox photo_box=new PhotoBox(i,media_array_[i].media_url,open_media_window);
      photo_box_array.append_val(photo_box);
      media_grid.attach(photo_box_array.index(i),i%2,i/2,1,1);
    }
  }
  
  private void open_media_window(int num){
    media_window=new MediaWindow(num,photo_box_array,config_);
    media_window.show_all();
    
    //ページ破棄と一緒にウィンドウも破棄
    this.destroy.connect(()=>{
      media_window.destroy();
    });
  }
}
