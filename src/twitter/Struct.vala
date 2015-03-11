namespace TwitterUtil{
  //urlsのコンパクトクラス
  [Compact]
  public struct urls{
    public string display_url;
    public string expanded_url;
    public string url;
    public int start_indices;
    public int end_indices;
  }
  //mediaのコンパクトクラス
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
