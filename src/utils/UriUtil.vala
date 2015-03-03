using TwitterUtil;

namespace URIUtil{
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
