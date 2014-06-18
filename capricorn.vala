using Sqlite;

using AccountInfo;
using OAuth;
using SqliteOpr;
using Twitter;
using UI;

namespace Capricorn{
  //本体
  class CprWindow:AppWindow{
    public CprWindow(GLib.Array<Account> account_array,Sqlite.Database db){
      
      //シグナルのコネクト
      this.post_box.post_button.clicked.connect(()=>{
        post_button_clicked(this.post_box.post_textview,account_array.index(0));
      });
      
    }
    
    private void post_button_clicked(Gtk.TextView post_textview,Account account){
      string post=post_textview.buffer.text;
      if(post!=""){
        Twitter.post_tweet(post,account.api_proxy);
        post_textview.buffer.text="";
      }
    }
  }
}
