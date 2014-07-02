using Rest;

using Twitter;

namespace ContentsObj{
  public class Account:GLib.Object{
    //コンストラクタ
    public int my_list_id{get;set;}
    public int my_id{get;set;}
    public string my_screen_name{get;set;}
    public string my_profile_image_url{get;set;}
    public OAuthProxy api_proxy=new OAuthProxy(CONSUMER_KEY,CONSUMER_SECRET,API_URL,false);
    public OAuthProxy stream_proxy=new OAuthProxy(CONSUMER_KEY,CONSUMER_SECRET,STREAM_URL,false);
  }
  
  //Gtk.Imageに画像乗っけるときに面倒だし
  public class ImageParam:GLib.Object{
    //コンストラクタ
    public string file_name{get;set;}
    public int id{get;set;}
    public string profile_image_url{get;set;}
    public string image_path{get;set;}
    public int size{get;set;}
    public bool always_get{get;set;}
    public bool has_image=false;
    public bool never_save;
    
    public ImageParam(string set_file_name,int set_id,string set_profile_image_url,string set_image_path,int set_size,bool set_always_get,bool set_never_save){
      //set
      this.file_name=set_file_name;
      this.id=set_id;
      this.profile_image_url=set_profile_image_url;
      this.image_path=set_image_path;
      this.size=set_size;
      this.always_get=set_always_get;
      this.never_save=set_never_save;
    }
  }
}
