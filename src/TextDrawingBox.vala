using Cairo;
using Gdk;
using Gtk;

using StringUtil;
using TwitterUtil;
using URIUtil;

class TextDrawingBox:DrawingBox{
  private weak ParsedJsonObj parsed_json_obj;
  private weak Account account;
  private string text;
  private string parsed_text;
  
  //button_release_eventのcallback(override)
  protected override bool button_release_event_cb(EventButton event_button){
    base.button_release_event_cb(event_button);
    
    int index_,trailing;
    layout.xy_to_index((int)event_button.x*Pango.SCALE,(int)event_button.y*Pango.SCALE,out index_,out trailing);
    //hashtagsから検索
    for(int i=0;i<parsed_json_obj.hashtags.length;i++){
      if(index_>=parsed_json_obj.hashtags[i].indices[0]&&index_<parsed_json_obj.hashtags[i].indices[1]){
        signal_pipe.add_text_event(" #%s".printf(parsed_json_obj.hashtags[i].text),null,account.my_list_id);
        break;
      }
    }
    //mediaから検索
    for(int i=0;i<parsed_json_obj.media.length;i++){
      if(index_>=parsed_json_obj.media[i].indices[0]&&index_<parsed_json_obj.media[i].indices[1]){
        weak TweetNode parent=(TweetNode)this.get_parent();
        signal_pipe.media_url_click_event(parent.copy(),parsed_json_obj.media);
        break;
      }
    }
    //urlsから検索
    for(int i=0;i<parsed_json_obj.urls.length;i++){
      if(index_>=parsed_json_obj.urls[i].indices[0]&&index_<parsed_json_obj.urls[i].indices[1]){
        open_url(parsed_json_obj.urls[i].expanded_url);
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
  
  public TextDrawingBox(ParsedJsonObj parsed_json_obj,Account account,Config config,SignalPipe signal_pipe){
    base(config,signal_pipe);
    
    this.parsed_json_obj=parsed_json_obj;
    this.account=account;
    text=this.parsed_json_obj.text;
        
    //縦に広がるようにする
    this.vexpand=true;
    
    //textの整形
    parsed_text=parse_text(ref text,this.parsed_json_obj.hashtags,this.parsed_json_obj.media,this.parsed_json_obj.urls);
    update_indices(text,this.parsed_json_obj.hashtags,this.parsed_json_obj.media,this.parsed_json_obj.urls);
  }
}
