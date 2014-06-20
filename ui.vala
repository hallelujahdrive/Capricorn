using Gtk;

namespace UI{
  //MainWindow
  class AppWindow:Gtk.Window{
    //コンストラクタ
    private Gtk.Grid app_grid=new Gtk.Grid();
    
    public PostBox post_box=new PostBox();
    
    public Gtk.Notebook home_tl_note=new Gtk.Notebook();
    public Gtk.Notebook mention_tl_note=new Gtk.Notebook();
    public Gtk.Notebook various_note=new Gtk.Notebook();
    
    public AppWindow (){
      //プロパティ
      this.title="Capricorn_Beta";
      this.set_default_size(800,500);
      this.border_width=2;
      this.window_position=WindowPosition.CENTER;
      this.destroy.connect(Gtk.main_quit);
      
      app_grid.set_column_homogeneous(true);
      
      home_tl_note.set_vexpand(true);
      mention_tl_note.set_vexpand(true);
      various_note.set_vexpand(true);
      
      //レイアウト
      app_grid.attach(post_box,0,0,3,1);
      app_grid.attach(home_tl_note,0,1,1,1);
      app_grid.attach(mention_tl_note,1,1,1,1);
      app_grid.attach(various_note,2,1,1,1);
      
      this.add(app_grid);
    }
  }
  //PostBox
  class PostBox:Gtk.Box{
    //コンストラクタ
    //box
    private Gtk.Box p_box=new Gtk.Box(Gtk.Orientation.HORIZONTAL,2);
    private Gtk.Box a_box=new Gtk.Box(Gtk.Orientation.HORIZONTAL,2);
    //post関連
    public Gtk.TextView post_textview=new Gtk.TextView();
    public Gtk.Label chars_count_label=new Gtk.Label("140");
    public Gtk.Button post_button=new Gtk.Button.with_label("post");
    public Gtk.ButtonBox post_bbox=new Gtk.ButtonBox(Gtk.Orientation.HORIZONTAL);
    
    private Gtk.ScrolledWindow pb_scrolled=new Gtk.ScrolledWindow(null,null);
    
    //アカウント関連
    public Gtk.ListStore account_list_store=new Gtk.ListStore(1,typeof(string));
    public Gtk.TreeIter iter;
    public Gtk.ComboBox account_cbox;
    
    public PostBox(){
      //プロパティ
      this.set_orientation(Gtk.Orientation.VERTICAL);
      this.set_spacing(2);
      
      account_cbox=new Gtk.ComboBox.with_model(account_list_store);
      //レイアウト
      pb_scrolled.add(post_textview);
      post_bbox.add(post_button);
      
      
      p_box.pack_start(chars_count_label,false,false,0);
      p_box.pack_start(pb_scrolled,true,true,0);
      p_box.pack_start(post_bbox,false,false,0);
      
      a_box.pack_start(account_cbox,false,false,0);
      
      this.pack_start(p_box);
      this.pack_start(a_box);
    }
  }
    
  //TLのScrolledWindow
  class TLScrolledUI:Gtk.ScrolledWindow{
    //コンストラクタ
    public Gtk.ListBox lbox=new Gtk.ListBox();
    
    public TLScrolledUI(){
      //プロパティ
      this.set_policy(Gtk.PolicyType.NEVER,Gtk.PolicyType.ALWAYS);
      lbox.set_vexpand(true);
      //レイアウト
      this.add(lbox);
    }
  }
  
  //ツイートのオブジェクト
  class TweetObjUI:Gtk.ListBoxRow{
    //コンストラクタ
    public Gtk.Grid tweet_obj_grid=new Gtk.Grid();    
    public Gtk.EventBox tweet_obj_ebox=new Gtk.EventBox();
    
    public Gtk.EventBox icon_ebox=new Gtk.EventBox();
    public Gtk.EventBox source_ebox=new Gtk.EventBox();
    
    public Gtk.Box name_box=new Gtk.Box(Gtk.Orientation.VERTICAL,0);
    public Gtk.Box text_box=new Gtk.Box(Gtk.Orientation.VERTICAL,0);
    public Gtk.Box created_at_box=new Gtk.Box(Gtk.Orientation.VERTICAL,0);
    
    public Gtk.DrawingArea icon_area=new Gtk.DrawingArea();
    public Gtk.DrawingArea name_area=new Gtk.DrawingArea();
    public Gtk.DrawingArea text_area=new Gtk.DrawingArea();
    public Gtk.DrawingArea created_at_area=new Gtk.DrawingArea();
    public Gtk.DrawingArea source_area=new Gtk.DrawingArea();
    
    public TweetObjUI(){
      //プロパティ
      icon_ebox.set_vexpand(true);
      icon_ebox.set_hexpand(true);
      name_box.set_vexpand(true);
      name_box.set_hexpand(true);
      text_box.set_vexpand(true);
      text_box.set_hexpand(true);
      created_at_box.set_vexpand(true);
      source_ebox.set_vexpand(true);
      
      //レイアウト
      icon_ebox.add(icon_area);
      name_box.pack_start(name_area);
      text_box.pack_start(text_area);
      created_at_box.add(created_at_area);
      source_ebox.add(source_area);
      
      //tweet_obj_grid.attach(icon_ebox,0,0,1,2);
      tweet_obj_grid.attach(name_box,0,0,1,1);
      tweet_obj_grid.attach(text_box,1,0,1,1);
      
      tweet_obj_ebox.add(tweet_obj_grid);
      this.add(tweet_obj_ebox);
    }
  }
  
  //認証用UI
  class OAuthUI:Gtk.Grid{
    //コンストラクタ
    public Gtk.Label message_label=new Gtk.Label("とりあえずPINコードもらってきて");
    public Gtk.Label status_label=new Gtk.Label("未認証");
    public Gtk.Entry pin_code_entry=new Gtk.Entry();
      
    public Gtk.ButtonBox get_pin_bbox=new Gtk.ButtonBox(Gtk.Orientation.HORIZONTAL);
    public Gtk.ButtonBox send_pin_bbox=new Gtk.ButtonBox(Gtk.Orientation.HORIZONTAL);
    public Gtk.ButtonBox reconquiestion_bbox=new Gtk.ButtonBox(Gtk.Orientation.HORIZONTAL);
    
    public Gtk.LinkButton get_pin_button=new Gtk.LinkButton.with_label("","PINコードを取得");
    public Gtk.Button send_pin_button=new Gtk.Button.with_label("認証");
    public Gtk.Button reconquiestion_button=new Gtk.Button.with_label("再取得");
    
    public OAuthUI(){
      //gridのプロパティ
      this.set_column_spacing(2);
      this.set_row_homogeneous(true);

      //pin_code_entryの設定
      pin_code_entry.set_hexpand(true);
         
      //ButtonBoxに詰める
      get_pin_bbox.add(get_pin_button);
      send_pin_bbox.add(send_pin_button);
      reconquiestion_bbox.add(reconquiestion_button);
          
      //gridのレイアウト
      this.attach(message_label,0,0,2,1);
      this.attach(get_pin_bbox,0,1,2,1);
      this.attach(pin_code_entry,0,2,1,1);
      this.attach(send_pin_bbox,1,2,1,1);
      this.attach(status_label,0,3,1,1);
      this.attach(reconquiestion_bbox,1,3,1,1);
    }
  }
}
