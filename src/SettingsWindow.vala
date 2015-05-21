using Gdk;
using Gtk;
using Ruribitaki;

using SqliteUtil;

[GtkTemplate(ui="/org/gtk/capricorn/ui/settings_window.ui")]
class SettingsWindow:Dialog{
  private unowned GLib.Array<CapricornAccount> cpr_account_array;
  
  private weak Config config;
  private weak MainWindow main_window;
    
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
    //accountの更新
    if(account_is_changed){
      int account_count_records=count_records(config.db,"ACCOUNT");
      //Databaseからの削除
      for(int i=0;i<account_count_records;){
        if(i>=cpr_account_array.length||get_id(i,config.db)!=cpr_account_array.index(i).id){
          delete_account(i,config.db);
          account_count_records--;
          for(int j=i;j<account_count_records;j++){
            update_account_list_id(j,j+1,config.db);
          }
        }else{
          i++;
        }
      }
      //Databaseへ追加
      for(int i=account_count_records;i<cpr_account_array.length;i++){
        insert_account(cpr_account_array.index(i),config.db);
      }
    }
        
    //colorの更新
    if(display_settings_page.color_is_changed){
      display_settings_page.update_color_settings();
      //データベースのアップデート
      update_color(0,config.color_profile,config.db);
      //シグナルの発行
      main_window.color_change_event();
    }
    
    //fontの更新
    if(display_settings_page.font_is_changed){
      display_settings_page.update_font_desc_settings();
      //データベースのアップデート
      update_font(0,config.font_profile,config.db);
      //シグナルの発行
      main_window.color_change_event();
    }
    
    //eventの表示数の更新
    if(event_notify_settings_page.changed){
      event_notify_settings_page.update_settings();
      //データベースのアップデート
      update_event_notify_settings(config.event_node_count,config.event_show_on_time_line,config.db);
      //シグナルの発行
      main_window.event_notify_settings_change_event();
    }
    
    //network設定の更新
    if(network_settings_page.changed){
      network_settings_page.update_settings();
      //データベースのアップデート
      update_network_settings(config.use_proxy,config.proxy_uri,config.db);
    }
    
    //nodeの表示数の更新
    if(time_line_settings_page.changed){
      time_line_settings_page.update_settings();
      //データベースのアップデート
      update_time_line_settings(config.init_time_line_node_count,config.time_line_node_count,config.db);
      //シグナルの発行
      main_window.time_line_node_count_change_event();
    }
    
    this.destroy();
  }
  
  //Cancel
  [GtkCallback]
  private void cancel_button_clicked_cb(Button cancel_button){
    account_is_changed=false;
    this.destroy();
  }
  
  public SettingsWindow(GLib.Array<CapricornAccount> cpr_account_array,Func<Array<Account>> func,Config config,MainWindow main_window){
    this.cpr_account_array=cpr_account_array;
    this.config=config;
    this.main_window=main_window;
    
    account_settings_page=new AccountSettingsPage(this.cpr_account_array,this.config,this);
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
      func(account_settings_page.account_array);
    });
  }
}
