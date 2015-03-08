using Gdk;
using Gtk;

using ImageUtil;
using SqliteUtil;
using TwitterUtil;

[GtkTemplate(ui="/org/gtk/capricorn/ui/account_settings_page.ui")]
class AccountSettingsPage:Frame{
  private GLib.Array<Account> _account_array;
  
  private Config _config;

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
    int len=(int)_account_array.length;
    OAuthDialog oauth_dialog=new OAuthDialog(len,account);
    oauth_dialog.set_transient_for(settings_window_);
    oauth_dialog.show_all();
    
    //oauth_dialogのcallback
    oauth_dialog.destroy.connect(()=>{
      if(oauth_dialog.success){
        settings_window_.account_is_changed=true;
        _account_array.append_val((owned)account);
      }
      load_acount_tree_view();
    });
    
    if(_account_array.length==1){
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
    _account_array.remove_index(remove_list_id);
    for(int i=remove_list_id;i<_account_array.length;i++){
      _account_array.index(i).my_list_id=i;
    }
    
    if(_account_array.length==1){
     account_remove_button.set_sensitive(false);
    }
   
    settings_window_.account_is_changed=true;
    
    load_acount_tree_view();
  }
  
  public AccountSettingsPage(GLib.Array<Account> account_array,Config config,SettingsWindow settings_window){
    _account_array=account_array;
    _config=config;
    settings_window_=settings_window;
    
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
    for(int i=0;i<_account_array.length;i++){
      //戻り値用のbool
      bool profile_image_loaded=false;
      TreeIter iter;
      
      account_list_store.append(out iter);
      account_list_store.set(iter,0,_account_array.index(i).my_list_id,2,_account_array.index(i).my_screen_name);
      //load中の画像のRotateSurface
      try{
        RotateSurface rotate_surface=new RotateSurface(_config.icon_theme.load_icon(LOADING_ICON,16,IconLookupFlags.NO_SVG));
        rotate_surface.run();
        rotate_surface.update.connect((surface)=>{
          if(!profile_image_loaded&&account_list_store!=null){
            account_list_store.set(iter,1,pixbuf_get_from_surface(surface,0,0,16,16));
          }   
          return !profile_image_loaded;
        });
      }catch(Error e){
        print("IconTheme Error : %s\n",e.message);
      }
      //profile_imageの取得
      get_pixbuf_async.begin(_config.cache_dir_path,_account_array.index(i).my_screen_name,_account_array.index(i).my_profile_image_url,16,_config.profile_image_hash_table,(obj,res)=>{
        account_list_store.set(iter,1,get_pixbuf_async.end(res));
        profile_image_loaded=true;
      });
    }
  }
}
