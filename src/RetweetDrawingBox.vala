using Cairo;
using Gdk;
using Gtk;

using ImageUtils;

class RetweetDrawingBox:DrawingBox{
  private const string retweet_text="Retweeted by";
  
  private StringBuilder rt_screen_name_sb=new StringBuilder();
  private Pixbuf rt_profile_image_pixbuf;
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
    //retweet_text(Retweeted by)の描画
    layout.set_markup(retweet_text,-1);
    layout.set_width((int)w*Pango.SCALE);
    context.move_to(0,0);
    Pango.cairo_show_layout(context,layout);
    layout.get_pixel_size(out icon_pos,null);
    
    //rt_screen_nameの描画
    layout.set_markup(rt_screen_name_sb.str,-1);
    //描画位置の調整(spacer(5px)+pixuf(16px)+spacer(5px)=26px)
    context.move_to(icon_pos+26,0);
    Pango.cairo_show_layout(context,layout);
    
    //rt_profile_image_pixbufの描画
    image_surface=cairo_surface_create_from_pixbuf(rt_profile_image_pixbuf,1,null);
    //描画位置の調整(spacer(5px))
    context.set_source_surface(image_surface,icon_pos+5,0);
    context.paint();
    
    //DrawingAreaの高さの設定
    layout.get_pixel_size(null,out h);
    h=h>16?h:16;

    this.set_size_request(-1,h);
    return true;
  }
  
  public RetweetDrawingBox(string rt_screen_name,string rt_profile_image_url,Config config,SignalPipe signal_pipe){
    config_=config;
    signal_pipe_=signal_pipe;
    
    rt_screen_name_sb.append("@");
    rt_screen_name_sb.append(rt_screen_name);
    
    //rt_profile_imageの取得
    rt_profile_image_pixbuf=get_pixbuf_from_path(config_.loading_icon_path,16);
    string icon_path=GLib.Path.build_path(GLib.Path.DIR_SEPARATOR_S,config_.cache_dir_path,rt_screen_name+".png");
    get_pixbuf_async.begin(icon_path,rt_profile_image_url,16,(obj,res)=>{
      rt_profile_image_pixbuf=get_pixbuf_async.end(res);
      //再描画
      drawing_area.hide();
      drawing_area.show();
    });
  }
  
  //color,descriptionの設定(footerの設定を使う)
  private void set_font(Context context){
    if(config_.font_profile.use_default){
      context_set_source_rgba(context,config_.font_profile.text_font_rgba);
      layout.set_font_description(config_.font_profile.text_font_desc);
    }else{
      context_set_source_rgba(context,config_.font_profile.footer_font_rgba);
      layout.set_font_description(config_.font_profile.footer_font_desc);
    }
  }
}
