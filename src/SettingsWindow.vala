using Gdk;
using Gtk;

using SqliteUtil;
using TwitterUtil;

[GtkTemplate(ui="/org/gtk/capricorn/ui/settings_window.ui")]
class SettingsWindow:Dialog{
  private GLib.Array<Account> account_array_;
  
  private Config config_;
  private SignalPipe signal_pipe_;
  
  private AccountSettingsPage account_s_page;
  private DisplaySettingsPage display_s_page;
  private TLSettingsPage tl_s_page;
  
  public bool account_is_changed=false;
  
  [GtkChild]
  private Notebook settings_notebook;
  
  [GtkCallback]
  private void ok_button_clicked_cb(Button ok_button){
    if(account_is_changed){
      int account_count_records=count_records(config_.db,"ACCOUNT");
      //Databaseからの削除
      for(int i=0;i<account_count_records;){
        if(i>=account_array_.length||get_id(i,config_.db)!=account_array_.index(i).my_id){
          delete_account(i,config_.db);
          account_count_records--;
          for(int j=i;j<account_count_records;j++){
            update_account_list_id(j,j+1,config_.db);
          }
        }else{
          i++;
        }
      }
      //Databaseへ追加
      for(int i=account_count_records;i<account_array_.length;i++){
        insert_account(account_array_.index(i),config_.db);
      }
    }
    //colorの更新
    if(display_s_page.color_is_changed){
      display_s_page.set_color();
      //アップデート
      update_color(0,config_);
      //シグナルの発行
      signal_pipe_.color_change_event();
    }
    
    //fontの更新
    if(display_s_page.font_is_changed){
      display_s_page.set_font_desc();
      //アップデート
      update_font(0,config_.font_profile,config_.db);
      //シグナルの発行
      signal_pipe_.color_change_event();
    }
    
    //ツイートの取得数の更新
    if(tl_s_page.node_max_is_changed){
      tl_s_page.set_timeline_nodes();
      //アップデート
      update_timeline_node_count(config_.get_tweet_nodes,config_.tweet_node_max,config_.db);
      //シグナルの発行
      signal_pipe_.timeline_nodes_is_changed();
    }
    
    this.destroy();
  }
  
  //Cancel
  [GtkCallback]
  private void cancel_button_clicked_cb(Button cancel_button){
    //account_arrayの復帰
    if(account_is_changed){
      account_array_.remove_range(0,account_array_.length);
      int account_count_records=count_records(config_.db,"ACCOUNT");
      for(int i=0;i<account_count_records;i++){
        Account account=new Account();
        account_array_.append_val(account);
        select_account(i,account_array_.index(i),config_.db);
        get_account_info(account_array_.index(i));
      }
    }
    account_is_changed=false;
    this.destroy();
  }
  
  public SettingsWindow(GLib.Array<Account> account_array,Func func,Config config,SignalPipe signal_pipe){
    account_array_=account_array;
    config_=config;
    signal_pipe_=signal_pipe;
    
    account_s_page=new AccountSettingsPage(account_array_,config_,this);
    display_s_page=new DisplaySettingsPage(config_);
    tl_s_page=new TLSettingsPage(config_);
    
    settings_notebook.append_page(account_s_page,account_s_page.tab);
    settings_notebook.append_page(display_s_page,display_s_page.tab);
    settings_notebook.append_page(tl_s_page,tl_s_page.tab);
        
    //シグナルハンドラ
    this.destroy.connect(()=>{
      func(null);
    });
  }
}
