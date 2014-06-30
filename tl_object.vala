using Cairo;
using Gdk;
using Gtk;
using Pango;
using Sqlite;

using FileOpr;
using JsonOpr;
using UI;

namespace TLObject{
  //TLScrolled
  class TLScrolledObj:TLScrolledUI{
    //コンストラクタ
    public GLib.Array<TweetObj> tweet_obj_array=new GLib.Array<TweetObj>();
    //インスタンス
    //TweetObjの初期配置
    public void add_tweet_obj(TweetObj tweet_obj,int get_tweet_max,bool stream){
      if(stream){
        //オブジェクト削除
        if(tweet_obj_array.length==get_tweet_max){
          tweet_obj_array.index(get_tweet_max-1).destroy();
          tweet_obj_array.remove_index(get_tweet_max-1);
        }
        //prepend
        tweet_obj_array.prepend_val(tweet_obj);
        this.lbox.prepend(tweet_obj_array.index(0));
      }else{
        //append
        tweet_obj_array.append_val(tweet_obj);
        this.lbox.add(tweet_obj_array.index(tweet_obj_array.length-1));
      }
      //表示
      this.lbox.show_all();
    }
  }
  
  //Tweet
  class Tweet:GLib.Object{
    public TweetObj normal_tweet_obj;
    public TweetObj reply_obj;
    
    public Tweet(ParseJson parse_json,string cache_dir,bool stream,Pango.FontDescription font_desk,Sqlite.Database db){
      //画像あるかどうか
      bool has_image=false;
      string image_path=SqliteOpr.select_image_path(parse_json.id,cache_dir,db);
        if(!image_path.has_suffix("cache")){
        has_image=true;
      }
      //普通の
      //通常APIによる取得であれば,
      if(!stream){
        image_path=cache_dir;
      }
      normal_tweet_obj=new TweetObj(parse_json,image_path,has_image,font_desk,db);
      //リプライを作るかもしれない
      if(parse_json.reply){
        reply_obj=new TweetObj(parse_json,image_path,true,font_desk,db);
      }
    }
  }
    
  //TweetObj
  class TweetObj:TweetObjUI{
    //コンストラクタ
      public TweetObj(ParseJson parse_json,string image_path,bool has_image,Pango.FontDescription font_desk,Sqlite.Database db){
      //profile_image_areaの描画
      profile_image.set_size_request(48,48);
      //image_pathがcache_dirだったらimageの取得
      if(image_path.has_suffix("cache")){
        string new_image_path=GLib.Path.build_path(GLib.Path.DIR_SEPARATOR_S,image_path,parse_json.screen_name);
        var image=File.new_for_uri(parse_json.profile_image_url);
        image.read_async.begin(Priority.DEFAULT,null,(obj,res)=>{
          try{
            var image_stream=image.read_async.end(res);
            var image_data_stream=new DataInputStream(image_stream);
            Pixbuf pixbuf=new Pixbuf.from_stream(image_data_stream,null);
            pixbuf.save(new_image_path,"png");
            //この辺Cairo
            Cairo.ImageSurface surface=new Cairo.ImageSurface(Cairo.Format.ARGB32,48,48);
            Cairo.Context context=new Cairo.Context(surface);
            context.arc(24,24,24,0,2*Math.PI);
            context.clip();
            context.new_path();
            context.scale(1,1);
            Cairo.ImageSurface img=new Cairo.ImageSurface.from_png(new_image_path);
            context.set_source_surface(img,0,0);
            context.paint();
            surface.write_to_png(new_image_path);
            //読み込み
            profile_image.set_from_file(new_image_path);
          }catch(Error e){
            print("Error:%s\n",e.message);
          }
        });
        //まだインサートされてなければインサート
        if(!has_image){
          SqliteOpr.insert_image_path(parse_json.id,new_image_path,db);
        }
      }else{
        profile_image.set_from_file(image_path);
      }
      
      //nameの描画
      this.name_area.draw.connect((context)=>{
        //boxのサイズ
        int w=this.name_box.get_allocated_width();
        int h;
        
        Pango.Layout name_layout=Pango.cairo_create_layout(context);
        name_layout.set_font_description(font_desk);
        name_layout.set_markup(parse_json.name,-1);
        name_layout.set_width((int)w*Pango.SCALE);
        context.move_to(0,0);        
        Pango.cairo_show_layout(context,name_layout);
        name_layout.get_pixel_size(null,out h);
        this.name_box.set_size_request(-1,h);
        
        return true;
      });
      
      //textの描画
      this.text_area.draw.connect((context)=>{
        //boxのサイズ
        int w=this.text_box.get_allocated_width();
        int h;
        
        Pango.Layout text_layout=Pango.cairo_create_layout(context);
        text_layout.set_font_description(font_desk);
        text_layout.set_markup(parse_json.text,-1);
        text_layout.set_width((int)w*Pango.SCALE);
        context.move_to(0,0);
        Pango.cairo_show_layout(context,text_layout);
        text_layout.get_pixel_size(null,out h);
        this.text_box.set_size_request(-1,h);
        
        return true;
      });
      
      //created_atの描画
      this.created_at_area.set_size_request(-1,1);
      this.created_at_area.draw.connect((context)=>{
        //boxのサイズ
        int w=this.text_box.get_allocated_width();
        int h;
        Pango.Layout created_at_layout=Pango.cairo_create_layout(context);
        created_at_layout.set_font_description(font_desk);
        created_at_layout.set_markup(parse_json.created_at,-1);
        created_at_layout.set_width((int)w*Pango.SCALE);
        context.move_to(0,0);
        Pango.cairo_show_layout(context,created_at_layout);
        created_at_layout.get_pixel_size(null,out h);
        this.created_at_box.set_size_request(-1,h);
        return true;
      });
      
      //source_areaの描画
      this.source_area.set_size_request(-1,1);
      this.source_area.draw.connect((context)=>{
        //boxのサイズ
        int w=this.text_box.get_allocated_width();
        int h;
        Pango.Layout source_layout=Pango.cairo_create_layout(context);
        source_layout.set_font_description(font_desk);
        source_layout.set_markup(parse_json.source_label,-1);
        source_layout.set_width((int)w*Pango.SCALE);
        context.move_to(0,0);
        Pango.cairo_show_layout(context,source_layout);
        source_layout.get_pixel_size(null,out h);
        this.source_ebox.set_size_request(-1,h);
       
        return true;
      });
    }
  }
}
