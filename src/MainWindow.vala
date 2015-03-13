using Gdk;
using Gtk;
using Sqlite;

using ImageUtil;
using TwitterUtil;

[GtkTemplate(ui="/org/gtk/capricorn/ui/main_window.ui")]
public class MainWindow:ApplicationWindow{
  private unowned Config config;
  private weak SignalPipe signal_pipe;

  //Accountの配列
  private unowned Array<Account> account_array;

  //TLNodeの配列
  private Array<TLNode> tl_node_array=new Array<TLNode>();
  
  private PostPage post_page;
  private EventNotifyPage event_notify_page;
  
  private IconButton settings_button;
  
  private SettingsWindow settings_window;
    
  [GtkChild]
  private Box button_box;

  [GtkChild]
  private Notebook home_tl_notebook;
  
  [GtkChild]
  private Notebook mention_tl_notebook;
  
  [GtkChild]
  private Notebook various_notebook;
    
  public MainWindow(Capricorn capricorn){
    GLib.Object(application:capricorn);
    
    config=capricorn.config;
    signal_pipe=capricorn.signal_pipe;
    account_array=capricorn.account_array;
    
    post_page=new PostPage(account_array,config,signal_pipe);
    event_notify_page=new EventNotifyPage(account_array,tl_node_array,config,signal_pipe);
    
    settings_button=new IconButton(SETTINGS_ICON,null,null,IconSize.LARGE_TOOLBAR);
        
    //load
    various_notebook.append_page(post_page,post_page.tab);
    various_notebook.append_page(event_notify_page,event_notify_page.tab);
    button_box.pack_end(settings_button,false,false,0);
    
    //シグナルハンドラ
    //表示に時間かかるからあとから読み込み
    this.show.connect(()=>{
      load_notebooks();
    });
    
    //アクティブなTLとPostアカウントの同期
    post_page.tl_link.connect((selected_account_num)=>{
      home_tl_notebook.set_current_page(selected_account_num);
      mention_tl_notebook.set_current_page(selected_account_num);
    });
    
    //SettingsWindowを開く
    settings_button.clicked.connect((already)=>{
      settings_button.sensitive=false;
      
      settings_window=new SettingsWindow(account_array,reload_settings,config,signal_pipe);
      settings_window.set_transient_for(this);
      settings_window.show_all();
      
      return true;
    });
    
    //Mediasのopen
    signal_pipe.media_url_click_event.connect((tweet_node,media_array)=>{
      MediaPage media_page=new MediaPage(tweet_node,media_array);
      various_notebook.append_page(media_page,media_page.tab);
      various_notebook.set_current_page(various_notebook.page_num(media_page));
    });
  }
  
  //設定の再読み込み
  private void reload_settings(){
    //TLNotebookの削除
    if(settings_window.account_is_changed){
      for(int i=0;i<tl_node_array.length;){
        if(i>=account_array.length||tl_node_array.index(i).my_id!=account_array.index(i).my_id){
          tl_node_array.remove_index(i);
          home_tl_notebook.remove_page(i);
          mention_tl_notebook.remove_page(i);
        }else{
          i++;
        }
      }
      //追加
      for(uint i=tl_node_array.length;i<account_array.length;i++){
        TLNode tl_node=new TLNode(account_array.index(i),config,signal_pipe);
        tl_node_array.append_val(tl_node);
        home_tl_notebook.append_page(tl_node_array.index(i).home_time_line,tl_node_array.index(i).home_time_line.tab);
        mention_tl_notebook.append_page(tl_node_array.index(i).mention_time_line,tl_node_array.index(i).mention_time_line.tab);
      }
      //account_cboxの再読み込み
      signal_pipe.account_array_change_event();
    }
    settings_button.set_sensitive(true);
  }
  
  private void load_notebooks(){
    //TLのロード
    for(int i=0;i<account_array.length;i++){
      TLNode tl_node=new TLNode(account_array.index(i),config,signal_pipe);
      tl_node_array.append_val(tl_node);
      home_tl_notebook.append_page(tl_node_array.index(i).home_time_line,tl_node_array.index(i).home_time_line.tab);
      mention_tl_notebook.append_page(tl_node_array.index(i).mention_time_line,tl_node_array.index(i).mention_time_line.tab);
    }
    event_notify_page.init(0);
  }
  
  //初回起動時,認証後に再読込する
  public void load_all(){
    signal_pipe.account_array_change_event();
    load_notebooks();
  }
}
