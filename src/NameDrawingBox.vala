using Cairo;
using Gdk;
using Gtk;

class NameDrawingBox:DrawingBox{
  private StringBuilder name_sb=new StringBuilder();
  
  //drawのcallback(override)
  public override bool drawing_area_draw_cb(Context context){
    base.drawing_area_draw_cb(context);
    
    w=this.get_allocated_width();
    layout=Pango.cairo_create_layout(context);
    //fontの設定
    set_font(context);
    layout.set_markup(name_sb.str,-1);
    layout.set_width((int)w*Pango.SCALE);
    context.move_to(0,0);
    Pango.cairo_show_layout(context,layout);
    layout.get_pixel_size(null,out h);
    h/=layout.get_line_count();
    layout.set_height(h);
    this.set_size_request(-1,h);
    return true;
  }
  
  public NameDrawingBox(string screen_name,string name,Config config,SignalPipe signal_pipe){
    config_=config;
    signal_pipe_=signal_pipe;
    
    //表示する文字列
    name_sb.append("<b>@");
    name_sb.append(screen_name);
    name_sb.append("</b> ");
    name_sb.append(name);
  }
  
  //color,descriptionの設定
  private void set_font(Context context){
    if(config_.font_profile.use_default){
      context_set_source_rgba(context,config_.font_profile.text_font_rgba);
      layout.set_font_description(config_.font_profile.text_font_desc);
    }else{
      context_set_source_rgba(context,config_.font_profile.name_font_rgba);
      layout.set_font_description(config_.font_profile.name_font_desc);
    }
  }
}
