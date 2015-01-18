using Cairo;
using Gdk;
using Gtk;
using Rest;

using ImageUtils;
using JsonUtils;
using TwitterUtils;

class InReplyDrawingBox:DrawingBox{
  private ParsedJsonObj in_reply_parsed_json_obj;
  private Pixbuf in_reply_profile_image_pixbuf;
  private Surface image_surface;
  
  //drawのcallback(override)
  protected override bool drawing_area_draw_cb(Context context){
    base.drawing_area_draw_cb(context);
    
    w=this.get_allocated_width();
    
    layout=Pango.cairo_create_layout(context);
    //fontの設定
    set_font(context);
    //textの描画
    layout.set_markup(in_reply_parsed_json_obj.text,-1);
    //横幅の設定(引かないとズレる)
    layout.set_width((int)(w-29)*Pango.SCALE);
    //描画位置の調整(pixbuf(24px)+spacer(5px)=29px)
    context.move_to(29,0);
    Pango.cairo_show_layout(context,layout);
    layout.get_pixel_size(null,out h);
    
    image_surface=cairo_surface_create_from_pixbuf(in_reply_profile_image_pixbuf,1,null);
    context.set_source_surface(image_surface,0,0);
    context.paint();
    
    //高さの設定
    h=h>24?h:24;
    this.set_size_request(-1,h);
    
    return true;
  }
  
  public InReplyDrawingBox(OAuthProxy api_proxy,string in_reply_to_status_id,Config config,SignalPipe signal_pipe){
    config_=config;
    signal_pipe_=signal_pipe;
    
    //reply元の
    string json_str=get_tweet_json(api_proxy,in_reply_to_status_id);
    if(json_str!=null){
      in_reply_parsed_json_obj=new ParsedJsonObj(json_str,null);
      
      //profile_image_pixbufの取得
      in_reply_profile_image_pixbuf=config_.loading_pixbuf_24px;
      get_pixbuf_async.begin(config.cache_dir_path,in_reply_parsed_json_obj.screen_name,in_reply_parsed_json_obj.profile_image_url,24,config.profile_image_hash_table,(obj,res)=>{
        in_reply_profile_image_pixbuf=get_pixbuf_async.end(res);
        //再描画
        drawing_area.queue_draw();
      });
    }
  }
  
  //color,descriptionの設定
  private void set_font(Context context){
    if(config_.font_profile.use_default){
      context_set_source_rgba(context,config_.font_profile.text_font_rgba);
      layout.set_font_description(config_.font_profile.text_font_desc);
    }else{
      context_set_source_rgba(context,config_.font_profile.in_reply_font_rgba);
      layout.set_font_description(config_.font_profile.in_reply_font_desc);
    }
  }
}
