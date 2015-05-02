using Gdk;
using Gtk;
using Ruribitaki;

using ImageUtil;
using StringUtil;

[GtkTemplate(ui="/org/gtk/capricorn/ui/post_page.ui")]
class PostPage:Frame{
  private unowned GLib.Array<Account> account_array;
  private weak Config config;
  private weak SignalPipe signal_pipe;
  
  private IconButton post_button;
  private IconButton url_shorting_button;
  private AccountComboBox account_combo_box;
  
  private Node _tweet_node;
  
  //tweet_text_view内の文字数
  private static int chars_count=140;
  //リプライ元のtweet_id
  private string? in_reply_to_status_id_str;

  //選択中のaccount
  private static int selected_account_num=0;
  
  //TLの変更を連動させるかどうか
  private bool tl_is_linked=false;
  
  //Widget
  [GtkChild]
  public Image tab;
  
  [GtkChild]
  private Grid main_grid;
  
  [GtkChild]
  private Label chars_count_label;
  
  [GtkChild]
  private TextView tweet_text_view;
  
  [GtkChild]
  private TextBuffer buffer;

  [GtkChild]
  private CheckButton tl_link_cbutton;
  
  //Callback
  //残り文字数のカウント
  [GtkCallback]
  private void buffer_changed_cb(TextBuffer buffer){
    chars_count=140-buffer.get_char_count();
    chars_count_label.set_text(chars_count.to_string());
    //post_buttonのプロパティ
    if(chars_count==140){
      url_shorting_button.set_sensitive(false);
      reply_reset();
    }
    if(chars_count==140||chars_count<0){
      post_button.set_sensitive(false);
    }else{
      post_button.set_sensitive(true);
      url_shorting_button.set_sensitive(true);
    }
  }
  
  [GtkCallback]
  private void tl_link_cbutton_toggled_cb(){
    tl_is_linked=tl_link_cbutton.get_active();
  }
  
  public PostPage(GLib.Array<Account> account_array,Config config,SignalPipe signal_pipe){
    this.account_array=account_array;
    this.config=config;
    this.signal_pipe=signal_pipe;
    
    post_button=new IconButton(POST_ICON,null,null,IconSize.LARGE_TOOLBAR);
    url_shorting_button=new IconButton(URL_SHORTING_ICON,null,null,IconSize.LARGE_TOOLBAR);
    account_combo_box=new AccountComboBox(account_array,account_combo_box_changed,config,signal_pipe);
    
    
    //パッキング
    main_grid.attach(post_button,0,2,1,1);
    main_grid.attach(url_shorting_button,1,2,1,1);
    main_grid.attach(account_combo_box,0,4,2,1);
    
    //プロパティ
    post_button.set_sensitive(false);
    url_shorting_button.set_sensitive(false);
        
    //シグナルハンドラ
    //post
    post_button.clicked.connect(()=>{
      statuses_update.begin(this.account_array.index(selected_account_num),buffer.text,in_reply_to_status_id_str,(obj,res)=>{
        if(statuses_update.end(res)){
          buffer.text="";
        }
      });
    });
    
    //URLの短縮
    url_shorting_button.clicked.connect(()=>{
      string parsed_text=parse_post_text(buffer.text);
      buffer.text=parsed_text;
    });
    
    //add_text
    signal_pipe.add_text_event.connect((text,tweet_node,my_list_id)=>{
      //buffer.txtが更新されるときreply_resetが呼ばれる
      buffer.text=buffer.text+text;
      account_combo_box.active=my_list_id;
      if(tweet_node!=null){
        in_reply_to_status_id_str=tweet_node.id_str;
        _tweet_node=tweet_node;
        main_grid.attach(_tweet_node,0,3,2,1);
      }
            
      tweet_text_view.grab_focus();
    });
    
  }
  
  //リプライのリセット
  private void reply_reset(){
    if(_tweet_node!=null){
      _tweet_node.destroy();
      in_reply_to_status_id_str=null;
    }
  }
  
  //account_combo_box変更
  private void account_combo_box_changed(int _selected_account_num){
    selected_account_num=_selected_account_num;
    
    if(tl_is_linked){
      tl_link(_selected_account_num);
    }
  }
  
  //tlとcomboboxの連動
  public signal void tl_link(int selected_account_num);
}
