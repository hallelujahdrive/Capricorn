using Cairo;
using Gtk;
using Pango;
using Sqlite;

using JsonOpr;
using UI;

namespace TLObject{
  //TLScrolled
  class TLScrolledObj:TLScrolledUI{
    //コンストラクタ
    private GLib.Array<TweetObj> tweet_obj_array=new GLib.Array<TweetObj>();
    //インスタンス
    //TweetObjの初期配置
    public void add_tweet_obj(string[] json_str_array,string my_screen_name,int[] time_deff,Pango.FontDescription font_desk,Sqlite.Database db){
      foreach(string json_str in json_str_array){
        ParseJson parse_json=new ParseJson(json_str,my_screen_name,time_deff,db);
        if(parse_json.obj_not_null){
          TweetObj tweet_obj=new TweetObj(parse_json,font_desk,db);
          tweet_obj_array.append_val(tweet_obj);
          this.lbox.add(tweet_obj_array.index(tweet_obj_array.length-1));
        }
      }
      //表示
      this.lbox.show_all();
    }
  }
  
  //TweetObj
  class TweetObj:TweetObjUI{
    //コンストラクタ
    public TweetObj(ParseJson parse_json,Pango.FontDescription font_desk,Sqlite.Database db){
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
    }
  }
}
