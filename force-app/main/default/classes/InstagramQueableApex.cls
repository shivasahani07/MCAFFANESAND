public class InstagramQueableApex implements Queueable {

    public void execute(QueueableContext context) {
        InstagramAuthHelper.getAllPostsFromInstaForUserId();
        
        InstagramAuthHelper.getAllMentionsFromInstaForUserId();
        
        InstagramAuthHelper.getPostDetailsByHashTagId('letshyphen');
    }

}