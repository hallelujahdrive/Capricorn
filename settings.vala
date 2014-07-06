using ContentsObj;
using FileOpr;
using OAuth;
using UI;

namespace Settings{
  class SettingsWindow:SettingsWindowUI{
    
    public SettingsWindow(GLib.Array<Account> account_array,string cache_dir,bool* account_add_or_remove,Sqlite.Database db){
      AccountManagement account_management=new AccountManagement(account_array,cache_dir,account_add_or_remove,db);
        this.settings_note.append_page(account_management,null);      
    }
   
    class AccountManagement:AccountManagementUI{
      public AccountManagement(GLib.Array<Account> account_array,string cache_dir,bool* account_add_or_remove,Sqlite.Database db){
        *account_add_or_remove=false;
        //list_storeにアカウントの追加
        load_treeview(account_array,cache_dir,db);
        
        Gtk.CellRendererPixbuf cell_pixbuf=new Gtk.CellRendererPixbuf();
        account_view.insert_column_with_attributes(-1,"",cell_pixbuf,"pixbuf",1);
        
        Gtk.CellRendererText cell_text=new Gtk.CellRendererText();
        account_view.insert_column_with_attributes(-1,"Account",cell_text,"text",2);
        
        account_selection=account_view.get_selection();
        
        //シグナリルの処理
        //アカウントの追加
        account_add_button.clicked.connect(()=>{
          //URLの取得
          //アカウント
          Account account=new Account();
          string token_url=Twitter.get_token_url(account.api_proxy);
          //oauth_box
          OAuthBox oauth_box=new OAuthBox(account,token_url,db);
          this.dummy_oauth_box.add(oauth_box);
          this.dummy_oauth_box.show_all();
          
          //認証完了時にTreeViewを再読み込み
          oauth_box.destroy.connect(()=>{
            if(Twitter.get_account_info(account)){
              account_array.append_val(account);
              load_treeview(account_array,cache_dir,db);
              *account_add_or_remove=true;
            }
          });
        });
        
        //アカウントの削除
        account_remove_button.clicked.connect(()=>{
          GLib.Value val; //戻り値用のval
          
          //現在選択中の項目を読み込み
          account_selection.get_selected(null,out iter);
          account_list_store.get_value(iter,0,out val);
          
          //削除するアカウントidの取得
          int remove_list_id=(int)val;
          //削除
          account_array.remove_index(remove_list_id);
          SqliteOpr.delete_account(remove_list_id,db);
          //データベースを詰める
          for(int i=remove_list_id;i<account_array.length;i++){
            SqliteOpr.update_account(i,i+1,db);
          }
          //再読み込み
          *account_add_or_remove=true;
          load_treeview(account_array,cache_dir,db);
        });
      }
      
      //アカウントのload
      private void load_treeview(GLib.Array<Account> account_array,string cache_dir,Sqlite.Database db){
        account_list_store.clear();
        for(int i=0;i<account_array.length;i++){
          //get_image(image_param,null,cache_dir,db);
          try{
           // Gdk.Pixbuf pixbuf=new Gdk.Pixbuf.from_file(image_param.image_path);
            this.account_list_store.append(out iter);
           // this.account_list_store.set(iter,0,account_array.index(i).my_list_id,1,pixbuf,2,"@"+account_array.index(i).my_screen_name);
          }catch(Error e){
            print("%s\n",e.message);
          }
        }        
        this.account_view.show_all();
      }
    }
  }
}
