public class TweetRequestBody {
    public String text;
    public ReplyInfo reply;
    
    public class ReplyInfo {
        public String in_reply_to_tweet_id;
    }
}