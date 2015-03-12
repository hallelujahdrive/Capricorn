using Cairo;
using Gdk;
using Gtk;

using ImageUtil;
using TwitterUtil;

class HeaderDrawingBox:DrawingBox{
  private unowned User _user;
  
  private StringBuilder name_sb=new StringBuilder();
  
  private Surface image_surface;
  
  //アイコンの描画位置
  private int icon_pos;
    
  //drawのcallback(override)
  public override bool drawing_area_draw_cb(Context context){
    base.drawing_area_draw_cb(context);
    
    width=this.get_allocated_width();
    layout=Pango.cairo_create_layout(context);
    //fontの設定
    set_font(context);
    layout.set_markup(name_sb.str,-1);
    layout.set_width((int)width*Pango.SCALE);
    context.move_to(0,0);
    Pango.cairo_show_layout(context,layout);
    layout.get_pixel_size(out icon_pos,out height);
    
    //protected_icon_pixbufの描画
    if(_user.account_is_protected){
      //描画位置の調整(spacer(5px))
      context.set_source_surface(image_surface,icon_pos+5,0);
      context.paint();
    }
    height/=layout.get_line_count();
    height=!_user.account_is_protected||height>16?height:16;
    layout.set_height(height);
    this.set_size_request(-1,height);
    return true;
  }
  
  public HeaderDrawingBox(User user,Config config,SignalPipe signal_pipe){
    base(config,signal_pipe);
    
    _user=user;
    
    //iconを取得
    if(_user.account_is_protected){
      try{
        Screen screen=Screen.get_default();
        image_surface=_config.icon_theme.load_surface(PROTECTED_ICON,16,1,screen.get_active_window(),IconLookupFlags.NO_SVG);
      }catch(Error e){
        print("IconTheme Error : %s\n",e.message);
      }
    }
    
    //表示する文字列
    name_sb.append("<b>@");
    name_sb.append(_user.screen_name);
    name_sb.append("</b> ");
    name_sb.append(_user.name);
  }
  
  //color,descriptionの設定
  private void set_font(Context context){
    if(_config.font_profile.use_default){
      context_set_source_rgba(context,_config.font_profile.text_font_rgba);
      layout.set_font_description(_config.font_profile.text_font_desc);
    }else{
      context_set_source_rgba(context,_config.font_profile.name_font_rgba);
      layout.set_font_description(_config.font_profile.name_font_desc);
    }
  }
}
