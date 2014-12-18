using Gdk;
using Gtk;

using ImageUtils;
using StringUtils;
using TwitterUtils;

[GtkTemplate(ui="/org/gtk/capricorn/ui/post_page.ui")]
class PostPage:Frame{
  private GLib.Array<Account> account_array_;
  private Config config_;
  private SignalPipe signal_pipe_;
  
  //tab
  public Image post_tab=new Image();
  
  //tweet_text_view内の文字数
  private static int chars_count=140;
  //リプライ元のtweet_id
  private string? to_reply_tweet_id_str;

  //選択中のaccount
  private static int selected_account_num=0;
  
  //TLの変更を連動させるかどうか
  private bool tl_is_linked=false;
  
  //Widget
  [GtkChild]
  private Label chars_count_label;
  
  [GtkChild]
  private TextView tweet_text_view;
  
  [GtkChild]
  private TextBuffer buffer;
  
  [GtkChild]
  private Button post_button;
  
  private CellRendererPixbuf cell_pixbuf=new CellRendererPixbuf();
  private CellRendererText cell_text=new CellRendererText();
  
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
    }else{
      post_button.set_sensitive(true);
    }
  }
  
  //post
  [GtkCallback]
  private void post_button_clicked_cb(Button post_button){
    post_tweet.begin(buffer.text,to_reply_tweet_id_str,account_array_.index(selected_account_num).api_proxy,(obj,res)=>{
      bool result=post_tweet.end(res);
      if(result){
        buffer.text="";
      }
    });
    to_reply_tweet_id_str=null;
  }
  
  [GtkCallback]
  private void url_shorten_button_clicked_cb(Button url_shorten_button){
    if(buffer.text!=""){
      string parsed_text=parse_post_text(buffer.text);
      buffer.text=parsed_text;      
    }
  }
  
  //accountの選択
  [GtkCallback]
  private void account_cbox_changed_cb(ComboBox account_cbox){
    GLib.Value val;
    account_cbox.get_active_iter(out iter);
    account_list_store.get_value(iter,0, out val);
    selected_account_num=(int)val;
    
    //TLの切り替えをAccountと連動させる
    if(tl_is_linked){
      tl_link(selected_account_num);
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
    
    //プロパティ
    post_button.sensitive=false;
    
    account_cbox.pack_start(cell_pixbuf,false);
    account_cbox.add_attribute(cell_pixbuf,"pixbuf",1);
    account_cbox.pack_start(cell_text,true);
    account_cbox.add_attribute(cell_text,"text",2);
    
    account_list_store.set_sort_column_id(0,SortType.ASCENDING);
    
    post_tab.set_from_pixbuf(config_.post_icon_pixbuf);
    //load
    load_account_combobox();
    
    //signalhandler
    signal_pipe.reply_request_event.connect((tweet_id_str,screen_name)=>{
      to_reply_tweet_id_str=tweet_id_str;
      buffer.text="@"+screen_name+" ";
      tweet_text_view.grab_focus();
    });
  }
  
  //account_comboboxの読み込み
  public void load_account_combobox(){
    account_list_store.clear();
    for(int i=0;i<account_array_.length;i++){
      int my_list_id=account_array_.index(i).my_list_id;
      string my_screen_name=account_array_.index(i).my_screen_name;
      get_pixbuf_async.begin(config_.cache_dir_path,my_screen_name,account_array_.index(i).my_profile_image_url,16,config_.profile_image_hash_table,(obj,res)=>{
        Pixbuf pixbuf=get_pixbuf_from_path(config_.loading_icon_path,16);
        account_list_store.append(out iter);
        account_list_store.set(iter,0,my_list_id,1,pixbuf,2,my_screen_name);
        //profile_imageの取得
        pixbuf=get_pixbuf_async.end(res);
        account_list_store.set(iter,1,pixbuf);
        if(i==account_array_.length){
          //デフォで0のアカウントを表示
          account_cbox.active=0;
        }
      });
    }
  }
  
  //tlとcomboboxの連動
  public signal void tl_link(int selected_account_num);
}
