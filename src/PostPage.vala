using Gdk;
using Gtk;
using Ruribitaki;

using ImageUtil;
using StringUtil;

[GtkTemplate(ui="/org/gtk/capricorn/ui/post_page.ui")]
class PostPage:Page,Frame{
  //Pageのinstance
  public Tab tab{get;set;}
  public position pos{get;set;}
  
  private unowned Array<CapricornAccount> cpr_account_array;
  private weak Config config;
  private weak MainWindow main_window;
  
  private IconButton post_button;
  private IconButton url_shorting_button;
  private AccountComboBox account_combo_box;
  
  private Node in_reply_to_node;
  
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
  
  public PostPage(Array<CapricornAccount> cpr_account_array,Config config,MainWindow main_window){
    this.cpr_account_array=cpr_account_array;
    this.config=config;
    this.main_window=main_window;

    //tabの設定
    tab=new Tab.from_icon_name(TWEET_ICON,IconSize.LARGE_TOOLBAR);
    //pos
    pos=this.config.positions[PageType.POST];
    
    post_button=new IconButton(POST_ICON,null,null,IconSize.LARGE_TOOLBAR);
    url_shorting_button=new IconButton(URL_SHORTING_ICON,null,null,IconSize.LARGE_TOOLBAR);
    account_combo_box=new AccountComboBox(cpr_account_array,account_combo_box_changed,config,main_window);
    
    
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
      statuses_update.begin(this.cpr_account_array.index(selected_account_num),buffer.text,in_reply_to_status_id_str,(obj,res)=>{
        try{
          if(statuses_update.end(res)){
            buffer.text="";
          }
        }catch(Error e){
          print("Update error : %s\n",e.message);
        }
      });
    });
    
    //URLの短縮
    url_shorting_button.clicked.connect(()=>{
      string parsed_text=parse_post_text(buffer.text);
      buffer.text=parsed_text;
    });
  }
  
  //リプライのリセット
  private void reply_reset(){
    if(in_reply_to_node!=null){
      in_reply_to_node.destroy();
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

  //text_viewerにtextをセット
  public void add_text(string text,int list_id,Node? node=null){
    //buffer.txtが更新されるときreply_resetが呼ばれる
    buffer.text=buffer.text+text;
    account_combo_box.active=list_id;
    if(node!=null){
      in_reply_to_status_id_str=node.id_str;
      in_reply_to_node=node;
      main_grid.attach(in_reply_to_node,0,3,2,1);
    }
          
    tweet_text_view.grab_focus();
  }
  
  //tlとcomboboxの連動
  public signal void tl_link(int selected_account_num);
}
