//enum
namespace TwitterUtil{
  //ParsedJsonObjのtype
  public enum ParsedJsonObjType{
    DELETE,
    EVENT,
    FRIENDS,
    NULL,
    RETWEET,
    TWEET;
  }
  
  //eventのtype.UNKNOWNは暫定
  public enum EventType{
    ACCESS_REVOKED,
    BLOCK,
    UNBLOCK,
    FAVORITE,
    UNFAVORITE,
    FOLLOW,
    UNFOLLOW,
    LIST_CREATED,
    LIST_DESTROYED,
    LIST_UPDATED,
    LIST_MEMBER_ADDED,
    LIST_MEMBER_REMOVED,
    LIST_USER_SUBSCRIBED,
    LIST_USER_UNSUBSCRIBED,
    USER_UPDATE,
    NULL;
  }
  
  //tweetのtype
  public enum TweetType{
    NORMAL,
    NULL,
    REPLY;
  }
}
