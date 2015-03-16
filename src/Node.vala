using Cairo;
using Gdk;
using Gtk;
using Rest;

using TwitterUtil;
using URIUtil;

[GtkTemplate(ui="/org/gtk/capricorn/ui/node.ui")]
public class Node:Grid{
  //メンバ
  protected ParsedJsonObj parsed_json_obj;
  protected unowned Account account;
  protected weak Config config;
  protected weak SignalPipe signal_pipe;
  
  public string id_str;
  public string screen_name;
    
  //Widget
  private HeaderDrawingBox header_drawing_box;
  private TextDrawingBox text_drawing_box;
  private FooterDrawingBox footer_drawing_box;
  
  private ProfileImageButton profile_image_button;
  
  [GtkChild]
  protected Box profile_image_box;
  
  [GtkChild]
  protected Box action_box;
  
  public Node(ParsedJsonObj parsed_json_obj,Account account,Config config,SignalPipe signal_pipe){
    this.parsed_json_obj=parsed_json_obj;
    this.account=account;
    this.config=config;
    this.signal_pipe=signal_pipe;
    
    id_str=this.parsed_json_obj.id_str;
    screen_name=this.parsed_json_obj.user.screen_name;
    
    header_drawing_box=new HeaderDrawingBox(this.parsed_json_obj.user,this.config,this.signal_pipe);
    text_drawing_box=new TextDrawingBox(this.parsed_json_obj,this.config,this.signal_pipe);
    footer_drawing_box=new FooterDrawingBox(this.parsed_json_obj,this.config,this.signal_pipe);
    
    profile_image_button=new ProfileImageButton(this.parsed_json_obj.user,this.config,this.signal_pipe);
    
    this.attach(header_drawing_box,1,0,1,1);
    this.attach(text_drawing_box,1,1,1,1);
    this.attach(footer_drawing_box,1,3,1,1);
    
    profile_image_box.pack_start(profile_image_button,false,false,0);
        
    //背景色の設定
    set_bg_color();
    
    //シグナルハンドラ
    //背景色設定のシグナル
    this.signal_pipe.color_change_event.connect(()=>{
      set_bg_color();
      this.queue_draw();
    });
  }
  
  //背景色の設定
  protected void set_bg_color(){
    if(parsed_json_obj.is_mine){
      this.override_background_color(StateFlags.NORMAL,config.mine_bg_rgba);
    }else{
      switch(parsed_json_obj.type){
        case ParsedJsonObjType.DELETE:this.override_background_color(StateFlags.NORMAL,config.delete_bg_rgba);
        break;
        case ParsedJsonObjType.RETWEET:this.override_background_color(StateFlags.NORMAL,config.retweet_bg_rgba);
        break;
        default:
        switch(parsed_json_obj.tweet_type){
          case TweetType.REPLY:this.override_background_color(StateFlags.NORMAL,config.reply_bg_rgba);
          break;
          default:this.override_background_color(StateFlags.NORMAL,config.default_bg_rgba);
          break;
        }
        break;
      }
    }
  }
}
