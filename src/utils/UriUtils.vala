namespace UriUtils{
  //urlsの構造体
  public struct urls{
    public string display_url;
    public string expanded_url;
    public string url;
    public int start_indices;
    public int end_indices;
  }
  //mediaの構造体
  public struct media{
    public string display_url;
    public string expanded_url;
    public string media_url;
    public string media_url_https;
    public string url;
    public int start_indices;
    public int end_indices;
  }
  
  //urlを開く
  public bool open_url(string url){
    bool result=true;
    //urlのオープン
    try{
      Gtk.show_uri(null,url,Gtk.get_current_event_time());
    }catch(Error e){
      print("%s\n",e.message);
      result=false;
    }
    return result;
  }
}
