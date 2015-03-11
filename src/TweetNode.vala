using Cairo;
using Gdk;
using Gtk;
using Rest;

using TwitterUtil;
using URIUtil;

[GtkTemplate(ui="/org/gtk/capricorn/ui/tweet_node.ui")]
public class TweetNode:Grid{
  private ParsedJsonObj _parsed_json_obj;
  private unowned Account _account;
  private weak Config _config;
  private weak SignalPipe _signal_pipe;
    
  private HeaderDrawingBox header_d_box;
  private TextDrawingBox text_d_box;
  private FooterDrawingBox footer_d_box;
  
  private ProfileImageButton profile_image_button;
  private IconButton reply_button;
  private IconButton retweet_button;
  private IconButton favorite_button;
  
  public string id_str;
  public string screen_name;
  [GtkChild]
  private Box profile_image_box;
  
  [GtkChild]
  private Box action_box;
  
  public TweetNode(ParsedJsonObj parsed_json_obj,Account account,Config config,SignalPipe signal_pipe){
    _parsed_json_obj=parsed_json_obj;
    _account=account;
    _config=config;
    _signal_pipe=signal_pipe;
    
    id_str=_parsed_json_obj.id_str;
    screen_name=_parsed_json_obj.screen_name;
    
    header_d_box=new HeaderDrawingBox(_parsed_json_obj,_config,_signal_pipe);
    text_d_box=new TextDrawingBox(_parsed_json_obj,_config,_signal_pipe);
    footer_d_box=new FooterDrawingBox(_parsed_json_obj,_config,_signal_pipe);
    
    profile_image_button=new ProfileImageButton(_parsed_json_obj.screen_name,_parsed_json_obj.profile_image_url,_config,_signal_pipe);
    reply_button=new IconButton(REPLY_ICON,REPLY_HOVER_ICON,null,IconSize.BUTTON);
    retweet_button=new IconButton(RETWEET_ICON,RETWEET_HOVER_ICON,RETWEET_ON_ICON,IconSize.BUTTON);
    favorite_button=new IconButton(FAVORITE_ICON,FAVORITE_HOVER_ICON,FAVORITE_ON_ICON,IconSize.BUTTON);
    
    this.attach(header_d_box,1,0,1,1);
    this.attach(text_d_box,1,1,1,1);
    this.attach(footer_d_box,1,3,1,1);
    
    profile_image_box.pack_start(profile_image_button,false,false,0);
    
    action_box.pack_end(favorite_button,false,false,0);
    action_box.pack_end(retweet_button,false,false,0);
    action_box.pack_end(reply_button,false,false,0);
        
    //背景色の設定
    set_bg_color();
    
    //rt_d_boxの追加
    if(_parsed_json_obj.tweet_type==TweetType.RETWEET){
      var rt_d_box=new RetweetDrawingBox(_parsed_json_obj,_config,_signal_pipe);
      this.attach(rt_d_box,1,4,1,1);
    }
    
    //in_reply_d_boxの追加
    if(_parsed_json_obj.in_reply_to_status_id!=null){
      var in_reply_d_box=new InReplyDrawingBox(_config,_signal_pipe);
      if(in_reply_d_box.draw_tweet(_account.api_proxy,parsed_json_obj.in_reply_to_status_id)){
        this.attach(in_reply_d_box,1,5,1,1);
      }
    }
    
    //シグナルハンドラ
    //背景色設定のシグナル
    signal_pipe.color_change_event.connect(()=>{
      set_bg_color();
      this.queue_draw();
    });
    
    //delete
    signal_pipe.delete_tweet_node_event.connect((id_str)=>{
      if(id_str==_parsed_json_obj.id_str){
        _parsed_json_obj.type=ParsedJsonObjType.DELETE;
        set_bg_color();
        this.queue_draw();
      }
    });
    
    //reply
    reply_button.clicked.connect((already)=>{
      _signal_pipe.reply_request_event(this.copy(),_account.my_list_id);
      return true;
    });
    
    //retweet
    retweet_button.clicked.connect((already)=>{
      return retweet(_parsed_json_obj.id_str,_account.api_proxy);
    });
    
    //favorite
    favorite_button.clicked.connect((already)=>{
      return favorites_create(_parsed_json_obj.id_str,_account.api_proxy);
    });
  }
  
  //背景色の設定
  private void set_bg_color(){
    switch(_parsed_json_obj.type){
      case ParsedJsonObjType.DELETE:this.override_background_color(StateFlags.NORMAL,_config.delete_bg_rgba);
      break;
      default:
      switch(_parsed_json_obj.tweet_type){
        case TweetType.MINE:this.override_background_color(StateFlags.NORMAL,_config.mine_bg_rgba);
        break;
        case TweetType.RETWEET:this.override_background_color(StateFlags.NORMAL,_config.retweet_bg_rgba);
        break;
        case TweetType.REPLY:this.override_background_color(StateFlags.NORMAL,_config.reply_bg_rgba);
        break;
        default:this.override_background_color(StateFlags.NORMAL,_config.default_bg_rgba);
        break;
      }
      break;
    }
  }
  
  //コピー
  public TweetNode copy(){
    return new TweetNode(_parsed_json_obj,_account,_config,_signal_pipe);
  }
}
