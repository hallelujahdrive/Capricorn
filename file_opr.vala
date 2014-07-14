using Gdk;

using ContentsObj;
using JsonOpr;

namespace FileOpr{
  //ディレクトリの作成
  public bool mk_cpr_dir(string cpr_dir_path,string cache_dir_path){
    if(!GLib.FileUtils.test(cpr_dir_path,FileTest.IS_DIR)){
      try{
        //$HOME.capricornの作成
        var cpr_dir=File.new_for_path(cpr_dir_path);
        cpr_dir.make_directory();
        //$HOME/.capricorn/cacheの作成
        var cache_dir=File.new_for_path(cache_dir_path);
        cache_dir.make_directory();
        return true;
      }catch(Error e){
        print("%s\n",e.message);
        return false;
      }
    }
    return false;
  }
  
  //profile_imageの読み出し
  public void get_image(string file_name,int id,string profile_image_url,string? image_path,
                           bool always_get,bool never_save,bool original_size,
                           Gtk.Image? profile_image,Gtk.ListStore? account_list_store,Gtk.TreeIter? iter,
                           string cache_dir,Sqlite.Database db){
    //画像のサイズ
    int size;
    if(original_size){
      size=48;
    }else{
      size=24;
    }
    bool has_image=false;
    GLib.Cancellable cancellable=new GLib.Cancellable();
    //image_pathが正常に取得できていればそのまま設定できる
    if(image_path!=null){
      has_image=true;
    }
    //もしアイコンを持っていなければ取得
    if(!has_image||always_get||!image_path.has_suffix("gif")){
      //image_pathの設定
      string new_image_path=GLib.Path.build_path(GLib.Path.DIR_SEPARATOR_S,cache_dir,file_name);
      var image=File.new_for_uri(profile_image_url);
      image.read_async.begin(Priority.DEFAULT,cancellable,(obj,res)=>{
        try{
          //streamからのpixbuf
          var image_stream=image.read_async.end(res);
          Pixbuf stream_pixbuf=new Pixbuf.from_stream(image_stream,null);
          stream_pixbuf.save(new_image_path,"png");
          image_stream.close();
          //この辺Cairo
          Cairo.ImageSurface surface=new Cairo.ImageSurface(Cairo.Format.ARGB32,size,size);
          Cairo.Context context=new Cairo.Context(surface);
          //現状丸だけどそのうち角の丸い四角に変える
          context.arc(size/2,size/2,size/2,0,2*Math.PI);
          context.clip();
          context.new_path();
          context.scale(size/48.0,size/48.0);
          Cairo.ImageSurface img=new Cairo.ImageSurface.from_png(new_image_path);
          context.set_source_surface(img,0,0);
          context.paint();
          surface.write_to_png(new_image_path);
          //imageに設定
          if(profile_image!=null){
            profile_image.set_from_file(new_image_path);
          }else{
            Pixbuf pixbuf=new Pixbuf.from_file(new_image_path);
            account_list_store.set(iter,1,pixbuf);
          }
        }catch(Error e){
          print("Error:%s\n%s\n",e.message,file_name);
        }
      });
      //insertされていなければ書き出す
      if(!has_image&&!never_save){
        if(original_size){
          SqliteOpr.insert_image_path(id,new_image_path,db);
        }else{
          SqliteOpr.insert_icon_path(id,new_image_path,db);
        }
      }
    }else{
      //既に取得済みであれば問題なし
      if(profile_image!=null){
        profile_image.set_from_file(image_path);
      }else{
        try{
          Pixbuf pixbuf=new Pixbuf.from_file(image_path);
          account_list_store.set(iter,1,pixbuf);
        }catch(Error e){
          print("%s\n",e.message);
        }
      }
        
            
      //シグナルの処理
      cancellable.cancelled.connect(()=>{
        print("Cancelled\n");
        });
    }
  }  
  //キャッシュの全削除
  public void clear_cache(string cache_dir_path){
    try{
      GLib.Dir cache_dir=GLib.Dir.open(cache_dir_path,0);
      string? cache_name=null;
      while((cache_name=cache_dir.read_name())!=null){
        string cache_path=GLib.Path.build_path(GLib.Path.DIR_SEPARATOR_S,cache_dir_path,cache_name);
        var cache_file=File.new_for_path(cache_path);
        cache_file.delete();
      }
    }catch(Error e){
      print("%s\n",e.message);
    }
  }
}
