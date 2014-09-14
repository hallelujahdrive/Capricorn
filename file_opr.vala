using Gdk;
using Soup;

using ContentsObj;
using JsonOpr;

namespace FileOpr{
  //文字列定数
  static const string LOADING_ICON_PATH="icon/loading_icon.png";
  static const string REPLY_ICON_PATH="icon/reply_icon.png";
  static const string RT_ICON_PATH="icon/rt_icon.png";
  static const string RT_ICON_F_PATH="icon/rt_icon_f.png";
  static const string FAV_ICON_PATH="icon/fav_icon.png";
  static const string FAV_ICON_F_PATH="icon/fav_icon_f.png";
  
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
  public void set_image_for_image(string image_path,string profile_image_url,int size,Gtk.Image profile_image){
    GLib.Cancellable cancellable=new GLib.Cancellable();
    //image_pathが正常に取得できていればそのまま設定できる
    bool has_image=image_test(image_path);
    //gifは現状除外
    if(!profile_image_url.has_suffix("gif")){
    //もしアイコンを持っていなければ取得
    if(!has_image){
      
      Soup.Session session=new Soup.Session();
      Soup.Message msg=new Soup.Message("GET",profile_image_url);
      session.queue_message(msg,(s,_msg)=>{
        try{
          var memory_stream=new MemoryInputStream.from_data(_msg.response_body.data,null);
          Pixbuf pixbuf=new Pixbuf.from_stream_at_scale(memory_stream,size,size,false);
          profile_image.set_from_pixbuf(pixbuf);
          memory_stream.close();
        //image_pathの設定(
      /*var image=File.new_for_uri(profile_image_url);
      image.read_async.begin(Priority.DEFAULT,cancellable,(obj,res)=>{
        try{
          //streamからのpixbuf
          var input_stream=image.read_async.end(res);
          var data_input_stream=new DataInputStream(input_stream);
          Pixbuf pixbuf=new Pixbuf.from_stream(data_input_stream,null);
          
          //imageに設定
          Pixbuf scaled_pixbuf=pixbuf.scale_simple(size,size,Gdk.InterpType.BILINEAR);
          profile_image.set_from_pixbuf(scaled_pixbuf);
          
          input_stream.close();
          data_input_stream.close();*/
          
          //書き出し
          /*if(!image_test(image_path)){
            var output_image=File.new_for_path(image_path);
            var output_stream=output_image.create(GLib.FileCreateFlags.REPLACE_DESTINATION,null);
            pixbuf.save_to_stream(output_stream,"png",cancellable);
            output_stream.close();
          }*/
          
        }catch(Error e){
          print("Error:%s\n%s\n",e.message,image_path);
        }
      });
    }else{
      //既に取得済みであれば問題なし
      Pixbuf pixbuf=get_pixbuf(image_path,size);
      profile_image.set_from_pixbuf(pixbuf);
    }
    }
            
    //シグナルの処理
    cancellable.cancelled.connect(()=>{
      print("Cancelled\n");
    });
  }
  
  public void set_image_for_liststore(string image_path,string profile_image_url,int size,Gtk.ListStore account_list_store,Gtk.TreeIter iter){
    GLib.Cancellable cancellable=new GLib.Cancellable();
    //image_pathが正常に取得できていればそのまま設定できる
    bool has_image=image_test(image_path);
    //gifは現状除外
    if(!profile_image_url.has_suffix("gif")){
    //もしアイコンを持っていなければ取得
    if(!has_image){
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
          print("Error:%s\n\n",e.message);

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
  
  //アイコンの取得済みかどうか
  public bool image_test(string image_path){
    if(GLib.FileUtils.test(image_path,FileTest.IS_REGULAR)){
      return true;
    }else{
      return false;
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
  
  public Pixbuf? get_pixbuf(string image_path,int size){
    Pixbuf pixbuf=null;
    try{
      //既に取得済みであれば問題なし
      var image=File.new_for_path(image_path);
      var image_stream=image.read();
      pixbuf=new Pixbuf.from_stream_at_scale(image_stream,size,size,true,null);
      image_stream.close();
    }catch(Error e){
      print("%s\n",e.message);
    }
    return pixbuf;
  }
}
