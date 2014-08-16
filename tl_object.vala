using Cairo;
using Gdk;
using Gtk;
using Pango;
using Sqlite;


using ContentsObj;
using FileOpr;
using JsonOpr;
using UI;

namespace TLObject{
  //TLScrolled
  class TLScrolledObj:TLScrolledUI{
    //コンストラクタ
    private TweetObj[] tweet_obj_array;
    private int array_val;
    //インスタンス
    //TweetObjの初期配置
    public TLScrolledObj(int get_tweet_max){
      array_val=get_tweet_max;
      tweet_obj_array=new TweetObj[get_tweet_max];
    }
    public void add_tweet_obj(TweetObj tweet_obj,int get_tweet_max,bool always_get){
      if(!always_get){
        //オブジェクト削除
        if(tweet_obj_array[array_val]!=null){
          tweet_obj_array[array_val].destroy();
        }
        //prepend
        tweet_obj_array[array_val]=tweet_obj;
        this.lbox.prepend(tweet_obj_array[array_val]);
        
        (array_val+1)>=get_tweet_max ? array_val=0:array_val++;
      }else{
        //append
        array_val--;
        tweet_obj_array[array_val]=tweet_obj;
        this.lbox.add(tweet_obj_array[array_val]);
      }     
      //表示
      this.lbox.show_all();
    }
  }
    
  //TweetObj
  class TweetObj:TweetObjUI{
    //コンストラクタ
      public TweetObj(ParseJson parse_json,Pango.FontDescription font_desk){
      //profile_image_areaの描画
      profile_image.set_size_request(48,48);
      
      //nameの描画
      name_area.draw.connect((context)=>{
        //boxのサイズ
        int w=name_box.get_allocated_width();
        int h;
        
        Pango.Layout name_layout=Pango.cairo_create_layout(context);
        name_layout.set_font_description(font_desk);
        name_layout.set_markup("<b>@"+parse_json.screen_name+"</b> "+parse_json.name,-1);
        name_layout.set_width((int)w*Pango.SCALE);
        context.move_to(0,0);        
        Pango.cairo_show_layout(context,name_layout);
        name_layout.get_pixel_size(null,out h);
        name_box.set_size_request(-1,h);
        
        return true;
      });
      
      //textの描画
      text_area.draw.connect((context)=>{
        //boxのサイズ
        int w=text_box.get_allocated_width();
        int h;
        
        Pango.Layout text_layout=Pango.cairo_create_layout(context);
        text_layout.set_font_description(font_desk);
        text_layout.set_markup(parse_json.text,-1);
        text_layout.set_width((int)w*Pango.SCALE);
        context.move_to(0,0);
        Pango.cairo_show_layout(context,text_layout);
        text_layout.get_pixel_size(null,out h);
        text_box.set_size_request(-1,h);
        
        return true;
      });
      
      //created_atの描画
      created_at_area.set_size_request(-1,1);
      created_at_area.draw.connect((context)=>{
        //boxのサイズ
        int w=text_box.get_allocated_width();
        int h;
        Pango.Layout created_at_layout=Pango.cairo_create_layout(context);
        created_at_layout.set_font_description(font_desk);
        created_at_layout.set_markup(parse_json.created_at,-1);
        created_at_layout.set_width((int)w*Pango.SCALE);
        context.move_to(0,0);
        Pango.cairo_show_layout(context,created_at_layout);
        created_at_layout.get_pixel_size(null,out h);
        created_at_box.set_size_request(-1,h);
        return true;
      });
      
      //source_areaの描画
      this.source_area.set_size_request(-1,1);
      this.source_area.draw.connect((context)=>{
        //boxのサイズ
        int w=text_box.get_allocated_width();
        int h;
        Pango.Layout source_layout=Pango.cairo_create_layout(context);
        source_layout.set_font_description(font_desk);
        source_layout.set_markup(parse_json.source_label,-1);
        source_layout.set_width((int)w*Pango.SCALE);
        context.move_to(0,0);
        Pango.cairo_show_layout(context,source_layout);
        source_layout.get_pixel_size(null,out h);
        source_ebox.set_size_request(-1,h);
       
        return true;
      });
      
      //RTの時、専用のDrawingAreaを追加
      if(parse_json.retweet){
        //プロパティ
        rt_box.set_hexpand(true);
        rt_profile_image.set_size_request(24,24);
        
        //レイアウト
        rt_box.pack_start(rt_mess_area,false,false,0);
        rt_box.pack_start(rt_profile_image,false,false,0);
        rt_box.pack_start(rt_name_area);
        tweet_obj_grid.attach(rt_box,1,2,1,1);
        
        //rt_mess_areaの描画
        rt_mess_area.draw.connect((context)=>{
          int w,h;
          Pango.Layout rt_mess_layout=Pango.cairo_create_layout(context);
          rt_mess_layout.set_font_description(font_desk);
          rt_mess_layout.set_markup("RT by",-1);
          context.move_to(0,0);
          Pango.cairo_show_layout(context,rt_mess_layout);
          rt_mess_layout.get_pixel_size(out w,out h);
          rt_mess_area.set_size_request(w,h);
          
          return true;
        });
        
        //rt_name_areaの描画
        rt_name_area.draw.connect((context)=>{
          int w,h;
          Pango.Layout rt_name_layout=Pango.cairo_create_layout(context);
          rt_name_layout.set_font_description(font_desk);
          rt_name_layout.set_markup("@"+parse_json.screen_name,-1);
          rt_name_layout.set_width(-1);
          context.move_to(0,0);
          Pango.cairo_show_layout(context,rt_name_layout);
          rt_name_layout.get_pixel_size(out w,out h);
          rt_name_area.set_size_request(w,h);

          return true;
        });

      }
    }
  }
}
