using Gtk;
using Sqlite;
using Ruribitaki;

using SqliteUtil;
using URIUtil;

[GtkTemplate(ui="/org/gtk/capricorn/ui/oauth_window.ui")]
public class OAuthDialog:Gtk.Dialog{
  //url
  private string token_url;
  
  //Account認証
  public bool success=false;
  
  //Account
  private unowned Account account;
  
  [GtkChild]
  private Button auth_button;
  
  [GtkChild]
  private Entry pin_entry;
  
  //Callback
  [GtkCallback]
  private void get_pin_button_clicked_cb(Button get_pin_button){
    //urlのオープン
    open_url(token_url);
    
    pin_entry.sensitive=true;
    auth_button.sensitive=true;
    get_pin_button.sensitive=false;
  }
  [GtkCallback]
  private void pin_entry_activate_cb(Entry pin_entry){
    send_pin();
  }
  
  [GtkCallback]
  private void auth_button_clicked_cb(Button auth_button){
    send_pin();
  }
  
  [GtkCallback]
  private void cancel_button_clicked_cb(Button cancel_button){
    this.destroy();
  }
  public OAuthDialog(Account account){
    this.account=account;
    //プロパティ
    pin_entry.set_sensitive(false);
    auth_button.set_sensitive(false);
    
    try{
      token_url=request_token(this.account);
    }catch(Error e){
      print("Request token error : %s\n",e.message);
    }
    
    //シグナル
    this.destroy.connect(()=>{
      if(success){
        //アカウント情報の取得
        try{
          account_verify_credential(this.account);
        }catch(Error e){
          print("Account verify credential error : %s\n",e.message);
        }
      }
    });
  }
  
  //pinコードの送信
  private void send_pin(){
    string pin_code=pin_entry.get_text();
    if(pin_code!=""){
      try{
        oauth_access_token(account,pin_code);
        success=true;
        this.destroy();
      }catch(Error e){
        print("OAuth access token error : %s\n",e.message);
      }
    }
  }
}
