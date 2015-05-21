using Cairo;
using Gdk;
using Gtk;
using Ruribitaki;

using StringUtil;
using URIUtil;

class TextDrawingBox:DrawingBox{
  private weak Ruribitaki.Status status;
  private weak CapricornAccount cpr_account;
  private string text;
  private string parsed_text;
  
  //button_release_eventのcallback(override)
  protected override bool button_release_event_cb(EventButton event_button){
    base.button_release_event_cb(event_button);
    
    int index_,trailing;
    layout.xy_to_index((int)event_button.x*Pango.SCALE,(int)event_button.y*Pango.SCALE,out index_,out trailing);
    //entities_hashtagsから検索
    for(int i=0;i<status.entities_hashtags.length;i++){
      if(index_>=status.entities_hashtags[i].indices[0]&&index_<status.entities_hashtags[i].indices[1]){
        main_window.post_page.add_text(" #%s".printf(status.entities_hashtags[i].text),cpr_account.list_id);
        break;
      }
    }
    //entities_mediaから検索
    for(int i=0;i<status.entities_media.length;i++){
      if(index_>=status.entities_media[i].indices[0]&&index_<status.entities_media[i].indices[1]){
        weak TweetNode parent=(TweetNode)this.get_parent();
        //MediaPageに渡すのはextended_entities_media
        main_window.open_media_page(parent.copy(),status.entities_media,status.extended_entities_media);
        break;
      }
    }
    //entities_urlsから検索
    for(int i=0;i<status.entities_urls.length;i++){
      if(index_>=status.entities_urls[i].indices[0]&&index_<status.entities_urls[i].indices[1]){
        open_url(status.entities_urls[i].expanded_url);
        break;
      }
    }
    return true;
  }
  
  //drawのcallback(override)
  protected override bool drawing_area_draw_cb(Context context){
    base.drawing_area_draw_cb(context);
    
    width=this.get_allocated_width();
    
    //fontcolorの設定
    context_set_source_rgba(context,config.font_profile.text_font_rgba);
    
    layout=Pango.cairo_create_layout(context);
    //font_descriptionの設定
    layout.set_font_description(config.font_profile.text_font_desc);
    layout.set_markup(parsed_text,-1);
    layout.set_width((int)width*Pango.SCALE);
    context.move_to(0,0);
    Pango.cairo_show_layout(context,layout);
    layout.get_pixel_size(null,out height);
    this.set_size_request(-1,height);
    
    return true;
  }
  
  public TextDrawingBox(Ruribitaki.Status status,CapricornAccount cpr_account,Config config,MainWindow main_window){
    base(config,main_window);
    
    this.status=status;
    this.cpr_account=cpr_account;
    text=this.status.text;
        
    //縦に広がるようにする
    this.vexpand=true;
    
    //textの整形
    parsed_text=parse_text(ref text,this.status.entities_hashtags,this.status.entities_media,this.status.entities_urls);
    update_indices(text,this.status.entities_hashtags,this.status.entities_media,this.status.entities_urls);
  }
}
