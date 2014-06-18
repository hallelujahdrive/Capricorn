using Cairo;
using Gtk;
using Pango;
using Sqlite;

using JsonOpr;
using UI;

namespace TweetObject{
  //TweetObj
  class TweetObj:TweetObjUI{
    public TweetObj(ParseJson parse_json,Sqlite.Database db){
      //iconの描画
      //nameの描画
      this.name_area.draw.connect((context)=>{
        //boxのサイズ
        int w=this.name_ebox.get_allocated_width();
        int h;
        
        Pango.Layout name_layout=Pango.cairo_create_layout(context);
        name_layout.set_markup(parse_json.name,-1);
        
        name_layout.set_width((int)w*Pango.SCALE);
        name_layout.get_pixel_size(null,out h);
        name_ebox.set_size_request(-1,h);
        
        return true;
      });
    }
  }
}
