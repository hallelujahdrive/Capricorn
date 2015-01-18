using Gdk;
using Gtk;

using ImageUtils;
using SqliteUtils;

[GtkTemplate(ui="/org/gtk/capricorn/ui/account_settings_page.ui")]
class AccountSettingsPage:Frame{
  private GLib.Array<Account> account_array_;
  
  private Config config_;

  //AccountのCellRenderer
  private CellRendererPixbuf cell_pixbuf=new CellRendererPixbuf();
  private CellRendererText cell_text=new CellRendererText();
  
  //Widget
  [GtkChild]
  private TreeView account_tree_view;
  
  [GtkChild]
  private ListStore account_list_store;
  
  [GtkChild]
  private Button account_remove_button;
  
  [GtkChild]
  public Image tab;
  
  private TreeSelection account_selection;
  private TreeIter iter;
  
  private SettingsWindow settings_window_;
    
  //Callback
  [GtkCallback]
  private void account_add_button_clicked_cb(Button account_add_button){
    Account account=new Account();
    int len=(int)account_array_.length;
    OAuthDialog oauth_dialog=new OAuthDialog(len,account);
    oauth_dialog.set_transient_for(settings_window_);
    oauth_dialog.show_all();
    
    //oauth_dialogのcallback
    oauth_dialog.destroy.connect(()=>{
      if(oauth_dialog.success){
        settings_window_.account_is_changed=true;
        account_array_.append_val(account);
      }
      load_acount_tree_view();
    });
    
    if(account_array_.length==1){
      account_remove_button.set_sensitive(false);
    }
  }
  
  
  //Accountの削除
  [GtkCallback]
  private void account_remove_button_clicked_cb(Button account_remove_button){
    GLib.Value val;
    
    account_selection.get_selected(null,out iter);
    account_list_store.get_value(iter,0,out val);
    
    int remove_list_id=(int)val;
    
    //list_idをずらす
    account_array_.remove_index(remove_list_id);
    for(int i=remove_list_id;i<account_array_.length;i++){
      account_array_.index(i).my_list_id=i;
    }
    
    if(account_array_.length==1){
     account_remove_button.set_sensitive(false);
    }
   
    settings_window_.account_is_changed=true;
    
    load_acount_tree_view();
  }
  
  public AccountSettingsPage(GLib.Array<Account> account_array,Config config,SettingsWindow settings_window){
    account_array_=account_array;
    config_=config;
    settings_window_=settings_window;
    
    //tabのicon
    tab.set_from_pixbuf(config_.account_pixbuf);
    
    //TreeViewのload
    account_tree_view.insert_column_with_attributes(-1,"",cell_pixbuf,"pixbuf",1);
    account_tree_view.insert_column_with_attributes(-1,"Screen name",cell_text,"text",2);
    load_acount_tree_view();
    
    account_list_store.set_sort_column_id(0,SortType.ASCENDING);
    
    account_selection=account_tree_view.get_selection();
    //remove_buttonのロック
    if(account_array.length==1){
      account_remove_button.set_sensitive(false);
    }
  }
  //TreeViewのload
  private void load_acount_tree_view(){
    account_list_store.clear();
    for(int i=0;i<account_array_.length;i++){
      int my_list_id=account_array_.index(i).my_list_id;
      string my_screen_name=account_array_.index(i).my_screen_name;
      get_pixbuf_async.begin(config_.cache_dir_path,my_screen_name,account_array_.index(i).my_profile_image_url,16,config_.profile_image_hash_table,(obj,res)=>{
        Pixbuf pixbuf=config_.loading_pixbuf_16px;
        account_list_store.append(out iter);
        account_list_store.set(iter,0,my_list_id,1,pixbuf,2,my_screen_name);
        //profile_imageの取得
        pixbuf=get_pixbuf_async.end(res);
        account_list_store.set(iter,1,pixbuf);
      });
    }
  }
}
