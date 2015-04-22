namespace TwitterUtil{
  //hashtagの構造体
  public struct hashtag{
    public int[] indices;
    public string text;
  }
    
  //urlの構造体
  public struct url{
    public string display_url;
    public string expanded_url;
    public int[] indices;
    public string media_url;
    public string media_url_https;
    public string url;
  }
}
