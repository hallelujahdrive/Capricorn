using Gtk;

//page
interface Page:Widget{
  public abstract Tab tab{get;set;}
  
  public abstract position pos{get;set;}
}
