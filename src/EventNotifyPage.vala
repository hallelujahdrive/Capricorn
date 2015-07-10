using Gdk;
using Gtk;
using Ruribitaki;

[GtkTemplate(ui="/org/gtk/capricorn/ui/event_notify_page.ui")]
class EventNotifyPage:Page,Frame{
  //Pageのinstance
  public Tab tab{get;set;}
  public position pos{get;set;}
  
  public unowned Array<CapricornAccount> cpr_account_array;
    
  //widget
  [GtkChild]
  private Grid main_grid;
  
  private AccountComboBox account_combo_box;
  
  public EventNotifyPage(Array<CapricornAccount> cpr_account_array,Config config,MainWindow main_window){
    //Pageのinstanceの初期化
    tab=new Tab.from_icon_name(EVENT_NOTIFY_ICON,IconSize.LARGE_TOOLBAR);
    pos=config.positions[PageType.EVENT_NOTIFY];
    
    this.cpr_account_array=cpr_account_array;
    
    account_combo_box=new AccountComboBox(cpr_account_array,account_combo_box_changed,config,main_window);
    main_grid.attach(account_combo_box,0,0,1,1);
  }
  
  private void account_combo_box_changed(int selected_account_num){
    if(cpr_account_array.length>0&&selected_account_num<=cpr_account_array.length-1){
      //子供を殺す
      if(main_grid.get_children().length()>=2){
        main_grid.remove_row(1);
      }
      cpr_account_array.index(selected_account_num).event_notify_list_box.unparent();
      main_grid.attach(cpr_account_array.index(selected_account_num).event_notify_list_box,0,1,1,1);
    }
  }
  
  //初期化用noedの取得
  public void init(int selected_account_num){
    account_combo_box_changed(selected_account_num);
  }
}
