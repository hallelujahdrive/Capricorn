using Sqlite;

using AccountInfo;
using Capricorn;
using FileOpr;
using OAuth;
using Twitter;
using UI;

int main(string[] args){
  //Path
  string CPR_DIR=GLib.Path.build_path(GLib.Path.DIR_SEPARATOR_S,GLib.Environment.get_home_dir(),".capricorn");
  string DB_PATH=GLib.Path.build_path(GLib.Path.DIR_SEPARATOR_S,CPR_DIR,"capricorn.db");
  
  //アカウントの配列
  GLib.Array<Account> account_array=new GLib.Array<Account>();
  int account_count=0;
  
  //ディレクトリの確認
  bool mk_new_dir=FileOpr.mk_cpr_dir(CPR_DIR);
  
  //データベース
  Sqlite.Database db;
  
  Gtk.init(ref args);    
  //データベースのオープン
  int ec=Sqlite.Database.open(DB_PATH,out db);
  
  //ディレクトリが新規作成された場合,認証Windowを開く.
  if(mk_new_dir){
    SqliteOpr.create_tables(db);
    Account account=new Account();
    account_array.append_val(account);
    //認証ウィンドウを開く
    OAuthWindow oauth_window=new OAuthWindow(account_array.index(0),db);
    oauth_window.show_all();
    Gtk.main();
    account_count=1;
  }
  //データベースにあるアカウント数を確認後,読み出し
  account_count=SqliteOpr.record_count(db,"ACCOUNT");
  if(account_count!=0){
    for(int i=0;i<account_count;i++){
      Account account=new Account();
      account_array.append_val(account);
      SqliteOpr.select_account(i,account_array.index(i),db);
      Twitter.get_account_info(account_array.index(i));
    }
    CprWindow main_window=new CprWindow(account_array,db);
    main_window.show_all();
    Gtk.main();
  }
  return 0;
}
