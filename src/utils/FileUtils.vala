//using Soup;

namespace FileUtils{
  //文字列定数
  /*private static const string LOADING_ICON_PATH="icon/loading_icon.png";
  private static const string REPLY_ICON_PATH="icon/reply_icon.png";
  private static const string RT_ICON_PATH="icon/rt_icon.png";
  private static const string RT_ICON_F_PATH="icon/rt_icon_f.png";
  private static const string FAV_ICON_PATH="icon/fav_icon.png";
  private static const string FAV_ICON_F_PATH="icon/fav_icon_f.png";*/
  
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
  
  //アイコンの取得済みかどうか
  public bool is_image(string image_path){
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
}
