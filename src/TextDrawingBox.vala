using Cairo;
using Gdk;
using Gtk;

using StringUtil;
using TwitterUtil;
using URIUtil;

class TextDrawingBox:DrawingBox{
  private media[] _media_array;
  private urls[] _urls_array;
  
  private string text_;
  private string parsed_text;
  
  //button_release_eventのcallback(override)
  protected override bool button_release_event_cb(EventButton event_button){
    base.button_release_event_cb(event_button);
    
    int index_,trailing;
    layout.xy_to_index((int)event_button.x*Pango.SCALE,(int)event_button.y*Pango.SCALE,out index_,out trailing);
    //media_arrayから検索
    for(int i=0;i<_media_array.length;i++){
      if(index_>=_media_array[i].start_indices&&index_<_media_array[i].end_indices){
        unowned TweetNode parent_node=(TweetNode)this.get_parent();
        _signal_pipe.media_url_click_event(new MediaPage(_media_array,parent_node.copy()));
        break;
      }
    }
    //urls_arrayから検索
    for(int i=0;i<_urls_array.length;i++){
      if(index_>=_urls_array[i].start_indices&&index_<_urls_array[i].end_indices){
        open_url(_urls_array[i].expanded_url);
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
    context_set_source_rgba(context,_config.font_profile.text_font_rgba);
    
    layout=Pango.cairo_create_layout(context);
    //font_descriptionの設定
    layout.set_font_description(_config.font_profile.text_font_desc);
    layout.set_markup(parsed_text,-1);
    layout.set_width((int)w*Pango.SCALE);
    context.move_to(0,0);
    Pango.cairo_show_layout(context,layout);
    layout.get_pixel_size(null,out h);
    this.set_size_request(-1,h);
    
    return true;
  }
  
  public TextDrawingBox(string text,media[] media_array,urls[] urls_array,Config config,SignalPipe signal_pipe){
    _config=config;
    _signal_pipe=signal_pipe;
    
    _media_array=media_array;
    _urls_array=urls_array;
        
    text_=text;
    //縦に広がるようにする
    this.vexpand=true;
    
    //textの整形
    parsed_text=parse_text(ref text_,_media_array,_urls_array);
    get_incides(text_,_media_array,_urls_array);
  }
  
  private void open_media_page(){
    
  }
}
