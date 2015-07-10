using Gdk;
using Gtk;

[GtkTemplate(ui="/org/gtk/capricorn/ui/page_notebook.ui")]
class PageNotebook:Notebook{   
  
  public PageNotebook(){
    drag_dest_set(this,DestDefaults.MOTION|DestDefaults.HIGHLIGHT,null,DragAction.MOVE);
  }
  
  //ページの追加

  public void @insert_page(Page page){
    base.insert_page(page,page.tab,page.pos.tab);
    set_tab_reorderable(page,true);
  }
}
