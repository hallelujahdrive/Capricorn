namespace TwitterUtil{
  //URL
  private static const string API_URL="https://api.twitter.com";
  private static const string STREAM_URL="https://userstream.twitter.com";
  
  private static const string URL_HEAD="https://twitter.com/oauth/authorize?oauth_token=";

  //Function
  private static const string FUNCTION_REQUEST_TOKEN="oauth/request_token";
  private static const string FUNCTION_ACCESS_TOKEN="oauth/access_token";
  private static const string FUNCTION_ACCOUNT_SETTINGS="1.1/account/settings.json";
  private static const string FUNCTION_ACCOUNT_VERIFY_CREDENTIALS="1.1/account/verify_credentials.json";
  private static const string FUNCTION_STATUSES_UPDATE="1.1/statuses/update.json";
  private static const string FUNCTION_STATUSES_HOME_TIMELINE="1.1/statuses/home_timeline.json";
  private static const string FUNCTION_STATUSES_MENTIONS_TIMELINE="1.1/statuses/mentions_timeline.json";
  private static const string FUNCTION_STATUSES_RETWEET="1.1/statuses/retweet/";
  private static const string FUNCTION_STATUSES_SHOW="1.1/statuses/show.json";
  private static const string FUNCTION_FAVORITES_CREATE="1.1/favorites/create.json";
  private static const string FUNCTION_USER="1.1/user.json";

  private static const string PARAM_STATUS="status";
  private static const string PARAM_IN_REPLY_TO_STATUS_ID="in_reply_to_status_id";
  private static const string PARAM_DELIMITED="delimited";
  private static const string PARAM_COUNT="count";
  private static const string PARAM_ID="id";
}
