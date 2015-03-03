using Rest;

namespace TwitterUtil{
  //通常apiによるjsonの取得
  public string[] get_timeline_json(OAuthProxy api_proxy,int get_tweet_max,bool status_is_mention){
    //文字列,戻り値の配列
    string tl_json;
    string[] tl_json_split=new string[get_tweet_max];
    ProxyCall tl_call=api_proxy.new_call();
    //mentionかどうか
    if(status_is_mention){
      tl_call.set_function(FUNCTION_STATUSES_MENTIONS_TIMELINE);
    }else{
      tl_call.set_function(FUNCTION_STATUSES_HOME_TIMELINE);
    }
    //proxy_callのパラメータ
    tl_call.set_method("GET");
    tl_call.add_param(PARAM_COUNT,get_tweet_max.to_string());
    //取得とセイキヒョウゲンカッコバクショウ
    try{
      tl_call.run();
      tl_json=tl_call.get_payload();
      string tl_json_slice=tl_json.slice(1,tl_json.length-1);
      var tl_regex_replace=new Regex("(},{\"created_at\")");
      string tl_regex=tl_regex_replace.replace(tl_json_slice,-1,0,"}\n{\"created_at\"");
      tl_json_split=tl_regex.split("\n");
    }catch(Error e){
      print("%s\n",e.message);
    }
    return tl_json_split;
  }
}
