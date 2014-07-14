using Gtk;

namespace UI{
  //MainWindow
  class AppWindow:Gtk.Window{
    //コンストラクタ
    private Gtk.Grid app_grid=new Gtk.Grid();
    
    public PostBox post_box=new PostBox();
    public SettingsBox settings_box=new SettingsBox();
    
    public Gtk.Notebook home_tl_note=new Gtk.Notebook();
    public Gtk.Notebook mention_note=new Gtk.Notebook();
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
      mention_note.set_vexpand(true);
      various_note.set_vexpand(true);
      
      //レイアウト
      app_grid.attach(post_box,0,0,3,1);
      app_grid.attach(home_tl_note,0,1,1,1);
      app_grid.attach(mention_note,1,1,1,1);
      app_grid.attach(various_note,2,1,1,1);
      app_grid.attach(settings_box,0,2,3,1);
      
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
    private Gtk.CellRendererPixbuf cell_pixbuf=new Gtk.CellRendererPixbuf();
    private Gtk.CellRendererText cell_text=new Gtk.CellRendererText();

    
    public Gtk.ListStore account_list_store=new Gtk.ListStore(3,typeof(int),typeof(Gdk.Pixbuf),typeof(string));
    public Gtk.TreeIter iter;
    public Gtk.ComboBox account_cbox;
      
    public PostBox(){
      //プロパティ
      this.set_orientation(Gtk.Orientation.VERTICAL);
      this.set_spacing(2);
      
      post_textview.set_wrap_mode(Gtk.WrapMode.WORD);
      account_cbox=new Gtk.ComboBox.with_model(account_list_store);
      
      account_cbox.pack_start(cell_pixbuf,true);
      account_cbox.add_attribute(cell_pixbuf,"pixbuf",1);
      account_cbox.pack_start(cell_text,true);
      account_cbox.add_attribute(cell_text,"text",2);
      
      //レイアウト
      pb_scrolled.add(post_textview);
      post_bbox.add(post_button);
      
      p_box.pack_start(chars_count_label,false,false,0);
      p_box.pack_start(pb_scrolled,true,true,0);
      p_box.pack_start(post_bbox,false,false,0);
      
      a_box.pack_start(account_cbox,false,false,0);
      
      this.pack_start(p_box,false,false,0);
      this.pack_start(a_box,false,false,0);
    }
  }
  
  //SettingsButton用
  class SettingsBox:Gtk.Box{
    //コンストラクタ
    private Gtk.ButtonBox settings_bbox=new Gtk.ButtonBox(Gtk.Orientation.HORIZONTAL);
    public Gtk.Button settings_button=new Gtk.Button.with_label("Settings");
    
    public SettingsBox(){
      //プロパティ
      this.set_orientation(Gtk.Orientation.HORIZONTAL);
      this.set_spacing(2);
      
      //レイアウト
      settings_bbox.add(settings_button);
      this.pack_end(settings_bbox,false,false,0);
    }
  }
    
  //TLのScrolledWindow
  class TLScrolledUI:Gtk.ScrolledWindow{
    //コンストラクタ
    public Gtk.ListBox lbox=new Gtk.ListBox();
    
    public TLScrolledUI(){
      //プロパティ
      this.set_policy(Gtk.PolicyType.NEVER,Gtk.PolicyType.ALWAYS);
      //レイアウト
      this.add(lbox);
    }
  }
  
  //ツイートのオブジェクト
  class TweetObjUI:Gtk.ListBoxRow{
    //コンストラクタ
    public Gtk.Grid tweet_obj_grid=new Gtk.Grid();    
    public Gtk.EventBox tweet_obj_ebox=new Gtk.EventBox();
    
    public Gtk.EventBox profile_image_ebox=new Gtk.EventBox();
    public Gtk.EventBox source_ebox=new Gtk.EventBox();
    
    public Gtk.Box profile_image_box=new Gtk.Box(Gtk.Orientation.VERTICAL,0);
    public Gtk.Box name_box=new Gtk.Box(Gtk.Orientation.VERTICAL,0);
    public Gtk.Box text_box=new Gtk.Box(Gtk.Orientation.VERTICAL,0);
    public Gtk.Box created_at_box=new Gtk.Box(Gtk.Orientation.HORIZONTAL,0);

    public Gtk.DrawingArea name_area=new Gtk.DrawingArea();
    public Gtk.DrawingArea text_area=new Gtk.DrawingArea();
    public Gtk.DrawingArea created_at_area=new Gtk.DrawingArea();
    public Gtk.DrawingArea source_area=new Gtk.DrawingArea();
    
    public Gtk.Image profile_image=new Gtk.Image();
    public TweetObjUI(){
      //プロパティ
      profile_image_ebox.set_vexpand(false);
      name_box.set_hexpand(true);
      text_box.set_vexpand(true);
      text_box.set_hexpand(true);
      created_at_box.set_hexpand(true);
      source_ebox.set_hexpand(true);
      
      //レイアウト
      profile_image_ebox.add(profile_image);
      name_box.pack_start(name_area);
      text_box.pack_start(text_area);
      created_at_box.pack_start(created_at_area,true,true,0);
      source_ebox.add(source_area);
      
      profile_image_box.pack_start(profile_image_ebox,false,false,0);
      
      tweet_obj_grid.attach(profile_image_box,0,0,1,2);
      tweet_obj_grid.attach(name_box,1,0,1,1);
      tweet_obj_grid.attach(text_box,1,1,1,1);
      tweet_obj_grid.attach(created_at_box,1,2,1,1);
      tweet_obj_grid.attach(source_ebox,1,3,1,1);
      
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
  
  class SettingsWindowUI:Gtk.Window{
    //コンストラクタ
    public Gtk.Notebook settings_note=new Gtk.Notebook();
    
    public SettingsWindowUI(){
      //Windowの設定
      this.title="設定";
      this.set_default_size(800,500);
      this.border_width=2;
      this.window_position=Gtk.WindowPosition.CENTER;
      
      //レイアウト
      this.add(settings_note);
    }
  }
  
  class AccountManagementUI:Gtk.Grid{
    //コンストラクタ
    private Gtk.Frame account_frame=new Gtk.Frame(null);
    public Gtk.ListStore account_list_store=new Gtk.ListStore(3,typeof(int),typeof(Gdk.Pixbuf),typeof(string));
    public Gtk.TreeIter iter;
    private Gtk.ButtonBox account_bbox=new Gtk.ButtonBox(Gtk.Orientation.VERTICAL);
    public Gtk.Button account_add_button=new Gtk.Button.with_label("add");
    public Gtk.Button account_remove_button=new Gtk.Button.with_label("remove");
    
    //TreeView
    public Gtk.TreeView account_view;
    public Gtk.TreeSelection account_selection;
   
    //oauth_boxのためのbox
    public Gtk.Box dummy_oauth_box=new Gtk.Box(Gtk.Orientation.VERTICAL,0);
    public AccountManagementUI(){
      //プロパティ
      this.set_row_homogeneous(true);
      //レイアウト
      //TreeViewの設定
      account_view=new Gtk.TreeView.with_model(account_list_store);
      account_view.set_hexpand(true);
      account_frame.add(account_view);
    
      account_bbox.set_layout(Gtk.ButtonBoxStyle.START);
      account_bbox.set_spacing(5);
      account_bbox.add(account_add_button);
      account_bbox.add(account_remove_button);
      
      this.attach(account_frame,0,0,1,1);
      this.attach(account_bbox,1,0,1,1);
      this.attach(dummy_oauth_box,0,1,1,1);
    }
  }
}
