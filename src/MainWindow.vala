using Gdk;
using Gtk;
using Sqlite;
using Ruribitaki;

using ImageUtil;
using SqliteUtil;

[GtkTemplate(ui="/org/gtk/capricorn/ui/main_window.ui")]
class MainWindow:ApplicationWindow{
  private unowned Config config;
  private weak SignalPipe signal_pipe;

  //CapricornAccountの配列
  private unowned Array<CapricornAccount> cpr_account_array;
  
  private Array<Notebook> notebook_array=new Array<Notebook>();
  
  private PostPage post_page;
  private EventNotifyPage event_notify_page;
  
  private IconButton settings_button;
  
  private SettingsWindow settings_window;
  
  [GtkChild]
  private Box notebook_box;
  
  [GtkChild]
  private Box button_box;
    
  public MainWindow(Capricorn capricorn){
    GLib.Object(application:capricorn);
    
    config=capricorn.config;
    signal_pipe=capricorn.signal_pipe;
    cpr_account_array=capricorn.cpr_account_array;
     
    //初期化
    init();
    
    post_page=new PostPage(cpr_account_array,config,signal_pipe);
    event_notify_page=new EventNotifyPage(cpr_account_array,config,signal_pipe);
    
    settings_button=new IconButton(SETTINGS_ICON,null,null,IconSize.LARGE_TOOLBAR);

    load_pages();

    notebook_array.index(2).append_page(post_page,post_page.tab);
    notebook_array.index(2).append_page(event_notify_page,event_notify_page.tab);
    button_box.pack_end(settings_button,false,false,0);
        
    //シグナルハンドラ
    //表示に時間かかるからあとから読み込み
    this.show.connect(()=>{
      signal_pipe.show();
    });
    
    //アクティブなTLとPostアカウントの同期
    post_page.tl_link.connect((selected_account_num)=>{
      notebook_array.index(0).set_current_page(selected_account_num);
      notebook_array.index(1).set_current_page(selected_account_num);
    });
    
    //SettingsWindowを開く
    settings_button.clicked.connect(()=>{
      settings_button.sensitive=false;
      
      settings_window=new SettingsWindow(cpr_account_array,reload_settings,config,signal_pipe);
      settings_window.set_transient_for(this);
      settings_window.show_all();
    });
    
    //Mediasのopen
    signal_pipe.media_url_click_event.connect((tweet_node,media_array)=>{
      MediaPage media_page=new MediaPage(tweet_node,media_array,config);
      notebook_array.index(2).append_page(media_page,media_page.tab);
      notebook_array.index(2).set_current_page(notebook_array.index(2).page_num(media_page));
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
        CapricornAccount cpr_account=new CapricornAccount(config,signal_pipe,account_array.index(i));
        cpr_account_array.append_val(cpr_account);
        cpr_account_array.index(i).list_id=(int)i;
        cpr_account_array.index(i).init();
        insert_account(cpr_account_array.index(i),config.db);
        
        notebook_array.index(0).append_page(cpr_account_array.index(i).home_time_line,cpr_account_array.index(i).home_time_line.tab);
        notebook_array.index(1).append_page(cpr_account_array.index(i).mention_time_line,cpr_account_array.index(i).mention_time_line.tab);
        
      }
      //account_cboxの再読み込み
      signal_pipe.account_array_change_event();
      signal_pipe.show();
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
      cpr_account_array.index(i).init();
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
    signal_pipe.account_array_change_event();
    init();
    load_pages();
    signal_pipe.show();
  }
}
