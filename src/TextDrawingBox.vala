using Cairo;
using Gdk;
using Gtk;

using StringUtil;
using TwitterUtil;
using URIUtil;

class TextDrawingBox:DrawingBox{
  private weak ParsedJsonObj parsed_json_obj;
  private string text;
  private string parsed_text;
  
  //button_release_eventのcallback(override)
  protected override bool button_release_event_cb(EventButton event_button){
    base.button_release_event_cb(event_button);
    
    int index_,trailing;
    layout.xy_to_index((int)event_button.x*Pango.SCALE,(int)event_button.y*Pango.SCALE,out index_,out trailing);
    //media_arrayから検索
    for(int i=0;i<parsed_json_obj.media_array.length;i++){
      if(index_>=parsed_json_obj.media_array[i].start_indices&&index_<parsed_json_obj.media_array[i].end_indices){
        weak TweetNode parent=(TweetNode)this.get_parent();
        signal_pipe.media_url_click_event(parent.copy(),parsed_json_obj.media_array);
        break;
      }
    }
    //urls_arrayから検索
    for(int i=0;i<parsed_json_obj.urls_array.length;i++){
      if(index_>=parsed_json_obj.urls_array[i].start_indices&&index_<parsed_json_obj.urls_array[i].end_indices){
        open_url(parsed_json_obj.urls_array[i].expanded_url);
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
  
  public TextDrawingBox(ParsedJsonObj parsed_json_obj,Config config,SignalPipe signal_pipe){
    base(config,signal_pipe);
    
    this.parsed_json_obj=parsed_json_obj;
    text=this.parsed_json_obj.text;
        
    //縦に広がるようにする
    this.vexpand=true;
    
    //textの整形
    parsed_text=parse_text(ref text,this.parsed_json_obj.media_array,this.parsed_json_obj.urls_array);
    get_incides(text,this.parsed_json_obj.media_array,this.parsed_json_obj.urls_array);
  }
  
  private void open_media_page(){
    
  }
}
