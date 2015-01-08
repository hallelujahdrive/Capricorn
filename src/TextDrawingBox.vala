using Cairo;
using Gdk;
using Gtk;

using StringUtils;
using UriUtils;

class TextDrawingBox:DrawingBox{
  private media[] media_array_;
  private urls[] urls_array_;
  
  private string text_;
  private string parsed_text;
  
  //button_release_eventのcallback(override)
  protected override bool button_release_event_cb(EventButton event_button){
    base.button_release_event_cb(event_button);
    
    int index_,trailing;
    layout.xy_to_index((int)event_button.x*Pango.SCALE,(int)event_button.y*Pango.SCALE,out index_,out trailing);
    //media_arrayから検索
    for(int i=0;i<media_array_.length;i++){
      if(index_>=media_array_[i].start_indices&&index_<media_array_[i].end_indices){
        //open_url(media_array_[i].expanded_url);
        signal_pipe_.media_url_click_event(media_array_);
        break;
      }
    }
    //urls_arrayから検索
    for(int i=0;i<urls_array_.length;i++){
      if(index_>=urls_array_[i].start_indices&&index_<urls_array_[i].end_indices){
        open_url(urls_array_[i].expanded_url);
        break;
      }
    }
    return true;
  }
  
  //drawのcallback(override)
  protected override bool drawing_area_draw_cb(Context context){
    base.drawing_area_draw_cb(context);
    
    w=this.get_allocated_width();
    
    //fontcolorの設定
    context_set_source_rgba(context,config_.font_profile.text_font_rgba);
    
    layout=Pango.cairo_create_layout(context);
    //font_descriptionの設定
    layout.set_font_description(config_.font_profile.text_font_desc);
    layout.set_markup(parsed_text,-1);
    layout.set_width((int)w*Pango.SCALE);
    context.move_to(0,0);
    Pango.cairo_show_layout(context,layout);
    layout.get_pixel_size(null,out h);
    this.set_size_request(-1,h);
    
    return true;
  }
  
  public TextDrawingBox(string text,media[] media_array,urls[] urls_array,Config config,SignalPipe signal_pipe){
    config_=config;
    signal_pipe_=signal_pipe;
    
    media_array_=media_array;
    urls_array_=urls_array;
    
    text_=text;
    //縦に広がるようにする
    this.vexpand=true;
    
    //textの整形
    parsed_text=parse_text(ref text_,media_array_,urls_array_);
    get_incides(text_,media_array_,urls_array_);
  }
}
