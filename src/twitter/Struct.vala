namespace TwitterUtil{
  //hashtagの構造体
  public struct hashtag{
    public string text;
    public int start_indices;
    public int end_indices;
  }
    
  //urlの構造体
  public struct url{
    public string display_url;
    public string expanded_url;
    public string media_url;
    public string media_url_https;
    public string url;
    public int start_indices;
    public int end_indices;
  }
}
