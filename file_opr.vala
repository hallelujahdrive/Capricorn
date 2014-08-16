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
  
  //imageの読み出し
  public void set_image_for_image(string file_name,int id,string profile_image_url,string? image_path,
                           int size,bool always_get,bool never_save,
                           Gtk.Image? profile_image,string cache_dir,Sqlite.Database db){
    bool has_image=false;
    GLib.Cancellable cancellable=new GLib.Cancellable();
    //image_pathが正常に取得できていればそのまま設定できる
    if(image_path!=null){
      has_image=true;
    }
    //gifは現状除外
    if(!profile_image_url.has_suffix("gif")){
    //もしアイコンを持っていなければ取得
    if(!has_image||always_get){
      //image_pathの設定
      string new_image_path=GLib.Path.build_path(GLib.Path.DIR_SEPARATOR_S,cache_dir,file_name);
      var image=File.new_for_uri(profile_image_url);
      image.read_async.begin(Priority.DEFAULT,cancellable,(obj,res)=>{
        try{
          //streamからのpixbuf
          var input_stream=image.read_async.end(res);
          Pixbuf pixbuf=new Pixbuf.from_stream(input_stream,null);
          
          //imageに設定
          Pixbuf scaled_pixbuf=pixbuf.scale_simple(size,size,Gdk.InterpType.BILINEAR);
          profile_image.set_from_pixbuf(scaled_pixbuf);
          
          input_stream.close();
          
          //書き出し
          if(!never_save){
            var output_image=File.new_for_path(new_image_path);
            var output_stream=output_image.create(GLib.FileCreateFlags.REPLACE_DESTINATION,null);
            pixbuf.save_to_stream(output_stream,"png",cancellable);
            output_stream.close();
          }
          
        }catch(Error e){
          print("Error:%s\n%s\n",e.message,file_name);

        }
      });
      //insertされていなければ書き出す
      if(!has_image&&!never_save){
        SqliteOpr.insert_image_path(id,new_image_path,db);
      }
    }else{
      try{
        //既に取得済みであれば問題なし
        var image=File.new_for_path(image_path);
        var image_stream=image.read();
        Pixbuf pixbuf=new Pixbuf.from_stream_at_scale(image_stream,size,size,true,null);
        profile_image.set_from_pixbuf(pixbuf);
        image_stream.close();
      }catch(Error e){
        print("%s\n",e.message);
      }
    }
    }
        
            
    //シグナルの処理
    cancellable.cancelled.connect(()=>{
      print("Cancelled\n");
    });
  }
  
  public void set_image_for_liststore(string file_name,int id,string profile_image_url,string? image_path,
                           bool always_get,
                           Gtk.ListStore? account_list_store,Gtk.TreeIter? iter,
                           string cache_dir,Sqlite.Database db){
    bool has_image=false;
    GLib.Cancellable cancellable=new GLib.Cancellable();
    //image_pathが正常に取得できていればそのまま設定できる
    if(image_path!=null){
      has_image=true;
    }
    //gifは現状除外
    if(!profile_image_url.has_suffix("gif")){
    //もしアイコンを持っていなければ取得
    if(!has_image||always_get){
      var image=File.new_for_uri(profile_image_url);
      image.read_async.begin(Priority.DEFAULT,cancellable,(obj,res)=>{
        try{
          //streamからのpixbuf
          var input_stream=image.read_async.end(res);
          Pixbuf pixbuf=new Pixbuf.from_stream(input_stream,null);
          input_stream.close();

          //imageに設定
          Pixbuf scaled_pixbuf=pixbuf.scale_simple(24,24,Gdk.InterpType.BILINEAR);
          account_list_store.set(iter,1,scaled_pixbuf);
          
        }catch(Error e){
          print("Error:%s\n%s\n",e.message,file_name);

        }
      });
    }else{
      try{
        //既に取得済みであれば問題なし
        var image=File.new_for_path(image_path);
        var image_stream=image.read();
        Pixbuf pixbuf=new Pixbuf.from_stream_at_scale(image_stream,24,24,true,null);
        image_stream.close();
        account_list_store.set(iter,1,pixbuf);
      }catch(Error e){
        print("%s\n",e.message);
      }
    }
    }
        
            
    //シグナルの処理
    cancellable.cancelled.connect(()=>{
      print("Cancelled\n");
    });
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
