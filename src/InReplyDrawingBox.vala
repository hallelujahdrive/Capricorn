using Cairo;
using Gdk;
using Gtk;
using Rest;
using Ruribitaki;

using ImageUtil;

class InReplyDrawingBox:DrawingBox{
  private Ruribitaki.Status in_reply_status;
  private Surface image_surface;
  
  //drawのcallback(override)
  protected override bool drawing_area_draw_cb(Context context){
    base.drawing_area_draw_cb(context);
    
    width=this.get_allocated_width();
    
    layout=Pango.cairo_create_layout(context);
    //fontの設定
    set_font(context);
    //textの描画
    layout.set_markup(in_reply_status.text,-1);
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
  public async bool draw_tweet(Account account,string in_reply_to_status_id_str){
    bool result=false;
    statuses_show.begin(account,in_reply_to_status_id_str,(obj,res)=>{
      try{
        if((in_reply_status=statuses_show.end(res))!=null){
          result=true;
          //load中の画像のRotateSurface
          rotate_surface_run(24);
          //profile_image_pixbufの取得
          get_profile_image_async.begin(in_reply_status.user.screen_name,in_reply_status.user.profile_image_url,24,config,(obj,res)=>{
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
      }catch(Error e){
        print("Show error : %s\n",e.message);
      }
      draw_tweet.callback();
    });
    yield;
    return result;
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
