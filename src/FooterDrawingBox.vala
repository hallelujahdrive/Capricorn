using Cairo;
using Gdk;
using Gtk;

class FooterDrawingBox:DrawingBox{
  private DateTime created_at_local;
  private StringBuilder source_sb=new StringBuilder();
  
  private string source_url_;
  
  private int created_at_w;
  private int source_w;
  
  //drawのcallback(override)    
  public override bool drawing_area_draw_cb(Context context){
    base.drawing_area_draw_cb(context);
    
    w=this.get_allocated_width();
    layout=Pango.cairo_create_layout(context);
    //fontの設定
    set_font(context);
    //タイムスタンプの描画
    layout.set_markup(created_at_local.format(config_.datetime_format),-1);
    layout.set_width((int)w*Pango.SCALE);
    context.move_to(0,0);
    Pango.cairo_show_layout(context,layout);
    layout.get_pixel_size(out created_at_w,out h);
    
    //sourceの描画
    layout.set_markup(source_sb.str,-1);
    //右寄せ
    layout.set_alignment(Pango.Alignment.RIGHT);
    layout.set_width((int)w*Pango.SCALE);
    layout.get_pixel_size(out source_w,null);
    //coreated_atとsourceが被った場合に、2行に分けて表示
    if(w<created_at_w+source_w){
      context.move_to(0,h);
      h*=2;
    }
    Pango.cairo_show_layout(context,layout);
    this.set_size_request(-1,h);

    return true;
  }
  
  public FooterDrawingBox(DateTime created_at,string source_label,string source_url,Config config,SignalPipe signal_pipe){
    config_=config;
    signal_pipe_=signal_pipe;
    
    source_url_=source_url;
    
    source_sb.append("via ");
    source_sb.append(source_label);
    
    created_at_local=created_at.to_local();
  }
  
  //color,descriptionの設定
  private void set_font(Context context){
    if(config_.font_profile.use_default){
      context_set_source_rgba(context,config_.font_profile.text_font_rgba);
      layout.set_font_description(config_.font_profile.text_font_desc);
    }else{
      context_set_source_rgba(context,config_.font_profile.name_font_rgba);
      layout.set_font_description(config_.font_profile.footer_font_desc);
    }
  }
}
