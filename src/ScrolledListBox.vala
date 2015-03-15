using Gtk;

[GtkTemplate(ui="/org/gtk/capricorn/ui/scrolled_list_box.ui")]
class ScrolledListBox:ScrolledWindow{
  
  protected weak Config config;
  protected weak SignalPipe signal_pipe;
  
  protected int node_count_limit;
  protected int node_count=0;

  //widget
  [GtkChild]
  protected ListBox list_box;
      
  public ScrolledListBox(Config config,SignalPipe signal_pipe){
    this.config=config;
    this.signal_pipe=signal_pipe;
    
    list_box.override_background_color(StateFlags.NORMAL,this.config.white);
    
  }
  
  //Nodeの追加(append)
  public virtual void add_node(Node node){
    list_box.add(node);
    node_count++;
  }
  
  //Nodeの追加(prepend)
  public virtual void prepend_node(Node node){
    list_box.prepend(node);
    //古いNodeの削除
    if(node_count==node_count_limit){
      //ListBoxRowの削除
      remove_list_box_row(list_box.get_row_at_index(node_count));
    }else{
      node_count++;
    }
  }
  
  //ListBoxRowの削除
  public virtual void remove_list_box_row(ListBoxRow list_box_row){
    list_box.remove(list_box_row);
  }
  
  //Nodeの削除
  protected virtual void delete_nodes(){
    while(node_count>node_count_limit){
      //ListBoxRowの取得
      node_count--;
      list_box.remove(list_box.get_row_at_index(node_count));
    }
  }
}
