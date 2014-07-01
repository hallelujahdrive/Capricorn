using Gtk;

using ContentsObj;
using SqliteOpr;
using Twitter;
using UI;

namespace OAuth{
  //認証用Window
  class OAuthWindow:Gtk.Window{

    public OAuthWindow(Account account,Sqlite.Database db){
      //プロパティ
      this.title="Capricorn_BETA(認証)";
      this.set_default_size(400,200);
      this.border_width=2;
      this.window_position=WindowPosition.CENTER;
      this.destroy.connect(Gtk.main_quit);
      
      //URLの取得
      string token_url=Twitter.get_token_url(account.api_proxy);
      
      //OAuthboxの作成
      OAuthBox oauth_box=new OAuthBox(account,token_url,db);
      this.add(oauth_box);
      
      //子供が死んだら親も死ぬ
      oauth_box.destroy.connect(()=>{
        this.destroy();
      });
    }
  }
    
  //認証用UI
  class OAuthBox:UI.OAuthUI{
    public OAuthBox(Account account,string token_url,Sqlite.Database db){
      //get_pin_buttonの設定
      get_pin_button.set_uri(token_url);
      
      //send_pin_bboxの設定
      send_pin_bbox.sensitive=false;
         
      //reconquiestion_bboxの設定
      reconquiestion_bbox.sensitive=false;
         
      //pin_code_entryの設定
      pin_code_entry.sensitive=false;
         
      //シグナルの処理
      get_pin_button.clicked.connect(()=>{
        get_pin_button_clicked();
      });
          
      send_pin_button.clicked.connect(()=>{
        send_pin_code(account,db);
      });
      pin_code_entry.activate.connect(()=>{
        send_pin_button.clicked();
      });
        
      reconquiestion_button.clicked.connect(()=>{
        reconquiestion_url(account);
      });
        
    }
      
    //get_pin_codeがクリックされた時の処理
    private void get_pin_button_clicked(){
      //message_labelのtextの変更
      message_label.set_text("PINコード打って");
      //get_pin_bboxをunsensitiveに
      get_pin_bbox.sensitive=false;
      //pin_code_entry,send_pin_bboxをsensitiveに
      pin_code_entry.sensitive=true;
      send_pin_bbox.sensitive=true;
    }
      
    //pin_codeの送信
    private void send_pin_code(Account account,Sqlite.Database db){
      //PINコードの読み取り
      string pin_code=pin_code_entry.get_text();
      
      //空白時は送信しない
      if(pin_code!=""){
        bool success=Twitter.get_token_and_token_secret(account,pin_code);
        pin_code_entry.set_text("");
        
        if(success){
          //認証成功
          message_label.set_text("");
          status_label.set_text("認証完了");
          //アカウント情報もらってきて
          account.my_list_id=SqliteOpr.record_count(db,"ACCOUNT");
          Twitter.get_account_info(account);
          //データベースに書き出し
          SqliteOpr.insert_account(account,db);
          this.destroy();
        }else{
          //認証失敗
          message_label.set_text("とりあえずURLも一回もらってきて");
          status_label.set_text("認証失敗");
          pin_code_entry.sensitive=false;
          send_pin_bbox.sensitive=false;
          reconquiestion_bbox.sensitive=true;
        }
      }
    }
      
    //URLの再取得
    private void reconquiestion_url(Account account){
      string token_url=Twitter.get_token_url(account.api_proxy);
      if(token_url!=null){
        //get_pin_buttonの設定
        get_pin_button.set_uri(token_url);
      
        //ラベルの設定
        message_label.set_text("んじゃも一回PINコードもらってきて");
        status_label.set_text("未認証");
      
        //sensitive,unsensitive
        get_pin_bbox.sensitive=true;
        pin_code_entry.sensitive=false;
        send_pin_bbox.sensitive=false;
        reconquiestion_bbox.sensitive=false;
      }
    }
  }
}
