using Gdk;
using Gtk;
using Sqlite;
using Ruribitaki;

using ImageUtil;
using SqliteUtil;

[GtkTemplate(ui="/org/gtk/capricorn/ui/main_window.ui")]
class MainWindow:ApplicationWindow{
  private unowned Config config;

  //CapricornAccountの配列
  private unowned Array<CapricornAccount> cpr_account_array;
  
  private Array<Notebook> notebook_array=new Array<Notebook>();
  
  public PostPage post_page;
  private EventNotifyPage event_notify_page;
  
  private IconButton settings_button;
  
  private SettingsWindow settings_window;
  
  [GtkChild]
  private Box notebook_box;
  
  [GtkChild]
  private Box button_box;
    
  public MainWindow(Capricorn capricorn,Array<CapricornAccount>cpr_account_array){
    GLib.Object(application:capricorn);
    
    config=capricorn.config;
    this.cpr_account_array=cpr_account_array;
     
    //初期化
    init();
    
    post_page=new PostPage(cpr_account_array,config,this);
    event_notify_page=new EventNotifyPage(cpr_account_array,config,this);
    
    settings_button=new IconButton(SETTINGS_ICON,null,null,IconSize.LARGE_TOOLBAR);

    load_pages();

    notebook_array.index(2).append_page(post_page,post_page.tab);
    notebook_array.index(2).append_page(event_notify_page,event_notify_page.tab);
    button_box.pack_end(settings_button,false,false,0);
        
    //シグナルハンドラ
    
    //アクティブなTLとPostアカウントの同期
    post_page.tl_link.connect((selected_account_num)=>{
      notebook_array.index(0).set_current_page(selected_account_num);
      notebook_array.index(1).set_current_page(selected_account_num);
    });
    
    //SettingsWindowを開く
    settings_button.clicked.connect(()=>{
      settings_button.sensitive=false;
      
      settings_window=new SettingsWindow(cpr_account_array,reload_settings,config,this);
      settings_window.set_transient_for(this);
      settings_window.show_all();
    });
  }
  
  //設定の再読み込み
  private void reload_settings(Array<Account> account_array){
    //CapricornAccountの削除
    if(settings_window.account_is_changed){
      for(int i=0;i<cpr_account_array.length;){
        if(i>=account_array.length||cpr_account_array.index(i).id!=account_array.index(i).id){
          delete_account(i,config.db);
          cpr_account_array.index(i).destroy();  
          //weak CapricornAccount del_account=cpr_account_array.index(i);
          cpr_account_array.remove_index(i);
          //print("%u\n",del_account.get_user_stream_ref_count());
          //list_idの更新
          for(int j=i;j<cpr_account_array.length;j++){
            cpr_account_array.index(j).list_id=j;
            update_account_list_id(j,j+1,config.db);
          }
        }else{
          i++;
        }
      }
      //追加
      for(uint i=cpr_account_array.length;i<account_array.length;i++){
        CapricornAccount cpr_account=new CapricornAccount(config,account_array.index(i));
        cpr_account_array.append_val(cpr_account);
        cpr_account_array.index(i).list_id=(int)i;
        cpr_account_array.index(i).init(this);
        insert_account(cpr_account_array.index(i).list_id,cpr_account_array.index(i),config.db);
        
        notebook_array.index(0).append_page(cpr_account_array.index(i).home_time_line,cpr_account_array.index(i).home_time_line.tab);
        notebook_array.index(1).append_page(cpr_account_array.index(i).mention_time_line,cpr_account_array.index(i).mention_time_line.tab);
        
      }
      //account_cboxの再読み込み
      account_array_change_event();
      this.show();
    }
    settings_button.set_sensitive(true);
  }
  
  private void init(){
    //notebookの配置(仮置きで3)
    for(int i=0;i<3;i++){
      Notebook notebook=new Notebook();
      notebook_array.append_val(notebook);
      notebook_box.pack_start(notebook_array.index(i));
    }
    notebook_box.show_all();
    //cpr_accountの初期化
    for(int i=0;i<cpr_account_array.length;i++){
      cpr_account_array.index(i).init(this);
    }
  }
  
  private void load_pages(){
    for(int i=0;i<cpr_account_array.length;i++){
      notebook_array.index(0).append_page(cpr_account_array.index(i).home_time_line,cpr_account_array.index(i).home_time_line.tab);
      notebook_array.index(1).append_page(cpr_account_array.index(i).mention_time_line,cpr_account_array.index(i).mention_time_line.tab);
    }
    event_notify_page.init(0);
  }
  
  //初回起動時,認証後に再読込する
  public void load_all(){
    account_array_change_event();
    init();
    load_pages();
    this.show();
  }

  //MediaPageを開く
  public void open_media_page(Node tweet_node,medium[] media,medium[] extended_media){
    MediaPage media_page=new MediaPage(tweet_node,media,extended_media,config);
    notebook_array.index(2).append_page(media_page,media_page.tab);
    notebook_array.index(2).set_current_page(notebook_array.index(2).page_num(media_page));
  }

  //signal
  //AccountComboBoxの再読み込み
  public signal void account_array_change_event();
  //colorが変更された
  public signal void color_change_event();
  //event_node_node_conutが変更された
  public signal void event_notify_settings_change_event();
  //timeline_node_conutが変更された
  public signal void time_line_node_count_change_event();  
}
