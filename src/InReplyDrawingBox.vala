using Cairo;
using Gdk;
using Gtk;
using Rest;

using ImageUtil;
using TwitterUtil;

class InReplyDrawingBox:DrawingBox{
  private ParsedJsonObj in_replyparsed_json_obj;
  private Surface image_surface;
  
  //drawのcallback(override)
  protected override bool drawing_area_draw_cb(Context context){
    base.drawing_area_draw_cb(context);
    
    width=this.get_allocated_width();
    
    layout=Pango.cairo_create_layout(context);
    //fontの設定
    set_font(context);
    //textの描画
    layout.set_markup(in_replyparsed_json_obj.text,-1);
    //横幅の設定(引かないとズレる)
    layout.set_width((int)(width-29)*Pango.SCALE);
    //描画位置の調整(pixbuf(24px)+spacer(5px)=29px)
    context.move_to(29,0);
    Pango.cairo_show_layout(context,layout);
    layout.get_pixel_size(null,out height);
    
    if(image_surface!=null){
      context.set_source_surface(image_surface,0,0);
    }
    context.paint();
    
    //高さの設定
    height=height>24?height:24;
    this.set_size_request(-1,height);
    
    return true;
  }
  
  public InReplyDrawingBox(Config config,SignalPipe signal_pipe){
    base(config,signal_pipe);
  }
  
  //reply元のツイートを取得
  public bool draw_tweet(Account account,string in_reply_to_status_id){
    string json_str=statuses_show(account,in_reply_to_status_id);
    if(json_str!=null){
      in_replyparsed_json_obj=new ParsedJsonObj.from_string(json_str,null);
      
      //load中の画像のRotateSurface
      rotate_surface_run(24);
      //profile_image_pixbufの取得
      get_pixbuf_async.begin(config.cache_dir_path,in_replyparsed_json_obj.user.screen_name,in_replyparsed_json_obj.user.profile_image_url,24,config.profile_image_hash_table,(obj,res)=>{
        image_surface=cairo_surface_create_from_pixbuf(get_pixbuf_async.end(res),1,null);
        profile_image_loaded=true;
        //再描画
        drawing_area.queue_draw();
      });
      
      //シグナルハンドラ
      rotate_surface.update.connect((surface)=>{
        if(!profile_image_loaded){
          image_surface=surface;
        }
        //再描画
        drawing_area.queue_draw();    
        return !profile_image_loaded;
      });
      return true;
    }else{
      return false;
    }
  }
  
  //color,descriptionの設定
  private void set_font(Context context){
    if(config.font_profile.use_default){
      context_set_source_rgba(context,config.font_profile.text_font_rgba);
      layout.set_font_description(config.font_profile.text_font_desc);
    }else{
      context_set_source_rgba(context,config.font_profile.in_reply_font_rgba);
      layout.set_font_description(config.font_profile.in_reply_font_desc);
    }
  }
}
