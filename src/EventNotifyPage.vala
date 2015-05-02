using Gdk;
using Gtk;
using Ruribitaki;

[GtkTemplate(ui="/org/gtk/capricorn/ui/event_notify_page.ui")]
class EventNotifyPage:Frame{
  public unowned Array<TLNode> tl_node_array;
    
  //widget
  [GtkChild]
  private Grid main_grid;
  
  [GtkChild]
  public Image tab;
  
  private AccountComboBox account_combo_box;
  
  public EventNotifyPage(Array<Account> account_array,GLib.Array<TLNode> tl_node_array,Config config,SignalPipe signal_pipe){
    this.tl_node_array=tl_node_array;
    
    account_combo_box=new AccountComboBox(account_array,account_combo_box_changed,config,signal_pipe);
    main_grid.attach(account_combo_box,0,0,1,1);
  }
  
  private void account_combo_box_changed(int selected_account_num){
    if(tl_node_array.length>0&&selected_account_num<=tl_node_array.length-1){
      //子供を殺す
      if(main_grid.get_children().length()>=2){
        main_grid.remove_row(1);
      }
      tl_node_array.index(selected_account_num).event_notify_list_box.unparent();
      main_grid.attach(tl_node_array.index(selected_account_num).event_notify_list_box,0,1,1,1);
    }
  }
  
  //初期化用noedの取得
  public void init(int selected_account_num){
    account_combo_box_changed(selected_account_num);
  }
}
