using Gtk;

using TwitterUtil;

class EventNotifyListBox:ScrolledListBox{
  //NodeのGenericSet
  public GenericSet<string> generic_set=new GenericSet<string>(str_hash,str_equal);
  
  public EventNotifyListBox(Config config,SignalPipe signal_pipe){
    base(config,signal_pipe);
    node_count_limit=config.event_node_count;
    list_box.set_sort_func(list_box_sort_func);
    
    signal_pipe.event_node_count_change_event.connect(()=>{
      node_count_limit=config.event_node_count;
      delete_nodes();
    });
  }
  
  //sort_func
  private int list_box_sort_func(ListBoxRow list_box_row1,ListBoxRow list_box_row2){
    return (int)(((Node)list_box_row1.get_children().data).event_created_at-((Node)list_box_row2.get_children().data).event_created_at);
  }
  
  //prepend
  public override void prepend_node(Node node){
    base.prepend_node(node);

    //GenericSetに追加
    generic_set.add(node.id_str);
  }
  
  //remove
  protected override void remove_list_box_row(ListBoxRow list_box_row){
    //GenericSetから削除
    generic_set.remove(((Node)list_box_row.get_children().data).id_str);
    base.remove_list_box_row(list_box_row);
  }
}
