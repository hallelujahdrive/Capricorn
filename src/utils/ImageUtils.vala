using Cairo;
using Gdk;
using Soup;

using FileUtils;

namespace ImageUtils{
  //URLからのPixbufの取得
  async Pixbuf get_pixbuf_async(string image_path_root,string screen_name,string image_url,int size,HashTable<string,string?> profile_image_hash_table){
    //imageのpath
    string image_path=GLib.Path.build_path(GLib.Path.DIR_SEPARATOR_S,image_path_root,screen_name+".png");
    //戻り値のPixbuf
    Pixbuf pixbuf=null;
    string? image_url_from_hash=profile_image_hash_table.get(screen_name);
    //hashtableから取得したurlと一致すれば取得
    if(image_url_from_hash!=null&&image_url_from_hash==image_url){
      return get_pixbuf_from_path(image_path,size);
    }else{
      //画像が取得されていなければ取得
      //Soupconfig_.cache_dir_path
      Session session=new Session();
      Message msg=new Message("GET",image_url);
      session.queue_message(msg,(_sess,_msg)=>{
        try{
          var memory_stream=new MemoryInputStream.from_data(_msg.response_body.data,null);
          pixbuf=new Pixbuf.from_stream_at_scale(memory_stream,48,48,false);
          
          //アイコンの切り出し
          Cairo.ImageSurface surface=new Cairo.ImageSurface(Cairo.Format.ARGB32,48,48);
          Cairo.Context context=new Cairo.Context(surface);
          context.arc(24,24,24,0,2*Math.PI);
          context.clip();
          context.new_path();
          context.scale(1,1);
          Cairo.Surface image=cairo_surface_create_from_pixbuf(pixbuf,1,null);
          context.set_source_surface(image,0,0);
          context.paint();
          
          pixbuf=pixbuf_get_from_surface(surface,0,0,48,48);
          //保存
          pixbuf.save(image_path,"png");
          //HashTableへの追加
          profile_image_hash_table.insert(screen_name,image_url);
          
          memory_stream.close();
          get_pixbuf_async.callback();
        }catch(Error e){
          print("Error:%s\n",e.message);
        }
      });
    }
    yield;
    return pixbuf.scale_simple(size,size,InterpType.BILINEAR);
  }
  
  //URLからのpixbufの取得(media)
  async Pixbuf get_media_pixbuf_async(string image_url){
    //戻り値のPixbuf
    Pixbuf pixbuf=null;
    Session session=new Session();
    Message msg=new Message("GET",image_url);
    session.queue_message(msg,(_sess,_msg)=>{
      try{
        var memory_stream=new MemoryInputStream.from_data(_msg.response_body.data,null);
        pixbuf=new Pixbuf.from_stream(memory_stream);
        memory_stream.close();
        get_media_pixbuf_async.callback();
      }catch(Error e){
        print("Error:%s\n",e.message);
      }
    });
    yield;
    return pixbuf;
  }
  
  //pathからのpixbufの生成
  public Pixbuf get_pixbuf_from_path(string image_path,int size){
    Pixbuf pixbuf=null;
    try{
      var image=File.new_for_path(image_path);
      var image_stream=image.read();
      pixbuf=new Pixbuf.from_stream_at_scale(image_stream,size,size,true,null);
      image_stream.close();
    }catch(Error e){
      print("%s\n",e.message);
    }
    return pixbuf;
  }
  
  //pathからのpixbuf_animationの生成
  public PixbufAnimation get_pixbuf_animation_from_path(string image_path){
    PixbufAnimation pixbuf_animation=null;
    try{
      var image=File.new_for_path(image_path);
      var image_stream=image.read();
      pixbuf_animation=new PixbufAnimation.from_stream(image_stream,null);
      image_stream.close();
    }catch(Error e){
      print("%s\n",e.message);
    }
    return pixbuf_animation;
  }
}
