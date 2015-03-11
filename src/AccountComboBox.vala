using Gdk;
using Gtk;

using ImageUtil;
using TwitterUtil;

[GtkTemplate(ui="/org/gtk/capricorn/ui/account_combo_box.ui")]
class AccountComboBox:ComboBox{
  private unowned Array<Account> _account_array;
  private unowned Func<int> _func;
  private weak Config _config;
  //widget
  [GtkChild]
  private ListStore account_list_store;
  
  private CellRendererPixbuf cell_pixbuf=new CellRendererPixbuf();
  private CellRendererText cell_text=new CellRendererText();
  private TreeIter iter;
  
  //Callback
  //accountの選択
  [GtkCallback]
  private void account_combo_box_changed_cb(){
    if(this.get_active_iter(out iter)){
      Value val;
      account_list_store.get_value(iter,0, out val);
    
    //切り替え時に実行するFunc
    _func((int)val);
    
    }
  }
  
  public AccountComboBox(Array<Account> account_array,Func<int> func,Config config,SignalPipe signal_pipe){
    _account_array=account_array;
    _func=func;
    _config=config;
    
    //プロパティ
    this.pack_start(cell_pixbuf,false);
    this.add_attribute(cell_pixbuf,"pixbuf",1);
    this.pack_start(cell_text,true);
    this.add_attribute(cell_text,"text",2);
    
    account_list_store.set_sort_column_id(0,SortType.ASCENDING);
    
    //読み込み
    load();
    
    //シグナルハンドラ
    signal_pipe.account_array_change_event.connect(()=>{
      load();
    });
  }
    
  //account_comboboxの読み込み
  private void load(){
    account_list_store.clear();
    for(int i=0;i<_account_array.length;i++){
      //RotateSurface戻り値用のbool
      bool profile_image_loaded=false;
      //iter(ローカル)
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
      get_pixbuf_async.begin(_config.cache_dir_path,_account_array.index(i).my_screen_name,_account_array.index(i).my_profile_image_url,16,_config.profile_image_hash_table,(obj,res)=>{
        //profile_imageの取得
        account_list_store.set(iter,1,get_pixbuf_async.end(res));
        profile_image_loaded=true;
      });
    }
    //デフォで0のアカウントを表示
    this.active=0;
  }
}
