using Gdk;
using Gtk;
using Ruribitaki;

using ImageUtil;
using SqliteUtil;

[GtkTemplate(ui="/org/gtk/capricorn/ui/account_settings_page.ui")]
class AccountSettingsPage:Frame{
  private unowned GLib.Array<Account> account_array;
  
  private weak Config config;

  //AccountのCellRenderer
  private CellRendererPixbuf cell_pixbuf=new CellRendererPixbuf();
  private CellRendererText cell_text=new CellRendererText();
  
  //Widget
  [GtkChild]
  private TreeView account_tree_view;
  
  [GtkChild]
  private Gtk.ListStore account_list_store;
  
  [GtkChild]
  private Button account_remove_button;
  
  [GtkChild]
  public Image tab;
  
  private TreeSelection account_selection;
  private TreeIter iter;
  
  private SettingsWindow settings_window;
    
  //Callback
  [GtkCallback]
  private void account_add_button_clicked_cb(Button account_add_button){
    Account account=new Account(TWITTER_CONSUMER_KEY,TWITTER_CONSUMER_SECRET);
    int len=(int)account_array.length;
    OAuthDialog oauth_dialog=new OAuthDialog(len,account);
    oauth_dialog.set_transient_for(settings_window);
    oauth_dialog.show_all();
    
    //oauth_dialogのcallback
    oauth_dialog.destroy.connect(()=>{
      if(oauth_dialog.success){
        settings_window.account_is_changed=true;
        account_array.append_val((owned)account);
      }
      load_acount_tree_view();
    });
    
    if(account_array.length==1){
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
    account_array.remove_index(remove_list_id);
    for(int i=remove_list_id;i<account_array.length;i++){
      account_array.index(i).my_list_id=i;
    }
    
    if(account_array.length==1){
     account_remove_button.set_sensitive(false);
    }
   
    settings_window.account_is_changed=true;
    
    load_acount_tree_view();
  }
  
  public AccountSettingsPage(GLib.Array<Account> account_array,Config config,SettingsWindow settings_window){
    this.account_array=account_array;
    this.config=config;
    this.settings_window=settings_window;
    
    //TreeViewのload
    account_tree_view.insert_column_with_attributes(-1,"",cell_pixbuf,"pixbuf",1);
    account_tree_view.insert_column_with_attributes(-1,"Screen name",cell_text,"text",2);
    load_acount_tree_view();
    
    account_list_store.set_sort_column_id(0,SortType.ASCENDING);
    
    account_selection=account_tree_view.get_selection();
    //remove_buttonのロック
    if(this.account_array.length==1){
      account_remove_button.set_sensitive(false);
    }
  }
  
  //TreeViewのload
  private void load_acount_tree_view(){
    account_list_store.clear();
    for(int i=0;i<account_array.length;i++){
      //戻り値用のbool
      bool profile_image_loaded=false;
      TreeIter iter;
      
      account_list_store.append(out iter);
      account_list_store.set(iter,0,account_array.index(i).my_list_id,2,account_array.index(i).my_screen_name);
      //load中の画像のRotateSurface
      try{
        RotateSurface rotate_surface=new RotateSurface(config.icon_theme.load_icon(LOADING_ICON,16,IconLookupFlags.NO_SVG));
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
      get_profile_image_async.begin(account_array.index(i).my_screen_name,account_array.index(i).my_profile_image_url,16,config,(obj,res)=>{
        account_list_store.set(iter,1,get_profile_image_async.end(res));
        profile_image_loaded=true;
      });
    }
  }
}
