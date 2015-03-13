using Gdk;
using Pango;

[Compact]
public class FontProfile{
  //FontDescription
  public FontDescription name_font_desc=new FontDescription();
  public FontDescription text_font_desc=new FontDescription();
  public FontDescription footer_font_desc=new FontDescription();
  public FontDescription in_reply_font_desc=new FontDescription();
  
  public RGBA name_font_rgba=RGBA();
  public RGBA text_font_rgba=RGBA();
  public RGBA footer_font_rgba=RGBA();
  public RGBA in_reply_font_rgba=RGBA();
  
  public bool use_default;
  
  public void init(){
    name_font_desc=FontDescription.from_string("DejaVu Sans Semi-Condensed 10");
    text_font_desc=FontDescription.from_string("DejaVu Sans Semi-Condensed 10");
    footer_font_desc=FontDescription.from_string("DejaVu Sans Semi-Condensed 10");
    in_reply_font_desc=FontDescription.from_string("DejaVu Sans Semi-Condensed 10");
    
    name_font_rgba.parse("rgb(40,40,40)");
    text_font_rgba.parse("rgb(40,40,40)");
    footer_font_rgba.parse("rgb(40,40,40)");
    in_reply_font_rgba.parse("rgb(40,40,40)");
    
    use_default=true;
  }
}
