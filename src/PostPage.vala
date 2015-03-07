using Gdk;
using Gtk;

using ImageUtil;
using StringUtil;
using TwitterUtil;

[GtkTemplate(ui="/org/gtk/capricorn/ui/post_page.ui")]
class PostPage:Frame{
  private GLib.Array<Account> account_array_;
  private Config config_;
  private SignalPipe signal_pipe_;
  
  private IconButton post_button;
  private IconButton url_shorting_button;
  
  private TweetNode tweet_node_;
  
  //tweet_text_view内の文字数
  private static int chars_count=140;
  //リプライ元のtweet_id
  private string? to_reply_tweet_id_str;
  //replyのリセットをしない
  private bool freeze=false;

  //選択中のaccount
  private static int selected_account_num=0;
  
  //TLの変更を連動させるかどうか
  private bool tl_is_linked=false;
  
  //Widget
  [GtkChild]
  public Image tab;
  
  [GtkChild]
  private Label chars_count_label;
  
  [GtkChild]
  private TextView tweet_text_view;
  
  [GtkChild]
  private TextBuffer buffer;
  
  private CellRendererPixbuf cell_pixbuf=new CellRendererPixbuf();
  private CellRendererText cell_text=new CellRendererText();
  
  [GtkChild]
  private Box bbox;
  
  [GtkChild]
  private Box tweet_node_box;
  
  [GtkChild]
  private ComboBox account_cbox;
  
  [GtkChild]
  private CheckButton tl_link_cbutton;
  
  [GtkChild]
  private ListStore account_list_store;
  private TreeIter iter;
  
  //Callback
  //残り文字数のカウント
  [GtkCallback]
  private void buffer_changed_cb(TextBuffer buffer){
    chars_count=140-buffer.get_char_count();
    chars_count_label.set_text(chars_count.to_string());
    //post_buttonのプロパティ
    if(chars_count==140||chars_count<0){
      post_button.set_sensitive(false);
      if(chars_count==140){
        reply_reset();
      }
    }else{
      post_button.set_sensitive(true);
    }
  }
  
  //accountの選択
  [GtkCallback]
  private void account_cbox_changed_cb(ComboBox account_cbox){
    if(account_cbox.get_active_iter(out iter)){
      Value val;
      account_list_store.get_value(iter,0, out val);
      selected_account_num=(int)val;
    
      //TLの切り替えをAccountと連動させる
      if(tl_is_linked){
      tl_link(selected_account_num);
      }
    }
  }
  
  [GtkCallback]
  private void tl_link_cbutton_toggled_cb(){
    if(tl_link_cbutton.active){
      tl_is_linked=true;
    }else{
      tl_is_linked=false;
    }
  }
  
  public PostPage(GLib.Array<Account> account_array,Config config,SignalPipe signal_pipe){
    account_array_=account_array;
    config_=config;
    signal_pipe_=signal_pipe;
    
    post_button=new IconButton(POST_ICON,null,null,IconSize.LARGE_TOOLBAR);
    url_shorting_button=new IconButton(URL_SHORTING_ICON,null,null,IconSize.LARGE_TOOLBAR);
    
    bbox.add(post_button);
    bbox.add(url_shorting_button);
    
    //プロパティ
    post_button.set_sensitive(false);
    
    account_cbox.pack_start(cell_pixbuf,false);
    account_cbox.add_attribute(cell_pixbuf,"pixbuf",1);
    account_cbox.pack_start(cell_text,true);
    account_cbox.add_attribute(cell_text,"text",2);
    
    account_list_store.set_sort_column_id(0,SortType.ASCENDING);

    //load
    load_account_combobox();
    
    //signalhandler
    //post
    post_button.clicked.connect((already)=>{
      post_tweet.begin(buffer.text,to_reply_tweet_id_str,account_array_.index(selected_account_num).api_proxy,(obj,res)=>{
      if(post_tweet.end(res)){
        buffer.text="";
        reply_reset();
        }
      });
      to_reply_tweet_id_str=null;
      return true;
    });
    
    //URLの短縮
    url_shorting_button.clicked.connect((already)=>{
      if(buffer.text!=""){
        string parsed_text=parse_post_text(buffer.text);
        buffer.text=parsed_text;      
      }
      return true;
    });
    
    //リプライのリクエスト
    signal_pipe.reply_request_event.connect((tweet_node,id_str,screen_name)=>{
      reply_reset();
      freeze=true;
      to_reply_tweet_id_str=id_str;
      buffer.text=buffer.text+"@"+screen_name+" ";
      tweet_node_box.add(tweet_node);
      freeze=false;
      tweet_text_view.grab_focus();
    });
    
  }
  
  //account_comboboxの読み込み
  public void load_account_combobox(){
    account_list_store.clear();
    for(int i=0;i<account_array_.length;i++){
      //戻り値用のbool
      bool profile_image_loaded=false;
      //iter(ローカル)
      TreeIter iter;
      
      account_list_store.append(out iter);
      account_list_store.set(iter,0,account_array_.index(i).my_list_id,2,account_array_.index(i).my_screen_name);
      //load中の画像のRotateSurface
      try{
        RotateSurface rotate_surface=new RotateSurface(config_.icon_theme.load_icon(LOADING_ICON,16,IconLookupFlags.NO_SVG));
        rotate_surface.run();
        rotate_surface.update.connect((surface)=>{
          if(!profile_image_loaded&&account_list_store!=null){
            account_list_store.set(iter,1,pixbuf_get_from_surface(surface,0,0,16,16));
          }   
          return !profile_image_loaded;
        });
      }catch(Error e){
        print("IconTheme Error : %s\n",e.message);
      }
      get_pixbuf_async.begin(config_.cache_dir_path,account_array_.index(i).my_screen_name,account_array_.index(i).my_profile_image_url,16,config_.profile_image_hash_table,(obj,res)=>{
        //profile_imageの取得
        account_list_store.set(iter,1,get_pixbuf_async.end(res));
        profile_image_loaded=true;
      });
    }
    //デフォで0のアカウントを表示
    account_cbox.active=0;
  }
  
  //リプライのリセット
  private void reply_reset(){
    if(tweet_node_!=null&&!freeze){
      tweet_node_.destroy();
      to_reply_tweet_id_str=null;
    }
  }
  
  //tlとcomboboxの連動
  public signal void tl_link(int selected_account_num);
}
