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
  
  private Array<PageNotebook> page_notebook_array=new Array<PageNotebook>();
  
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
    
    page_notebook_array.index(post_page.pos.column).insert_page(post_page);
    page_notebook_array.index(event_notify_page.pos.column).insert_page(event_notify_page);
    button_box.pack_end(settings_button,false,false,0);
        
    //シグナルハンドラ
    //初期化
    this.show.connect(()=>{
      init_event();
    });
    
    //アクティブなTLとPostアカウントの同期
    post_page.tl_link.connect((selected_account_num)=>{
      page_notebook_array.index(0).set_current_page(selected_account_num);
      page_notebook_array.index(1).set_current_page(selected_account_num);
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
            update_account_list_id(j,cpr_account_array.index(j).id,config.db);
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
        //positionの初期化
        cpr_account_array.index(i).home_pos=config.positions[PageType.DEFAULT_HOME];
        cpr_account_array.index(i).home_pos.tab=page_notebook_array.index(cpr_account_array.index(i).home_pos.column).get_n_pages();
        cpr_account_array.index(i).mention_pos=config.positions[PageType.DEFAULT_MENTION];
        cpr_account_array.index(i).mention_pos.tab=page_notebook_array.index(cpr_account_array.index(i).mention_pos.column).get_n_pages();
        //初期化
        cpr_account_array.index(i).init(this);
        //Databaseへ追加
        insert_account(cpr_account_array.index(i).list_id,cpr_account_array.index(i),cpr_account_array.index(i).home_pos,cpr_account_array.index(i).mention_pos,config.db);
        //pageの追加
        page_notebook_array.index(cpr_account_array.index(i).home_pos.column).insert_page(cpr_account_array.index(i).home_timeline);
        
      }
      //account_cboxの再読み込み
      account_array_change_event();
      this.show();
    }
    settings_button.set_sensitive(true);
  }
  
  private void init(){
    //notebookの配置
    for(int i=0;i<config.column_length;i++){
      PageNotebook page_notebook=new PageNotebook();
      page_notebook_array.append_val(page_notebook);
      notebook_box.pack_start(page_notebook_array.index(i));
    }
    notebook_box.show_all();
    //cpr_accountの初期化
    for(int i=0;i<cpr_account_array.length;i++){
      cpr_account_array.index(i).init(this);
    }
  }
  
  private void load_pages(){
    for(int i=0;i<cpr_account_array.length;i++){
      page_notebook_array.index(cpr_account_array.index(i).home_pos.column).insert_page(cpr_account_array.index(i).home_timeline);
      page_notebook_array.index(cpr_account_array.index(i).mention_pos.column).insert_page(cpr_account_array.index(i).mention_timeline);
    }
    event_notify_page.init(0);
  }
  
  //初回起動時,認証後に再読込する
  public void load_all(){
    account_array_change_event();
    init();
    load_pages();
    //signalの発行
    init_event();
  }

  //MediaPageを開く
  public void open_media_page(Node tweet_node,medium[] media,medium[] extended_media){
    MediaPage media_page=new MediaPage(tweet_node,media,extended_media,config);
    page_notebook_array.index(media_page.pos.column).insert_page(media_page);
    page_notebook_array.index(media_page.pos.column).set_current_page(page_notebook_array.index(2).page_num(media_page));
  }

  //signal
  //AccountComboBoxの再読み込み
  public signal void account_array_change_event();
  //colorが変更された
  public signal void color_change_event();
  //event_node_node_conutが変更された
  public signal void event_notify_settings_change_event();
  //初期化
  public signal void init_event();
  //timeline_node_conutが変更された
  public signal void timeline_node_count_change_event();  
}
