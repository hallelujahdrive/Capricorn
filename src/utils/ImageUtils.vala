using Cairo;
using Gdk;
using Soup;

using FileUtils;

namespace ImageUtils{
  //URLからのPixbufの取得
  async Pixbuf get_pixbuf_async(string image_path,string image_url,int size){
    //戻り値のPixbuf
    Pixbuf pixbuf=null;
    //gifは現状除外
    if(!image_url.has_suffix("gif")){
    //画像が取得されていなければ取得
    if(is_image(image_path)){
      return get_pixbuf_from_path(image_path,size);
    }else{
      //Soup
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
          pixbuf.save(image_path,"png");
          
          memory_stream.close();
          get_pixbuf_async.callback();
        }catch(Error e){
          print("Error:%s\n%s\n",e.message,image_path);
        }
      });
    }
    }
    yield;
    return pixbuf.scale_simple(size,size,InterpType.BILINEAR);
  }
  
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
}
