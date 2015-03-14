using Cairo;
using Gdk;
using Gtk;

using ImageUtil;
using TwitterUtil;

class EventDrawingBox:DrawingBox{
  //icon
  private Surface icon_surface;
  //ロード中のSurface;
  private Surface loading_surface;
  private Array<Surface?> image_surface_array=new Array<Surface?>();
  
  //描画するか否か
  private bool active=false;
  
  //アイコンの描画位置
  private int icon_pos;
  
  public override bool drawing_area_draw_cb(Context context){
    base.drawing_area_draw_cb(context);
    if(active){
      width=this.get_allocated_width();
      
      //iconの描画
      if(icon_surface!=null){
        context.set_source_surface(icon_surface,0,0);
        context.paint();
      }
      //描画位置の調整(16+spacer(10px)=26)
      icon_pos=26;
      
      //image_surfaceの描画
      for(int i=0;i<image_surface_array.length;i++){
        if(image_surface_array.index(i)!=null){
          context.set_source_surface(image_surface_array.index(i),icon_pos,0);
        }else{
          context.set_source_surface(loading_surface,icon_pos,0);
        }
        context.paint();
        icon_pos+=16;
      }
      
      //DrawingAreaの高さの設定
  
      this.set_size_request(-1,16);
    }
    return true;
  }
  
  public EventDrawingBox(ParsedJsonObj parsed_json_obj,Config config,SignalPipe signal_pipe){
    base(config,signal_pipe);
  }
  
  //RT
  public EventDrawingBox.retweet(ParsedJsonObj parsed_json_obj,Config config,SignalPipe signal_pipe){
    this(parsed_json_obj,config,signal_pipe);
    init(RETWEET_ON_ICON);
  }
  
  //☆
  public EventDrawingBox.favorite(ParsedJsonObj parsed_json_obj,Config config,SignalPipe signal_pipe){
    this(parsed_json_obj,config,signal_pipe);
    init(FAVORITE_ON_ICON);
  }
  
  //初期化
  private void init(string icon_name){
    //iconを取得
    try{
      Screen screen=Screen.get_default();
      icon_surface=config.icon_theme.load_surface(icon_name,16,1,screen.get_active_window(),IconLookupFlags.NO_SVG);
    }catch(Error e){
      print("IconTheme Error : %s\n",e.message);
    }
  }
  
  //追加
  public void add_user(User user){
    active=true;
    //rotate_surfaceの起動
    if(!profile_image_loaded){
      profile_image_loaded=false;
      rotate_surface_run(16);
    }
    //image_surface_arrayに追加(ダミー)
    image_surface_array.append_val((Surface)null);
    uint index=image_surface_array.length;
    //profile_image_pixbufの取得
    get_pixbuf_async.begin(config.cache_dir_path,user.screen_name,user.profile_image_url,16,config.profile_image_hash_table,(obj,res)=>{

      image_surface_array.insert_val(index-1,cairo_surface_create_from_pixbuf(get_pixbuf_async.end(res),1,null));
      image_surface_array.remove_index(index);
      profile_image_loaded=true;
      //再描画
      drawing_area.queue_draw();
    });
    //シグナルハンドラ
    rotate_surface.update.connect((surface)=>{
      if(!profile_image_loaded){
        loading_surface=surface;
      }
      //再描画
      drawing_area.queue_draw();    
      return !profile_image_loaded;
    });
  }
}
