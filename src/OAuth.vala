using Gtk;
using Sqlite;

using SqliteUtil;
using TwitterUtil;
using URIUtil;

[GtkTemplate(ui="/org/gtk/capricorn/ui/oauth_window.ui")]
public class OAuthDialog:Gtk.Dialog{
  //url
  private string token_url;
  
  //Account認証
  public bool success=false;
  
  //Account
  private Account account;
  
  [GtkChild]
  private Button get_pin_button;
  
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
  public OAuthDialog(int account_count,Account account_arg){
    account=account_arg;
    //プロパティ
    pin_entry.sensitive=false;
    auth_button.sensitive=false;
    
    token_url=get_token_url(account.api_proxy);
    
    //シグナル
    this.destroy.connect(()=>{
      if(success){
        //アカウント情報の取得
        get_account_verify_credential(account);
        account.my_list_id=account_count;
      }
    });
  }
  
  //pinコードの送信
  private void send_pin(){
    string pin_code=pin_entry.get_text();
    if(pin_code!=""){
      if(get_token_and_token_secret(account,pin_code)){
        success=true;
        this.destroy();
      }
    }
  }
}
