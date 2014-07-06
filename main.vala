using Sqlite;

using ContentsObj;
using Capricorn;
using FileOpr;
using OAuth;
using Twitter;
using UI;

int main(string[] args){
  //Path
  string CPR_DIR=GLib.Path.build_path(GLib.Path.DIR_SEPARATOR_S,GLib.Environment.get_home_dir(),".capricorn");
  string DB_PATH=GLib.Path.build_path(GLib.Path.DIR_SEPARATOR_S,CPR_DIR,"capricorn.db");
  string CACHE_DIR=GLib.Path.build_path(GLib.Path.DIR_SEPARATOR_S,CPR_DIR,"cache");
  
  //アカウントの配列
  GLib.Array<Account> account_array=new GLib.Array<Account>();
  int account_count=0;
  
  //ディレクトリの確認
  bool mk_new_dir=FileOpr.mk_cpr_dir(CPR_DIR,CACHE_DIR);
  
  //データベース
  Sqlite.Database db;
  
  Gtk.init(ref args);    
  //データベースのオープン
  int ec=Sqlite.Database.open_v2(DB_PATH,out db,Sqlite.OPEN_READWRITE|OPEN_CREATE);
  if(ec!=Sqlite.OK){
    print("Can't open database:%d:%s\n",db.errcode(),db.errmsg());
  }
  
  //ディレクトリが新規作成された場合,認証Windowを開く.
  if(mk_new_dir){
    SqliteOpr.create_tables(db);
    Account account=new Account();
    //認証ウィンドウを開く
    OAuthWindow oauth_window=new OAuthWindow(account,db);
    oauth_window.show_all();
    Gtk.main();
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
    CprWindow main_window=new CprWindow(account_array,CACHE_DIR,db);
    main_window.show_all();
    Gtk.main();
    SqliteOpr.delete_all_image_path(db);
    FileOpr.clear_cache(CACHE_DIR);
  }
  return 0;
}
