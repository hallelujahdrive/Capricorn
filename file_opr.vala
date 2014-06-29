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
