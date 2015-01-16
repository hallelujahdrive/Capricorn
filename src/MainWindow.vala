using Gdk;
using Gtk;
using Sqlite;

using ImageUtils;
using TwitterUtils;

[GtkTemplate(ui="/org/gtk/capricorn/ui/main_window.ui")]
public class MainWindow:ApplicationWindow{
  private Config config;
  private SignalPipe signal_pipe;

  //Accountの配列
  private GLib.Array<Account> account_array;

  //TLNodeの配列
  private GLib.Array<TLNode> tl_node_array=new GLib.Array<TLNode>();
  
  private PostPage post_page;
  private SettingsButton settings_button;
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
    settings_button=new SettingsButton(config,signal_pipe);
        
    //load
    various_notebook.append_page(post_page,post_page.post_tab);
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
    signal_pipe.settings_button_click_event.connect(()=>{
      settings_button.sensitive=false;
      
      settings_window=new SettingsWindow(account_array,config,signal_pipe);
      settings_window.set_transient_for(this);
      settings_window.show_all();
    });
    
    //SettingsWindowを閉じる
    signal_pipe.settings_window_destroy_event.connect(()=>{
      reload_settings();
      settings_button.sensitive=true;
    });
    
    //Mediasのopen
    signal_pipe.media_url_click_event.connect((media_array,clone_node)=>{
      MediasPage medias_page=new MediasPage(media_array,clone_node,config);
      various_notebook.append_page(medias_page,medias_page.tab);
      various_notebook.set_current_page(various_notebook.page_num(medias_page));
    });
  }
  
  //設定の再読み込み
  private void reload_settings(){
    //TLNotebookの削除
    if(settings_window.account_is_changed){
      for(int i=0;i<tl_node_array.length;){
        if(tl_node_array.index(i).my_id!=account_array.index(i).my_id){
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
        home_tl_notebook.append_page(tl_node_array.index(i).home_tl_page,tl_node_array.index(i).home_tab);
        mention_tl_notebook.append_page(tl_node_array.index(i).mention_tl_page,tl_node_array.index(i).mention_tab);
      }
      //account_cboxの再読み込み
      post_page.load_account_combobox();
    }
    settings_button.set_sensitive(true);
  }
  
  private void load_notebooks(){
    //TLのロード
    for(int i=0;i<account_array.length;i++){
      TLNode tl_node=new TLNode(account_array.index(i),config,signal_pipe);
      tl_node_array.append_val(tl_node);
      home_tl_notebook.append_page(tl_node_array.index(i).home_tl_page,tl_node_array.index(i).home_tab);
      mention_tl_notebook.append_page(tl_node_array.index(i).mention_tl_page,tl_node_array.index(i).mention_tab);
    }
  }
  
  //初回起動時,認証後に再読込する
  public void load_all(){
    post_page.load_account_combobox();
    load_notebooks();
  }
}
