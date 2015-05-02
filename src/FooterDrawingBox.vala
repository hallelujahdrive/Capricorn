using Cairo;
using Gdk;
using Gtk;
using Ruribitaki;

class FooterDrawingBox:DrawingBox{
  private weak ParsedJsonObj parsed_json_obj;
  private DateTime created_at_local;
  private StringBuilder source_sb=new StringBuilder();
    
  private int created_at_width;
  private int source_width;
  
  //drawのcallback(override)    
  public override bool drawing_area_draw_cb(Context context){
    base.drawing_area_draw_cb(context);
    
    width=this.get_allocated_width();
    layout=Pango.cairo_create_layout(context);
    //fontの設定
    set_font(context);
    //タイムスタンプの描画
    layout.set_markup(created_at_local.format(config.datetime_format),-1);
    layout.set_width((int)width*Pango.SCALE);
    context.move_to(0,0);
    Pango.cairo_show_layout(context,layout);
    layout.get_pixel_size(out created_at_width,out height);
    
    //sourceの描画
    layout.set_markup(source_sb.str,-1);
    //右寄せ
    layout.set_alignment(Pango.Alignment.RIGHT);
    layout.set_width((int)width*Pango.SCALE);
    layout.get_pixel_size(out source_width,null);
    //coreated_atとsourceが被った場合に、2行に分けて表示
    if(width<created_at_width+source_width){
      context.move_to(0,height);
      height*=2;
    }
    Pango.cairo_show_layout(context,layout);
    this.set_size_request(-1,height);

    return true;
  }
  
  public FooterDrawingBox(ParsedJsonObj parsed_json_obj,Config config,SignalPipe signal_pipe){
    base(config,signal_pipe);
    
    this.parsed_json_obj=parsed_json_obj;
    
    source_sb.append("via ");
    source_sb.append(parsed_json_obj.source_label);
    
    created_at_local=parsed_json_obj.created_at.to_local();
  }
  
  //color,descriptionの設定
  private void set_font(Context context){
    if(config.font_profile.use_default){
      context_set_source_rgba(context,config.font_profile.text_font_rgba);
      layout.set_font_description(config.font_profile.text_font_desc);
    }else{
      context_set_source_rgba(context,config.font_profile.name_font_rgba);
      layout.set_font_description(config.font_profile.footer_font_desc);
    }
  }
}
