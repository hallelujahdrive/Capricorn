using Gdk;
using Gtk;

using ImageUtils;
using UriUtils;

[GtkTemplate(ui="/org/gtk/capricorn/ui/medias_page.ui")]
class MediasPage:Frame{
  private media[] media_array_;
  
  [GtkChild]
  private Grid medias_grid;
  
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
  
  public Label tab=new Label("Medias");
  public MediasPage(media[] media_array,TweetNode tweet_node,Config config){
    media_array_=media_array;
    tweet_node_box.add(tweet_node);
    
    for(int i=0;i<media_array_.length;i++){
      PhotoBox photo_box=new PhotoBox(media_array_[i]);
      medias_grid.attach(photo_box,i%2,i/2,1,1);
    }
  }
}
