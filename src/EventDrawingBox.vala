using Cairo;
using Gdk;
using Gtk;
using Ruribitaki;

using ImageUtil;

class EventDrawingBox:DrawingBox{
  //icon
  private Surface icon_surface;
  //ロード中のSurface
  private Surface loading_surface;
  private HashTable<string,Surface?> user_hash_table=new HashTable<string,Surface?>(str_hash,str_equal);
  
  //描画するか否か
  public bool active=false;
  
  //アイコンの描画位置
  private int icon_pos;
  //カウント
  private string text;
  
  public override bool drawing_area_draw_cb(Context context){
    base.drawing_area_draw_cb(context);
    if(active){
      width=this.get_allocated_width();
      
      layout=Pango.cairo_create_layout(context);

      //fontの設定
      set_font(context);
      
      //textの描画
      layout.set_markup(text,-1);
      layout.set_width((int)width*Pango.SCALE);
      //offset
      context.move_to(20,0);
      Pango.cairo_show_layout(context,layout);
      layout.get_pixel_size(out icon_pos,null);
      
      //iconの描画
      if(icon_surface!=null){
        context.set_source_surface(icon_surface,0,0);
        context.paint();
      }
      
      //描画位置の調整(offset+spacer=10)
      icon_pos=icon_pos+30;
      
      //image_surfaceの描画
      user_hash_table.for_each((hash_key,hash_value)=>{
        if(hash_value!=null){
          context.set_source_surface(hash_value,icon_pos,0);
        }else{
          context.set_source_surface(loading_surface,icon_pos,0);
        }
        context.paint();
        icon_pos+=16;
      });
      
      //DrawingAreaの高さの設定
  
      this.set_size_request(-1,16);
    }
    return true;
  }
  
  public EventDrawingBox(Config config,SignalPipe signal_pipe){
    base(config,signal_pipe);
  }
  
  //RT
  public EventDrawingBox.retweet(Config config,SignalPipe signal_pipe){
    this(config,signal_pipe);
    init(RETWEET_ON_ICON);
  }
  
  //☆
  public EventDrawingBox.favorite(Config config,SignalPipe signal_pipe){
    this(config,signal_pipe);
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
  public void add_user(User user,int64 count){
    active=true;
    text=count.to_string();
    //rotate_surfaceの起動
    if(!profile_image_loaded){
      profile_image_loaded=false;
      rotate_surface_run(16);
    }
    //hash_tableに追加(ダミー)
    user_hash_table.insert(user.id_str,(Surface)null);
    //profile_image_pixbufの取得
    get_profile_image_async.begin(user.screen_name,user.profile_image_url,16,config,(obj,res)=>{

      user_hash_table.replace(user.id_str,cairo_surface_create_from_pixbuf(get_profile_image_async.end(res),1,null));
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
  
  //userの削除
  public void remove_user(User user){
    if(user_hash_table.remove(user.id_str)){
      if(user_hash_table.length==0){
        active=false;
      }
      //再描画
      drawing_area.queue_draw();
    }
   } 
  
  //color,descriptionの設定
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
