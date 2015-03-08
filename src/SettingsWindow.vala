using Gdk;
using Gtk;

using SqliteUtil;
using TwitterUtil;

[GtkTemplate(ui="/org/gtk/capricorn/ui/settings_window.ui")]
class SettingsWindow:Dialog{
  private GLib.Array<Account> _account_array;
  
  private Config _config;
  private SignalPipe _signal_pipe;
  
  private AccountSettingsPage account_settings_page;
  private DisplaySettingsPage display_settings_page;
  private TLSettingsPage tl_settings_page;
  
  public bool account_is_changed=false;
  
  [GtkChild]
  private Notebook settings_notebook;
  
  [GtkCallback]
  private void ok_button_clicked_cb(Button ok_button){
    if(account_is_changed){
      int account_count_records=count_records(_config.db,"ACCOUNT");
      //Databaseからの削除
      for(int i=0;i<account_count_records;){
        if(i>=_account_array.length||get_id(i,_config.db)!=_account_array.index(i).my_id){
          delete_account(i,_config.db);
          account_count_records--;
          for(int j=i;j<account_count_records;j++){
            update_account_list_id(j,j+1,_config.db);
          }
        }else{
          i++;
        }
      }
      //Databaseへ追加
      for(int i=account_count_records;i<_account_array.length;i++){
        insert_account(_account_array.index(i),_config.db);
      }
    }
    //colorの更新
    if(display_settings_page.color_is_changed){
      display_settings_page.set_color();
      //アップデート
      update_color(0,_config);
      //シグナルの発行
      _signal_pipe.color_change_event();
    }
    
    //fontの更新
    if(display_settings_page.font_is_changed){
      display_settings_page.set_font_desc();
      //アップデート
      update_font(0,_config.font_profile,_config.db);
      //シグナルの発行
      _signal_pipe.color_change_event();
    }
    
    //ツイートの取得数の更新
    if(tl_settings_page.changed){
      tl_settings_page.set_timeline_nodes();
      //アップデート
      update_timeline_node_count(_config.init_node_count,_config.tl_node_count,_config.db);
      //シグナルの発行
      _signal_pipe.timeline_nodes_is_changed();
    }
    
    this.destroy();
  }
  
  //Cancel
  [GtkCallback]
  private void cancel_button_clicked_cb(Button cancel_button){
    //account_arrayの復帰
    if(account_is_changed){
      _account_array.remove_range(0,_account_array.length);
      int account_count_records=count_records(_config.db,"ACCOUNT");
      for(int i=0;i<account_count_records;i++){
        Account account=new Account();
        _account_array.append_val((owned)account);
        select_account(i,_account_array.index(i),_config.db);
        account_verify_credential(_account_array.index(i));
      }
    }
    account_is_changed=false;
    this.destroy();
  }
  
  public SettingsWindow(GLib.Array<Account> account_array,Func func,Config config,SignalPipe signal_pipe){
    _account_array=account_array;
    _config=config;
    _signal_pipe=signal_pipe;
    
    account_settings_page=new AccountSettingsPage(_account_array,_config,this);
    display_settings_page=new DisplaySettingsPage(_config);
    tl_settings_page=new TLSettingsPage(_config);
    
    settings_notebook.append_page(account_settings_page,account_settings_page.tab);
    settings_notebook.append_page(display_settings_page,display_settings_page.tab);
    settings_notebook.append_page(tl_settings_page,tl_settings_page.tab);
        
    //シグナルハンドラ
    this.destroy.connect(()=>{
      func(null);
    });
  }
}
