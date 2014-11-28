using Cairo;
using Gdk;
using Gtk;

using ImageUtils;

class HeaderDrawingBox:DrawingBox{
  private bool account_is_protected_;
  
  private StringBuilder name_sb=new StringBuilder();
  
  private Pixbuf protected_icon_pixbuf;
  private Surface image_surface;
  
  //アイコンの描画位置
  private int icon_pos;
    
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
    layout.get_pixel_size(out icon_pos,out h);
    
    //protected_icon_pixbufの描画
    if(account_is_protected_){
      image_surface=cairo_surface_create_from_pixbuf(protected_icon_pixbuf,1,null);
      //描画位置の調整(spacer(5px))
      context.set_source_surface(image_surface,icon_pos+5,0);
      context.paint();
    
    }
    h=!account_is_protected_||(h/=layout.get_line_count())>16?h:16;
    layout.set_height(h);
    this.set_size_request(-1,h);
    return true;
  }
  
  public HeaderDrawingBox(string screen_name,string name,bool account_is_protected,Config config,SignalPipe signal_pipe){
    account_is_protected_=account_is_protected;
    config_=config;
    signal_pipe_=signal_pipe;
    
    //表示する文字列
    name_sb.append("<b>@");
    name_sb.append(screen_name);
    name_sb.append("</b> ");
    name_sb.append(name);
    
    //protected_icon_pixbufの取得
    if(account_is_protected_){
      protected_icon_pixbuf=get_pixbuf_from_path(config_.protected_icon_path,16);
    }
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
