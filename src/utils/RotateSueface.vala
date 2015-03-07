using Cairo;
using Gdk;

namespace ImageUtil{
  class RotateSurface{
    private int width;
    private int height;
    
    private Surface surface;
    private int deg=0;
    
    //Surface
    public RotateSurface(Pixbuf pixbuf){
      //初期化
      surface=cairo_surface_create_from_pixbuf(pixbuf,1,null);
      width=pixbuf.get_width();
      height=pixbuf.get_height();
    }
    
    private bool rotate(){
      ImageSurface image_surface=new ImageSurface(Format.ARGB32,width,height);
      Context context=new Context(image_surface);
      context.translate(0.5*width,0.5*height);
      context.rotate(deg*Math.PI/180);
      context.translate(-0.5*width,-0.5*height);
      context.set_source_surface(surface,0,0);
      context.paint();
      if((deg+=15)>=360){
        deg-=360;
      }
    
      return update(image_surface);
    }
    
    public void run(){
      //回転
      Timeout.add(100,rotate);
    }
    
    //更新用のシグナル
    public signal bool update(ImageSurface image_surface);
  }
}
