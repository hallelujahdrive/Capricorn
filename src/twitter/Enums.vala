//enum
namespace TwitterUtil{
  //ParsedJsonObjのtype
  public enum ParsedJsonObjType{
    DELETE,
    EVENT,
    FRIENDS,
    NULL,
    TWEET;
  }
  
  //eventのtype
  public enum EventType{
    FAVORITE;
  }
  
  //tweetのtype
  public enum TweetType{
    MINE,
    NORMAL,
    REPLY,
    RETWEET;
  }
}
