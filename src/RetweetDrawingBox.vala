using Cairo;
using Gdk;
using Gtk;

using ImageUtil;
using TwitterUtil;

class RetweetDrawingBox:DrawingBox{
  private weak ParsedJsonObj _parsed_json_obj;
  
  private const string retweet_text="Retweeted by";
  private StringBuilder rt_screen_name_sb=new StringBuilder();
  private Surface image_surface;
  
  private bool profile_image_loaded=false;
  //アイコンの描画位置
  private int icon_pos;
  
  //drawのcallback(override)
  public override bool drawing_area_draw_cb(Context context){
    base.drawing_area_draw_cb(context);
    
    width=this.get_allocated_width();
       
    layout=Pango.cairo_create_layout(context);
    //fontの設定
    set_font(context);
    //retweet_text(Retweeted by)の描画
    layout.set_markup(retweet_text,-1);
    layout.set_width((int)width*Pango.SCALE);
    context.move_to(0,0);
    Pango.cairo_show_layout(context,layout);
    layout.get_pixel_size(out icon_pos,null);
    
    //rt_screen_nameの描画
    layout.set_markup(rt_screen_name_sb.str,-1);
    //描画位置の調整(spacer(5px)+pixuf(16px)+spacer(5px)=26px)
    context.move_to(icon_pos+26,0);
    Pango.cairo_show_layout(context,layout);
    
    //rt_profile_image_pixbufの描画
    //描画位置の調整(spacer(5px))
    if(image_surface!=null){
      context.set_source_surface(image_surface,icon_pos+5,0);
    }
    context.paint();
    
    //DrawingAreaの高さの設定
    layout.get_pixel_size(null,out height);
    height=height>16?height:16;

    this.set_size_request(-1,height);
    return true;
  }
  
  public RetweetDrawingBox(ParsedJsonObj parsed_json_obj,Config config,SignalPipe signal_pipe){
    base(config,signal_pipe);
    
    _parsed_json_obj=parsed_json_obj;
    
    rt_screen_name_sb.append("@");
    rt_screen_name_sb.append(_parsed_json_obj.rt_screen_name);
    
    //profile_image_pixbufの取得
    try{
      //load中の画像のRotateSurface
      RotateSurface rotate_surface=new RotateSurface(_config.icon_theme.load_icon(LOADING_ICON,16,IconLookupFlags.NO_SVG));
      rotate_surface.update.connect((surface)=>{
        if(!profile_image_loaded){
          image_surface=surface;
        }
        //再描画
        drawing_area.queue_draw();    
        return !profile_image_loaded;
      });
    }catch(Error e){
      print("IconTheme Error : %s\n",e.message);
    }
    get_pixbuf_async.begin(_config.cache_dir_path,_parsed_json_obj.rt_screen_name,_parsed_json_obj.rt_profile_image_url,16,_config.profile_image_hash_table,(obj,res)=>{
      image_surface=cairo_surface_create_from_pixbuf(get_pixbuf_async.end(res),1,null);
      profile_image_loaded=true;
      //再描画
      drawing_area.queue_draw();
    });
  }
  
  //color,descriptionの設定(footerの設定を使う)
  private void set_font(Context context){
    if(_config.font_profile.use_default){
      context_set_source_rgba(context,_config.font_profile.text_font_rgba);
      layout.set_font_description(_config.font_profile.text_font_desc);
    }else{
      context_set_source_rgba(context,_config.font_profile.footer_font_rgba);
      layout.set_font_description(_config.font_profile.footer_font_desc);
    }
  }
}
