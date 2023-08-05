/* Test Class name : InstagramAuthHelperTest
* created Date     : 29/07/2023
* Created By       : shubham kumar
* Last Modfied By  : shubham kumar
* Descritpion      : This class contains all the api's related to instagram.
*/
global class InstagramAuthHelper {
    
    //Getting the basic details from custom setting
    private static Instagram_Api_Details__c fap = Instagram_Api_Details__c.getInstance();
    
    private static final String CLIENT_ID               = fap.CLIENT_ID__c;
    private static String CLIENT_SECRET                 = fap.CLIENT_SECRET__c;
    private static String REDIRECT_URI                  = fap.REDIRECT_URI__c;
    private static String accessToken                   = fap.accessToken__c;
    private static String basicUrl                      = fap.basicUrl__c;
    private static String businessUserId                = fap.businessUserId__c;
    private static Id caseRecordTypeId                  = Schema.SObjectType.case.getRecordTypeInfosByName().get('Instagram').getRecordTypeId();
    // This method will get the business user id
    /*public InstagramAuthHelper(){

String endpointUrl = basicUrl+'me/accounts?fields=instagram_business_account';
Map<String, String> queryParams = new Map<String, String>();
Map<String, String> headers = new Map<String, String>{'Content-Type' => 'application/json','Authorization' => 'Bearer '+accessToken};
HttpResponse response = DynamicHttpCallout.makeHttpGetCallout(endpointUrl, queryParams, headers);
system.debug('Response==>'+response.getBody());
// Process the response
if (response.getStatusCode() == 200) {
// Request successful, parse the response
Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
instaJSONHandler jsonResponse = instaJSONHandler.parse(response.getBody());

system.debug('responseMap=======>'+jsonResponse.data[0].instagram_business_account.id);
businessUserId = jsonResponse.data[0].instagram_business_account.id;
//return businessUserId;// jsonResponse.data[0].instagram_business_account;
// Handle the response data as per your application's requirements
} else {
// Request failed, handle the error
String errorMessage = 'Error: ' + response.getStatusCode() + ' - ' + response.getStatus();
//return errorMessage;
//System.debug(errorMessage);
}
}*/
    
    @Future(callout=true)
    global static void getAllPostsFromInstaForUserId(){
        List<case> existingCaseList = [Select id,subject,Description,Caption__c,Post_Id__c,(Select Comment__c,Comment_Id__c,Commented_By__c,Post_Url__c,Post_comment_Time__c from Post_Comments__r ) from case where recordTypeId = :caseRecordTypeId];
        List<case> insertedCaseList = new List<case>();
        List<Post_Comments__c> postCommentList                    = new List<Post_Comments__c>();
        List<Post_Comments__c> postCommentListToBeUpdated         = new List<Post_Comments__c>();
        map<String,List<Post_Comments__c>> commentsOnPostByPostId = new map<String,List<Post_Comments__c>>();
        map<String,String> caseIdByPostId                         = new map<String,String>();
        map<String,String> postCommentIdByPostId                  = new map<String,String>();
        List<String> casePostIds                                  = new List<String>();
        for(Case caseRec : existingCaseList){
            commentsOnPostByPostId.put(caseRec.Post_Id__c,caseRec.Post_Comments__r);
            caseIdByPostId.put(caseRec.Post_Id__c,caseRec.Id);
            for(Post_Comments__c pocRec : caseRec.Post_Comments__r){
                postCommentIdByPostId.put(pocRec.Comment_Id__c,pocRec.Id);
            }
        }
        system.debug('commentsOnPostByPostId'+commentsOnPostByPostId);
        String endpointUrl = 'https://graph.facebook.com/v17.0/'+businessUserId+'/media';
        String fieldsParam = 'fields=media_url,comments_count,permalink,caption,media_type,shortcode,timestamp,username,comments{id,like_count,user,media,timestamp,username,replies{text,username,timestamp},text}&limit=50';
        Id caseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('Instagram').getRecordTypeId();
        String fullUrl = endpointUrl + '?' + fieldsParam + '&access_token=' + accessToken;
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(fullUrl);
        request.setMethod('GET');
       
        HttpResponse response = http.send(request);
        System.debug('response.getBody() === > '+response.getBody());
        FacebookApiResponse responseWrapper = (FacebookApiResponse) JSON.deserialize(response.getBody(), FacebookApiResponse.class);
        system.debug('responseWrapper'+responseWrapper);
        for(FacebookApiResponse.DataWrapper postInfo : responseWrapper.data){
            System.debug('postInfo === >'+postInfo);
            if(!commentsOnPostByPostId.keyset().contains(postInfo.Id)){
                Case newCase = new case();
                newCase.Related_to__c = postInfo.username;
                newCase.Brand__c      = 'Hyphen';
                newCase.Origin        = 'Instagram';
                newCase.Post_Id__c = postInfo.id;
                newcase.Created_Time__c = String.valueOf(postInfo.timestamp).removeEnd('+0000');
                newcase.POST_URL__c = postInfo.permalink;
                newcase.recordtypeId = caseRecordTypeId;
                if((postInfo.comments != null)){
                    newcase.Comments_JSON__c = string.valueOf(postInfo.comments.data);
                }
                newcase.Priority = 'High';
                newcase.Type_of_Post__c = 'Post';
                newcase.Subject = 'Post from instagram.Related to '+postInfo.username+'. Created Date-Time : '+newcase.Created_Time__c;
                newcase.Description = postInfo.caption;
                if(!commentsOnPostByPostId.keyset().contains(newCase.Post_Id__c)){
                    insert newcase;
                    insertedCaseList.add(newcase);
                }
                System.debug('postInfo.comments  If == >'+postInfo.comments );
                if((postInfo.comments != null)){
                    if(newcase.Id != null){
                        for(FacebookApiResponse.CommentData postInfoRec : postInfo.comments.data){
                            Post_Comments__c commentRec = new Post_Comments__c();
                            commentRec.Case__c = newcase.Id;
                            commentRec.Comment__c = postInfoRec.text;
                            commentRec.Comment_Id__c = postInfoRec.Id;
                            commentRec.Commented_By__c = postInfoRec.username;
                            commentRec.Post_comment_Time__c = postInfoRec.timestamp;
                            commentRec.Replied_Comments__c = string.valueOf(postInfoRec.replies);
                            commentRec.Post_Url__c	 = postInfo.permalink;
                            postCommentList.add(commentRec);
                        }      
                    }
                }
            }else{
                if(postInfo.comments != null){
                    for(FacebookApiResponse.CommentData postInfoRec : postInfo.comments.data){
                        if(commentsOnPostByPostId.containsKey(postInfo.Id)){
                            List<String> postCommentIds = new List<String>();
                            for(Post_Comments__c poCom :  commentsOnPostByPostId.get(postInfo.Id)){
                                postCommentIds.add(poCom.Comment_Id__c);
                            }
                            if(!postCommentIds.contains(postInfoRec.Id)){
                                Post_Comments__c commentRec = new Post_Comments__c();
                                commentRec.Case__c = caseIdByPostId.get(postInfo.Id);
                                commentRec.Comment__c = postInfoRec.text;
                                commentRec.Comment_Id__c = postInfoRec.Id;
                                commentRec.Commented_By__c = postInfoRec.username;
                                commentRec.Post_comment_Time__c = postInfoRec.timestamp;
                                commentRec.Post_Url__c	 = postInfo.permalink;
                                commentRec.Replied_Comments__c = string.valueOf(postInfoRec.replies);
                                system.debug('replies are'+postInfoRec.replies);
                                postCommentList.add(commentRec);
                            }else{
                                system.debug('replies are'+postInfoRec.replies);
                                Post_Comments__c commentRec = new Post_Comments__c();
                                commentRec.Id = postCommentIdByPostId.get(postInfoRec.Id);
                                commentRec.Replied_Comments__c = string.valueOf(postInfoRec.replies);
                                postCommentListToBeUpdated.add(commentRec);
                            }
                        }
                    }
                }else{
                    system.debug('postInfo.comments'+postInfo.comments);
                }
            }
        }
        system.debug('postCommentList'+postCommentList);
        system.debug('postCommentList'+postCommentList.size());
        system.debug('insertedCaseList'+insertedCaseList.size());
        Database.insert(postCommentList, false);
        Database.update(postCommentListToBeUpdated,false);
    }

    @Future(callout=true)
    global static void getAllMentionsFromInstaForUserId(){
        List<case> existingCaseList = [Select id,subject,Description,Caption__c,Post_Id__c,(Select Comment__c,Comment_Id__c,Commented_By__c,Post_Url__c,Post_comment_Time__c from Post_Comments__r ) from case where recordTypeId = :caseRecordTypeId];
        List<case> insertedCaseList = new List<case>();
        
        List<Post_Comments__c> postCommentList                    = new List<Post_Comments__c>();
        List<Post_Comments__c> postCommentListToBeUpdated         = new List<Post_Comments__c>();
        map<String,List<Post_Comments__c>> commentsOnPostByPostId = new map<String,List<Post_Comments__c>>();
        map<String,String> caseIdByPostId                         = new map<String,String>();
        map<String,String> postCommentIdByPostId                  = new map<String,String>();
        List<String> casePostIds                                  = new List<String>();
        for(Case caseRec : existingCaseList){
            commentsOnPostByPostId.put(caseRec.Post_Id__c,caseRec.Post_Comments__r);
            caseIdByPostId.put(caseRec.Post_Id__c,caseRec.Id);
            for(Post_Comments__c pocRec : caseRec.Post_Comments__r){
                postCommentIdByPostId.put(pocRec.Comment_Id__c,pocRec.Id);
            }
        }
        
        String endpointUrl = 'https://graph.facebook.com/v17.0/'+businessUserId+'/tags';
        String fieldsParam = 'fields=media_url,comments_count,permalink,caption,media_type,timestamp,username,comments{id,like_count,user,media,timestamp,username,replies{text,username,timestamp},text}&limit=50';
        String fullUrl = endpointUrl + '?' + fieldsParam + '&access_token=' + accessToken;
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(fullUrl);
        request.setMethod('GET');
        
        HttpResponse response = http.send(request);
        FacebookApiResponse responseWrapper = (FacebookApiResponse) JSON.deserialize(response.getBody(), FacebookApiResponse.class);
        
        system.debug('responseWrapper'+responseWrapper);
        for(FacebookApiResponse.DataWrapper postInfo : responseWrapper.data){
            if(!commentsOnPostByPostId.keyset().contains(postInfo.Id)){
                Case newCase = new case();
                newCase.Related_to__c = postInfo.username;
                newCase.Brand__c      = 'Hyphen';
                newCase.Origin        = 'Instagram';
                newCase.Post_Id__c = postInfo.id;
                newcase.Created_Time__c = String.valueOf(postInfo.timestamp).removeEnd('+0000');
                newcase.POST_URL__c = postInfo.permalink;
                newcase.Mention__c = postInfo.username;
                if((postInfo.comments != null)){
                    newcase.Comments_JSON__c = string.valueOf(postInfo.comments.data);
                }
                newcase.recordtypeId = caseRecordTypeId;
                newcase.Priority = 'High';
                newcase.Type_of_Post__c = 'Tags/Mentions';
                newcase.Subject = 'Mention Post from instagram.Related to '+postInfo.username+'. Created Date-Time : '+newcase.Created_Time__c;
                newcase.Description = postInfo.caption;
                if(!commentsOnPostByPostId.keyset().contains(newCase.Post_Id__c)){
                    insert newcase;
                    insertedCaseList.add(newcase);
                }
                if((postInfo.comments != null)){
                    if(newcase.Id != null){
                        for(FacebookApiResponse.CommentData postInfoRec : postInfo.comments.data){
                            Post_Comments__c commentRec = new Post_Comments__c();
                            commentRec.Case__c = newcase.Id;
                            commentRec.Comment__c = postInfoRec.text;
                            commentRec.Comment_Id__c = postInfoRec.Id;
                            commentRec.Commented_By__c = postInfoRec.username;
                            commentRec.Post_comment_Time__c = postInfoRec.timestamp;
                            commentRec.Replied_Comments__c = string.valueOf(postInfoRec.replies);
                            commentRec.Post_Url__c	 = postInfo.permalink;
                            postCommentList.add(commentRec);
                        }    
                    }
                }
            }else{
                if(postInfo.comments != null){
                    for(FacebookApiResponse.CommentData postInfoRec : postInfo.comments.data){
                        if(commentsOnPostByPostId.containsKey(postInfo.Id)){
                            List<String> postCommentIds = new List<String>();
                            for(Post_Comments__c poCom :  commentsOnPostByPostId.get(postInfo.Id)){
                                postCommentIds.add(poCom.Comment_Id__c);
                            }
                            if(!postCommentIds.contains(postInfoRec.Id)){
                                Post_Comments__c commentRec = new Post_Comments__c();
                                commentRec.Case__c = caseIdByPostId.get(postInfo.Id);
                                commentRec.Comment__c = postInfoRec.text;
                                commentRec.Comment_Id__c = postInfoRec.Id;
                                commentRec.Commented_By__c = postInfoRec.username;
                                commentRec.Post_comment_Time__c = postInfoRec.timestamp;
                                commentRec.Post_Url__c	 = postInfo.permalink;
                                commentRec.Replied_Comments__c = string.valueOf(postInfoRec.replies);
                                system.debug('replies are'+postInfoRec.replies);
                                postCommentList.add(commentRec);
                            }else{
                                system.debug('replies are'+postInfoRec.replies);
                                Post_Comments__c commentRec = new Post_Comments__c();
                                commentRec.Id = postCommentIdByPostId.get(postInfoRec.Id);
                                commentRec.Replied_Comments__c = string.valueOf(postInfoRec.replies);
                                postCommentListToBeUpdated.add(commentRec);
                            }
                        }
                    }
                }else{
                    system.debug('postInfo.comments'+postInfo.comments);
                }
            }
        }
        system.debug('postCommentList'+postCommentList);
        system.debug('insertedCaseList'+insertedCaseList.size());
        Database.insert(postCommentList, false);
        system.debug('insertedCaseList==>'+insertedCaseList);
        Database.update(postCommentListToBeUpdated,false);
    }   
    
    @Future(callout=true)
    global static void getPostDetailsByHashTagId(String hashtagName){
        List<Case> caseList = new List<Case>();
        String hashTagId = getHashtagIdFromInsta(hashtagName);
        system.debug('hashTagId'+hashTagId);
        
        List<Post_Comments__c> postCommentList                    = new List<Post_Comments__c>();
        List<Post_Comments__c> postCommentListToBeUpdated         = new List<Post_Comments__c>();
        map<String,List<Post_Comments__c>> commentsOnPostByPostId = new map<String,List<Post_Comments__c>>();
        map<String,String> caseIdByPostId                         = new map<String,String>();
        map<String,String> postCommentIdByPostId                  = new map<String,String>();
        List<Case> existingCaseList                               = [Select id,subject,Description,Caption__c,Post_Id__c,(Select Comment__c,Comment_Id__c,Commented_By__c,Post_Url__c,Post_comment_Time__c from Post_Comments__r ) from case];
        List<String> casePostIds                                  = new List<String>();
        for(Case caseRec : existingCaseList){
            commentsOnPostByPostId.put(caseRec.Post_Id__c,caseRec.Post_Comments__r);
            caseIdByPostId.put(caseRec.Post_Id__c,caseRec.Id);
            for(Post_Comments__c pocRec : caseRec.Post_Comments__r){
                postCommentIdByPostId.put(pocRec.Comment_Id__c,pocRec.Id);
            }
        }
        String endpointUrl = basicUrl+hashTagId+'/recent_media?fields=media_url,media_type,caption,permalink,timestamp&user_id='+businessUserId;
        Map<String, String> queryParams = new Map<String, String>();
        Map<String, String> headers = new Map<String, String>{'Content-Type' => 'application/json','Authorization' => 'Bearer '+accessToken};
            HttpResponse response = DynamicHttpCallout.makeHttpGetCallout(endpointUrl, queryParams, headers);
        system.debug('Response==>'+response.getBody());
        
        if (response.getStatusCode() == 200) {
            instaJSONHandler jsonResponse = instaJSONHandler.parse(response.getBody());
            for(instaJSONHandler.cls_data postInfo : jsonResponse.data){
                if(!commentsOnPostByPostId.keyset().contains(postInfo.Id)){
                    Case newCase = new case();
                    newCase.Related_to__c = postInfo.username;
                    newCase.Brand__c      = 'Hyphen';
                    newCase.Origin        = 'Instagram';
                    newCase.Post_Id__c = postInfo.id;
                    newcase.Created_Time__c = String.valueOf(postInfo.timestamp).removeEnd('+0000');
                    newcase.POST_URL__c = postInfo.permalink;
                    newcase.Comments_JSON__c = string.valueOf(postInfo.repliesOnPost);
                    newcase.OwnerId =userinfo.getuserId();
                    newcase.Priority = 'High';
                    newcase.Type_of_Post__c = 'HashTags';
                    newcase.RecordTypeId = caseRecordTypeId;
                    newcase.Subject = 'Hash Tag Post from instagram.Related to #'+hashtagName+'. Created Date-Time : '+newcase.Created_Time__c;
                    newcase.Description = postInfo.caption;
                    newcase.HashTag__c = hashtagName;
                    newcase.Hash_Tag_Id__c = hashTagId;
                    if(!commentsOnPostByPostId.keyset().contains(newCase.Post_Id__c)){
                        caseList.add(newCase);
                    }
                }else{
                    
                }
            }
            if(caseList.size() > 0){
                 Database.insert(caseList, false);
            }
        } else {
            String errorMessage = 'Error: ' + response.getStatusCode() + ' - ' + response.getStatus();
            System.debug(errorMessage);
        }
    }
    
    // This method will get the id corresponding to the hashtag
    global static String getHashtagIdFromInsta(String hashtagName){
        system.debug('businessUserId---->>'+businessUserId + 'hashtagName--->>' +hashtagName );
        //InstagramAuthHelper instaAuth = new InstagramAuthHelper();
        String endpointUrl = basicUrl+'ig_hashtag_search?user_id='+businessUserId+'&q='+hashtagName;
        Map<String, String> queryParams = new Map<String, String>();
        Map<String, String> headers = new Map<String, String>{'Content-Type' => 'application/json','Authorization' => 'Bearer '+accessToken};
            HttpResponse response = DynamicHttpCallout.makeHttpGetCallout(endpointUrl, queryParams, headers);
        system.debug('Response==>'+response.getBody());
        // Process the response
        if (response.getStatusCode() == 200) {
            //Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            instaJSONHandler jsonResponse = instaJSONHandler.parse(response.getBody());
            string hashtagId = jsonResponse.data[0].Id;
            system.debug('HashtagId=======>'+hashtagId);
            return hashtagId;
        } else {
            String errorMessage = 'Error: ' + response.getStatusCode() + ' - ' + response.getStatus();
            return errorMessage;
        }
    }
   
    
    //Pass this method the Comment id and the media id will be fetched.
    global static void getAllDetailsOfComments(String commentId){
        List<Case> caseList = new List<Case>();
        String endpointUrl = basicUrl+commentId+'?fields=replies{text,username,timestamp,user},text,user,timestamp,username,media';
        Map<String, String> queryParams = new Map<String, String>();
        Map<String, String> headers = new Map<String, String>{'Content-Type' => 'application/json','Authorization' => 'Bearer '+accessToken};
            HttpResponse response = DynamicHttpCallout.makeHttpGetCallout(endpointUrl, queryParams, headers);
        system.debug('Response==>'+response.getBody());
        // Process the response
        if (response.getStatusCode() == 200) {
            InstaCommentWrapper jsonResponse = InstaCommentWrapper.parse(response.getBody());
            //System.debug('The Media id of this comment is==>'+jsonResponse.media.id );
            if(!test.isRunningTest()){
                getAllDetailsOfMedia(jsonResponse.media.id);    
            }
        }else{
            String errorMessage = 'Error: ' + response.getStatusCode() + ' - ' + response.getStatus();
            System.debug(errorMessage);
        }
    }
    
    //Pass this method the media id and all the details related to post will be fetched.
    global static void getAllDetailsOfMedia(String mediaId){
        
        List<Post_Comments__c> postCommentList = new List<Post_Comments__c>();
        List<Post_Comments__c> postCommentListToBeUpdated = new List<Post_Comments__c>();
        map<String,List<Post_Comments__c>> commentsOnPostByPostId = new map<String,List<Post_Comments__c>>();
        map<String,String> caseIdByPostId = new map<String,String>();
        map<String,String> postCommentIdByPostId = new map<String,String>();
        List<Case> existingCaseList = [Select id,subject,Description,Caption__c,Post_Id__c,(Select Comment__c,Comment_Id__c,Commented_By__c,Post_Url__c,Post_comment_Time__c from Post_Comments__r ) from case];
        
        List<String> casePostIds = new List<String>();
        for(Case caseRec : existingCaseList){
            commentsOnPostByPostId.put(caseRec.Post_Id__c,caseRec.Post_Comments__r);
            caseIdByPostId.put(caseRec.Post_Id__c,caseRec.Id);
            for(Post_Comments__c pocRec : caseRec.Post_Comments__r){
                postCommentIdByPostId.put(pocRec.Comment_Id__c,pocRec.Id);
            }
        }
        
        String endpointUrl = basicUrl+mediaId+'?fields=media_url,comments_count,permalink,caption,media_type,shortcode,timestamp,username,comments{id,like_count,user,media,timestamp,username,replies{text,username,timestamp},text}';
        Map<String, String> queryParams = new Map<String, String>();
        Map<String, String> headers = new Map<String, String>{'Content-Type' => 'application/json','Authorization' => 'Bearer '+accessToken};
            HttpResponse response = DynamicHttpCallout.makeHttpGetCallout(endpointUrl, queryParams, headers);
        InstagramMediaResponseWrapper postInfo = (InstagramMediaResponseWrapper) JSON.deserialize(response.getBody(), InstagramMediaResponseWrapper.class);
        
        system.debug('responseWrapper'+postInfo);
        //for(InstagramMediaResponseWrapper.DataWrapper postInfo : responseWrapper.data){
        system.debug('responseWrapper'+postInfo.Id);
        if(!commentsOnPostByPostId.keyset().contains(postInfo.Id)){
            Case newCase = new case();
            newCase.Related_to__c = postInfo.username;
            newCase.Origin = 'Instagram';
            newCase.Post_Id__c = postInfo.id;
            newcase.RecordTypeId = caseRecordTypeId;
            newcase.Created_Time__c = String.valueOf(postInfo.timestamp);
            newcase.POST_URL__c = postInfo.permalink;
            if((postInfo.comments != null)){
                newcase.Comments_JSON__c = string.valueOf(postInfo.comments.data);
            }
            newcase.OwnerId = userinfo.getuserId();
            newcase.Priority = 'High';
            newcase.Type_of_Post__c = 'Post';
            newcase.Subject = 'This case is coming from Instagram';
            newcase.Description = postInfo.caption;
            insert newcase;
            system.debug('postInfo.comments'+postInfo.comments);
            if((postInfo.comments != null)){
                for(InstagramMediaResponseWrapper.cls_data postInfoRec : postInfo.comments.data){
                    Post_Comments__c commentRec = new Post_Comments__c();
                    commentRec.Case__c = newcase.Id;
                    commentRec.Comment__c = postInfoRec.text;
                    commentRec.Comment_Id__c = postInfoRec.id;
                    commentRec.Commented_By__c = postInfoRec.username;
                    commentRec.Post_comment_Time__c = postInfoRec.timestamp;
                    commentRec.Replied_Comments__c = string.valueOf(postInfoRec.replies);
                    commentRec.Post_Url__c	 = postInfo.permalink;
                    system.debug('replies are'+postInfoRec.replies);
                    postCommentList.add(commentRec);
                }    
            }
        }else{
            if(postInfo.comments != null){
                for(InstagramMediaResponseWrapper.cls_data postInfoRec : postInfo.comments.data){
                    if(commentsOnPostByPostId.containsKey(postInfo.Id)){
                        List<String> postCommentIds = new List<String>();
                        for(Post_Comments__c poCom :  commentsOnPostByPostId.get(postInfo.Id)){
                            postCommentIds.add(poCom.Comment_Id__c);
                        }
                        if(!postCommentIds.contains(postInfoRec.id)){
                            Post_Comments__c commentRec = new Post_Comments__c();
                            commentRec.Case__c = caseIdByPostId.get(postInfo.Id);
                            commentRec.Comment__c = postInfoRec.text;
                            commentRec.Comment_Id__c = postInfoRec.id;
                            commentRec.Commented_By__c = postInfoRec.username;
                            commentRec.Post_comment_Time__c = postInfoRec.timestamp;
                            commentRec.Post_Url__c	 = postInfo.permalink;
                            commentRec.Replied_Comments__c = string.valueOf(postInfoRec.replies);
                            system.debug('replies are'+postInfoRec.replies);
                            postCommentList.add(commentRec);
                        }else{
                            system.debug('replies are'+postInfoRec.replies);
                            Post_Comments__c commentRec = new Post_Comments__c();
                            commentRec.Id = postCommentIdByPostId.get(postInfoRec.id);
                            commentRec.Replied_Comments__c = string.valueOf(postInfoRec.replies);
                            postCommentListToBeUpdated.add(commentRec);
                        }
                    }
                }
            }else{
                system.debug('postInfo.comments'+postInfo.comments);
            }
        }
        
        insert postCommentList;
        update postCommentListToBeUpdated;
    }
    
    global static void getAllPostsFromInstaForUserIdDummy(){
        List<Post_Comments__c> postCommentList                    = new List<Post_Comments__c>();
        List<Post_Comments__c> postCommentListToBeUpdated         = new List<Post_Comments__c>();
        map<String,List<Post_Comments__c>> commentsOnPostByPostId = new map<String,List<Post_Comments__c>>();
        map<String,String> caseIdByPostId                         = new map<String,String>();
        map<String,String> postCommentIdByPostId                  = new map<String,String>();
        List<Case> existingCaseList                               = [Select id,subject,Description,Caption__c,Post_Id__c,(Select Comment__c,Comment_Id__c,Commented_By__c,Post_Url__c,Post_comment_Time__c from Post_Comments__r ) from case];
        List<String> casePostIds                                  = new List<String>();
        for(Case caseRec : existingCaseList){
            commentsOnPostByPostId.put(caseRec.Post_Id__c,caseRec.Post_Comments__r);
            caseIdByPostId.put(caseRec.Post_Id__c,caseRec.Id);
            for(Post_Comments__c pocRec : caseRec.Post_Comments__r){
                postCommentIdByPostId.put(pocRec.Comment_Id__c,pocRec.Id);
            }
        }
        system.debug('commentsOnPostByPostId'+commentsOnPostByPostId);
        //InstagramAuthHelper instaAuth = new InstagramAuthHelper();
        String endpointUrl = 'https://graph.facebook.com/v17.0/17841455799037293/media';
        String fieldsParam = 'fields=media_url,comments_count,permalink,caption,media_type,shortcode,timestamp,username,comments{id,like_count,user,media,timestamp,username,replies{text,username,timestamp},text}?limit=75';
        
        String fullUrl = endpointUrl + '?' + fieldsParam + '&access_token=' + accessToken;
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(fullUrl);
        request.setMethod('GET');
        
        HttpResponse response = http.send(request);
        FacebookApiResponse responseWrapper = (FacebookApiResponse) JSON.deserialize(response.getBody(), FacebookApiResponse.class);
        
        system.debug('responseWrapper'+responseWrapper);
        for(FacebookApiResponse.DataWrapper postInfo : responseWrapper.data){
            if(!commentsOnPostByPostId.keyset().contains(postInfo.Id)){
                Case newCase = new case();
                newCase.Related_to__c = postInfo.username;
                newCase.Origin = 'Instagram';
                newCase.Post_Id__c = postInfo.id;
                newcase.Created_Time__c = String.valueOf(postInfo.timestamp);
                newcase.POST_URL__c = postInfo.permalink;
                if((postInfo.comments != null)){
                    newcase.Comments_JSON__c = string.valueOf(postInfo.comments.data);
                }
                
                newcase.OwnerId = userinfo.getuserId();
                newcase.Priority = 'High';
                newcase.Type = 'Post';
               newcase.RecordTypeId = caseRecordTypeId;
                newcase.Subject = 'This case is coming from Instagram';
                newcase.Description = postInfo.caption;
                insert newcase;
                if((postInfo.comments != null)){
                    for(FacebookApiResponse.CommentData postInfoRec : postInfo.comments.data){
                        Post_Comments__c commentRec = new Post_Comments__c();
                        commentRec.Case__c = newcase.Id;
                        commentRec.Comment__c = postInfoRec.text;
                        commentRec.Comment_Id__c = postInfoRec.Id;
                        commentRec.Commented_By__c = postInfoRec.username;
                        commentRec.Post_comment_Time__c = postInfoRec.timestamp;
                        commentRec.Replied_Comments__c = string.valueOf(postInfoRec.replies);
                        commentRec.Post_Url__c	 = postInfo.permalink;
                        postCommentList.add(commentRec);
                    }    
                }
            }
        }
        insert postCommentList;
        update postCommentListToBeUpdated;
    }
    
}