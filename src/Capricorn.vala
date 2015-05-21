using Gtk;
using Soup;
using Sqlite;
using Ruribitaki;

using FileUtil;
using SqliteUtil;

public class Capricorn:Gtk.Application{
  //ApplicationWindow
  private MainWindow window;
  
  //Accountの配列
  public GLib.Array<CapricornAccount> cpr_account_array=new GLib.Array<CapricornAccount>();
  
  //Path
  private static string CPR_DIR_PATH=GLib.Path.build_path(GLib.Path.DIR_SEPARATOR_S,GLib.Environment.get_home_dir(),".capricorn");
  private static string DB_PATH=GLib.Path.build_path(GLib.Path.DIR_SEPARATOR_S,CPR_DIR_PATH,"capricorn.db");
  
  //config
  public Config config;
  
  //windowを開けるか否か
  private bool can_window_open=false;
  
  public Capricorn(){
    application_id="org.gtk.capricorn";
    flags=GLib.ApplicationFlags.FLAGS_NONE;

    config=new Config(CPR_DIR_PATH);
    
    //ディレクトリの作成
    mk_cpr_dir(CPR_DIR_PATH,config.cache_dir_path);
    //データベースのオープン
    int ec=Database.open_v2(DB_PATH,out config.db,OPEN_READWRITE|OPEN_CREATE);
    if(ec!=Sqlite.OK){
      print("Can't open database:%d:%s\n",config.db.errcode(),config.db.errmsg());
    }
    //テーブルの作成
    if(create_tables(config.db)){
      //テーブルが新規に作成されたら
      //configの初期化
      config.init();
      //insert
      insert_color(0,config.color_profile,config.db);
      insert_event_notify_settings(config.event_node_count,config.event_show_on_time_line,config.db);
      insert_font(0,config.font_profile,config.db);
      insert_network_settings(config.use_proxy,config.proxy_uri,config.db);
      insert_time_line_settings(config.init_time_line_node_count,config.time_line_node_count,config.db);

      can_window_open=true;
    }else{
      //テーブルが存在したら
      //select
      select_color(0,config.color_profile,config.db);
      select_event_notify_settings(out config.event_node_count,out config.event_show_on_time_line,config.db);
      select_font(0,config.font_profile,config.db);
      select_network_settings(out config.use_proxy,out config.proxy_uri,config.db);
      select_time_line_settings(out config.init_time_line_node_count,out config.time_line_node_count,config.db);
      //Account情報の読み出し
      int account_count=count_records(config.db,"ACCOUNT");
      for(int i=0;i<account_count;i++){
        var cpr_account=new CapricornAccount(config);
        //配列に追加
        cpr_account_array.append_val(cpr_account);
        select_account(i,cpr_account_array.index(i),config.db);
        //Account情報の取得
        try{
          account_verify_credential(cpr_account_array.index(i));
          can_window_open=true;
        }catch(Error e){
          print("Account verify credential error : %s\n",e.message);
        }
      }
    }
  }

  public override void startup(){
    base.startup();
    
    //Accountが0なら,認証windowを開く
    if(cpr_account_array.length==0){
      var cpr_account=new CapricornAccount(config);
      OAuthDialog oauth_dialog=new OAuthDialog(cpr_account);
      oauth_dialog.show_all();
      
      //シグナルハンドラ
      oauth_dialog.destroy.connect(()=>{
        if(oauth_dialog.success){
          cpr_account_array.append_val(cpr_account);
          insert_account(cpr_account_array.index(0),config.db);
        }
        if(count_records(config.db,"ACCOUNT")==0){
          window.destroy();
        }else{
          window.load_all();
        }
      });
    }
    
    //時刻表示のロケールを設定
    Intl.setlocale(LocaleCategory.TIME,"en_US.UTF-8");
    //Windowを開く
    if(can_window_open){
      window=new MainWindow(this);
    }
    
    //終了処理
    this.shutdown.connect(()=>{
      clear_cache(config.cache_dir_path);
    });
    

  }
  public override void activate(){
    window.present();
  }
}
