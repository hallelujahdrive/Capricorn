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
  
  //アイコンの読み出し
  public void get_image(ImageParam image_param,Gtk.Image profile_image,string cache_dir,Sqlite.Database db){
    if(!image_param.image_path.has_suffix("cache")){
      image_param.has_image=true;
    }
    if(!image_param.has_image||image_param.always_get){
        image_param.image_path=GLib.Path.build_path(GLib.Path.DIR_SEPARATOR_S,cache_dir,image_param.file_name);
        var image=File.new_for_uri(image_param.profile_image_url);
        image.read_async.begin(Priority.DEFAULT,null,(obj,res)=>{
          try{
            var image_stream=image.read_async.end(res);
            var image_data_stream=new DataInputStream(image_stream);
            Pixbuf pixbuf=new Pixbuf.from_stream(image_data_stream,null);
            pixbuf.save(image_param.image_path,"png");
            //この辺Cairo
            Cairo.ImageSurface surface=new Cairo.ImageSurface(Cairo.Format.ARGB32,image_param.size,image_param.size);
            Cairo.Context context=new Cairo.Context(surface);
            context.arc(image_param.size/2,image_param.size/2,image_param.size/2,0,2*Math.PI);
            context.clip();
            context.new_path();
            context.scale(image_param.size/48.0,image_param.size/48.0);
            Cairo.ImageSurface img=new Cairo.ImageSurface.from_png(image_param.image_path);
            context.set_source_surface(img,0,0);
            context.paint();
            surface.write_to_png(image_param.image_path);
            //画像設定
            profile_image.set_from_file(image_param.image_path);
          }catch(Error e){
            print("Error:%s\n",e.message);
          }
        });
        if(!image_param.has_image&&image_param.save){
          SqliteOpr.insert_image_path(image_param.id,image_param.image_path,db);
        }
      }else{
        profile_image.set_from_file(image_param.image_path);
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
