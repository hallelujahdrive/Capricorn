namespace TwitterUtil{
  //urlsの構造体
  public struct urls{
    public string display_url;
    public string expanded_url;
    public string url;
    public int start_indices;
    public int end_indices;
  }
  //mediaの構造体
  [Compact]
  public struct media{
    public string display_url;
    public string expanded_url;
    public string media_url;
    public string media_url_https;
    public string url;
    public int start_indices;
    public int end_indices;
  }
}
