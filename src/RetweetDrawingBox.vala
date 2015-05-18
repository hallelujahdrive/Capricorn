using Cairo;
using Gdk;
using Gtk;
using Ruribitaki;

using ImageUtil;

class RetweetDrawingBox:DrawingBox{ 
  private const string retweet_text="Retweeted by";
  private string text;
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
    //retweet_text(Retweeted by)の描画
    layout.set_markup(retweet_text,-1);
    layout.set_width((int)width*Pango.SCALE);
    context.move_to(0,0);
    Pango.cairo_show_layout(context,layout);
    layout.get_pixel_size(out icon_pos,null);
    
    //textの描画
    layout.set_markup(text,-1);
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
  
  public RetweetDrawingBox(User rt_user,int64 retweet_count,Config config,SignalPipe signal_pipe){
    base(config,signal_pipe);
    
    text="@%s (%lld)".printf(rt_user.screen_name,retweet_count);
    
    //load中の画像のRotateSurface
    rotate_surface_run(16);
    //profile_image_pixbufの取得
    get_profile_image_async.begin(rt_user.screen_name,rt_user.profile_image_url,16,config,(obj,res)=>{
      image_surface=cairo_surface_create_from_pixbuf(get_profile_image_async.end(res),1,null);
      image_loaded=true;
      //再描画
      drawing_area.queue_draw();
    });
    
    //シグナルハンドラ
    rotate_surface.update.connect((surface)=>{
      if(!image_loaded){
        image_surface=surface;
      }
      //再描画
      drawing_area.queue_draw();    
      return !image_loaded;
    });
  }
  
  //color,descriptionの設定(footerの設定を使う)
  private void set_font(Context context){
    if(config.font_profile.use_default){
      context_set_source_rgba(context,config.font_profile.text_font_rgba);
      layout.set_font_description(config.font_profile.text_font_desc);
    }else{
      context_set_source_rgba(context,config.font_profile.footer_font_rgba);
      layout.set_font_description(config.font_profile.footer_font_desc);
    }
  }
}
