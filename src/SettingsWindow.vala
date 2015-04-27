using Gdk;
using Gtk;

using SqliteUtil;
using TwitterUtil;

[GtkTemplate(ui="/org/gtk/capricorn/ui/settings_window.ui")]
class SettingsWindow:Dialog{
  private unowned GLib.Array<Account> account_array;
  
  private weak Config config;
  private weak SignalPipe signal_pipe;
  
  private AccountSettingsPage account_settings_page;
  private DisplaySettingsPage display_settings_page;
  private EventNotifySettingsPage event_notify_settings_page;
  private NetworkSettingsPage network_settings_page;
  private TimeLineSettingsPage time_line_settings_page;
  
  public bool account_is_changed=false;
  
  [GtkChild]
  private Notebook settings_notebook;
  
  [GtkCallback]
  private void ok_button_clicked_cb(Button ok_button){
    if(account_is_changed){
      int account_count_records=count_records(config.db,"ACCOUNT");
      //Databaseからの削除
      for(int i=0;i<account_count_records;){
        if(i>=account_array.length||get_id(i,config.db)!=account_array.index(i).my_id){
          deleteaccount(i,config.db);
          account_count_records--;
          for(int j=i;j<account_count_records;j++){
            updateaccount_list_id(j,j+1,config.db);
          }
        }else{
          i++;
        }
      }
      //Databaseへ追加
      for(int i=account_count_records;i<account_array.length;i++){
        insertaccount(account_array.index(i),config.db);
      }
    }
    
    //colorの更新
    if(display_settings_page.color_is_changed){
      display_settings_page.update_color_settings();
      //データベースのアップデート
      update_color(0,config);
      //シグナルの発行
      signal_pipe.color_change_event();
    }
    
    //fontの更新
    if(display_settings_page.font_is_changed){
      display_settings_page.update_font_desc_settings();
      //データベースのアップデート
      update_font(0,config.font_profile,config.db);
      //シグナルの発行
      signal_pipe.color_change_event();
    }
    
    //eventの表示数の更新
    if(event_notify_settings_page.changed){
      event_notify_settings_page.update_settings();
      //データベースのアップデート
      update_event_notify_settings(config);
      //シグナルの発行
      signal_pipe.event_notify_settings_change_event();
    }
    
    //network設定の更新
    if(network_settings_page.changed){
      network_settings_page.update_settings();
      //データベースのアップデート
      update_network_settings(config);
    }
    
    //nodeの表示数の更新
    if(time_line_settings_page.changed){
      time_line_settings_page.update_settings();
      //データベースのアップデート
      update_time_line_settings(config);
      //シグナルの発行
      signal_pipe.time_line_node_count_change_event();
    }
    
    this.destroy();
  }
  
  //Cancel
  [GtkCallback]
  private void cancel_button_clicked_cb(Button cancel_button){
    //account_arrayの復帰
    if(account_is_changed){
      account_array.remove_range(0,account_array.length);
      int account_count_records=count_records(config.db,"ACCOUNT");
      for(int i=0;i<account_count_records;i++){
        Account account=new Account(TWITTER_CONSUMER_KEY,TWITTER_CONSUMER_SECRET);
        account_array.append_val((owned)account);
        select_account(i,account_array.index(i),config.db);
        account_verify_credential(account_array.index(i));
      }
    }
    account_is_changed=false;
    this.destroy();
  }
  
  public SettingsWindow(GLib.Array<Account> account_array,Func func,Config config,SignalPipe signal_pipe){
    this.account_array=account_array;
    this.config=config;
    this.signal_pipe=signal_pipe;
    
    account_settings_page=new AccountSettingsPage(this.account_array,this.config,this);
    display_settings_page=new DisplaySettingsPage(this.config);
    event_notify_settings_page=new EventNotifySettingsPage(this.config);
    network_settings_page=new NetworkSettingsPage(this.config);
    time_line_settings_page=new TimeLineSettingsPage(this.config);
    
    settings_notebook.append_page(account_settings_page,account_settings_page.tab);
    settings_notebook.append_page(display_settings_page,display_settings_page.tab);
    settings_notebook.append_page(event_notify_settings_page,event_notify_settings_page.tab);
    settings_notebook.append_page(network_settings_page,network_settings_page.tab);
    settings_notebook.append_page(time_line_settings_page,time_line_settings_page.tab);
        
    //シグナルハンドラ
    this.destroy.connect(()=>{
      func(null);
    });
  }
}
