
@RestResource(urlMapping='/mcaffeine_instaGramAPI/V2/*')
global without sharing class mcaffeine_instaWebhookApi {
    private static Id caseRecordTypeId                  = Schema.SObjectType.case.getRecordTypeInfosByName().get('Instagram').getRecordTypeId();
    static String WEB_TOKEN = 'EAAKJz6xiZC6gBAEQ7Ub3pazJxFazWFUXEkbp2Hlg0W0EmblRJVhrLLr1WUwL81hqfSxRXJJ8otiGZAyQ66onZBoRFTOqdjZBKioZA5iy55N0rxyZBulbw1XVgu6ktZA0b0vs6uZAFG7SodcyHayN2id8WAktoJejpdCcaTLF9NwV6FkTvizWzYBZC';
    @HttpPost
    global static void webhookListener(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String requestBody = req.requestBody.toString();
        System.debug('--- WEBHOOK requestBody' +requestBody);
        try{
            if(requestBody != null) {
                requestBody = requestBody.replace('"object"','"object_c"');
                requestBody = requestBody.replace('"time"','"time_c"');
                requestBody = requestBody.replace('"from"','"from_c"');
                
                Map<String,Object> responseMap = (Map<String,Object>) JSON.deserializeUntyped(requestBody);
                system.debug('responseMap--->'+responseMap);
                if(responseMap != null && responseMap.containsKey('entry')) {
                    List<Object> changesList = (List<Object>)((Map<String, Object>)(((List<Object>)responseMap.get('entry'))[0])).get('changes');
                    if(changesList != null && !changesList.isEmpty() && ((Map<String,Object>)changesList[0]).containsKey('field')) {
                        Map<String,Object> change = (Map<String,Object>)changesList[0];
                        if(change.get('field') == 'comments') {
                            processNewComment(requestBody);
                            system.debug('for new post');
                            newPost(requestBody);
                            system.debug('processNewComment');
                        }else if(change.get('field') == 'mentions') {
                           system.debug('processNewMention(change);');
                            newMentionComment(requestBody);
                           

                        }else if(change.get('field') == 'messages') {
                            system.debug('processNewMessages(change);');
                            processNewMessages(change);
                        }
                    }
                }
            }
        }catch(Exception e) {
            System.debug('--- Exception'+ e.getMessage());
        }
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new ResponseWrapper('Received', WEB_TOKEN)));
    }
    
    private static void processNewComment(String requestBody) {
        system.debug('postNotification Coming here');
        List<Case> postCaseList = new List<Case>();
        InstaNotificationWrapper postNotification = (InstaNotificationWrapper) JSON.deserialize(requestBody, InstaNotificationWrapper.class);
        if(postNotification != null) {
            Integer timeStamp;
            String entryId , message;
            for(InstaNotificationWrapper.cls_entry entry: postNotification.entry) {
                timeStamp = entry.time_c; //TODO convert this to readable format
                for(InstaNotificationWrapper.cls_changes change: entry.changes) {
                    system.debug('post_id==>'+change.value);
                    //InstagramAuthHelper.getAllDetailsOfComments(change.value.id);
                    Case postCase = new Case(Origin = 'Instagram',Created_Time__c = getTimeStamp(timeStamp), Subject= 'New Comments that you are tagged in.', Post_Id__c = change.value.id, Description = change.value.text,Type='Comments',Mention__c='utilitarian_labs');
                    postCaseList.add(postCase);
                }
            }
            if(!postCaseList.isEmpty()) {
                System.debug('--- creating case: '+postCaseList);
                try{
                    Database.insert(postCaseList, false);
                }catch(DMLException e){
                    System.debug('--- e.Message:'+e.getMessage());
                }
            }
        }
    }
    
    private static void processNewMention(Map<String,Object> responseMap) {
        system.debug('responseMap--in method,'+responseMap);
        Map<String, Object> fbMentionObject = (Map<String, Object>) responseMap.get('value');
        system.debug('fbMentionObject-->'+fbMentionObject);
        system.debug('fbMentionObject-------->'+fbMentionObject.get('comment_id'));
        system.debug('fbMentionObject-------->'+fbMentionObject.get('media_id'));
        
        if(fbMentionObject != null) {
            system.debug('fbMentionObject--->'+fbMentionObject);
           
            //InstagramAuthHelper.getAllDetailsOfMedia(String.valueOf(fbMentionObject.get('media_id')));
        }
    }
    
    private static void processNewMessages(Map<String,Object> responseMap) {
        Map<String, Object> fbMentionObject = (Map<String, Object>) responseMap.get('value');
        system.debug('fbMentionObject-->'+fbMentionObject);
        
        if(fbMentionObject != null) {
            system.debug('fbMentionObject--->'+fbMentionObject);
            //InstagramAuthHelper.getAllDetailsOfMedia(String.valueOf(fbMentionObject.get('media_id')));
        }
    }
    public class ResponseWrapper {
        String message;
        String token;
        public ResponseWrapper(String message, String token) { 
            this.message = message;
            this.token = token;
        }
    }
    
    @HttpGet
    global static Integer verify() {
        System.debug('--- params '+RestContext.request.params);
        String token = RestContext.request.params.get('hub.verify_token');
        Integer challenge = Integer.valueOf(RestContext.request.params.get('hub.challenge'));
        if(token == WEB_TOKEN) {
            return challenge;
        }
        return null;
    }
    
    global static string getTimeStamp(integer timeValue) {
        // Unix timestamp to be converted
        Integer unixTimestamp = timeValue;
        
        // Convert Unix timestamp to Datetime
        Datetime dateTimeValue = Datetime.newInstance(unixTimestamp * 1000L);
        
        // Convert the Datetime to a formatted string if needed
        String formattedDateTime = dateTimeValue.format('yyyy-MM-dd HH:mm:ss');
        System.debug('Converted Datetime: ' + formattedDateTime);
        return  formattedDateTime;
    }


    private static void testNewMention(){
       
    }

    private static void newMentionComment(String requestBody){

        List<case> insertedCaseList = new List<case>();
        List<Post_Comments__c> postCommentList                    = new List<Post_Comments__c>();
        List<Post_Comments__c> postCommentListToBeUpdated         = new List<Post_Comments__c>();
        List<Id> caseIdsToBeUpdated                               = new List<Id>();
        map<String,List<Post_Comments__c>> commentsOnPostByPostId = new map<String,List<Post_Comments__c>>();
        map<String,String> caseIdByPostId                         = new map<String,String>();
        map<String,String> postCommentIdByPostId                  = new map<String,String>();
        map<String,String> caseIdByPostCommentId                  = new map<String,String>();
        List<String> casePostIds                                  = new List<String>();
        List<Post_Comments__c> newpostCommentList                           = new List<Post_Comments__c>();
        List<Post_Comments__c> newpostCommentForExistingPosts               = new List<Post_Comments__c>();
        List<Post_Comments__c> postCommentsForExistingPostsToBeInserted     = new List<Post_Comments__c>();
        
        List<case> existingCaseList = [Select id,subject,Description,Caption__c,Post_Id__c from case where recordTypeId = :caseRecordTypeId and Origin = 'Instagram'AND Brand__c='Hyphen'];
       
        List<Post_Comments__c> postCommentDataList = [Select Comment__c,Comment_Id__c,case__c,Case__r.Post_Id__c,Commented_By__c,Post_Url__c,Post_comment_Time__c from Post_Comments__c where case__c IN :existingCaseList Limit 49000 ]; 
        
        for(Post_Comments__c postCommRec : postCommentDataList){
            postCommentIdByPostId.put(postCommRec.Comment_Id__c,postCommRec.Id);
            caseIdByPostCommentId.put(postCommRec.Comment_Id__c,postCommRec.Case__c);
            if(commentsOnPostByPostId.containsKey(postCommRec.Case__c)){
                commentsOnPostByPostId.get(postCommRec.Case__r.Post_Id__c).add(postCommRec);
            }else{
                list<Post_Comments__c> postCommNewList = new list<Post_Comments__c>();
                postCommNewList.add(postCommRec);
                commentsOnPostByPostId.put(postCommRec.Case__r.Post_Id__c,postCommNewList);
            }
        }
        
        for(Case caseRec : existingCaseList){
            list<Post_Comments__c> postCommNewList = new list<Post_Comments__c>();
            caseIdByPostId.put(caseRec.Post_Id__c,caseRec.Id);
            if(!commentsOnPostByPostId.keyset().contains(caseRec.Post_Id__c)){
                commentsOnPostByPostId.put(caseRec.Post_Id__c,postCommNewList);
            }
        }
        
        system.debug('requestBody--'+requestBody);

        FacebookApiResponse responseWrapper = (FacebookApiResponse) JSON.deserialize(requestBody, FacebookApiResponse.class);

        system.debug('The size of the response is---------->'+responseWrapper.data.size());
        if( responseWrapper.data.size() == 50){
            Instagram_Api_Details__c instaSetting = Instagram_Api_Details__c.getOrgDefaults();
            instaSetting.Id = instaSetting.Id;
            instaSetting.next_Pagination_Mention_Token__c = responseWrapper.paging.cursors.after;
            update instaSetting;
        }
        
        system.debug('requestBody--'+requestBody);
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
                    upsert newcase Post_Id__c;
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
                            if(commentsOnPostByPostId.get(postInfo.Id).size() > 0){
                                for(Post_Comments__c poCom :  commentsOnPostByPostId.get(postInfo.Id)){
                                    postCommentIds.add(poCom.Comment_Id__c);
                                }
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
                                postCommentList.add(commentRec);
                            }else{
                                Post_Comments__c commentRec = new Post_Comments__c();
                                commentRec.Id = postCommentIdByPostId.get(postInfoRec.Id);
                                commentRec.Replied_Comments__c = string.valueOf(postInfoRec.replies);
                                postCommentListToBeUpdated.add(commentRec);
                            }
                        }
                    }
                }else{
                }
            }
        }
        system.debug('insertedCaseList'+insertedCaseList.size());
        if(postCommentList.size() > 0){
            upsert postCommentList Comment_Id__c;
        }
        if(postCommentListToBeUpdated.size() > 0){
            Database.update(postCommentListToBeUpdated,false);
        }
        

    }


    private static void newPost(string response){


        
        List<case> insertedCaseList = new List<case>();
        List<Post_Comments__c> postCommentList                    = new List<Post_Comments__c>();
        List<Post_Comments__c> postCommentListToBeUpdated         = new List<Post_Comments__c>();
        List<Id> caseIdsToBeUpdated                               = new List<Id>();
        map<String,List<Post_Comments__c>> commentsOnPostByPostId = new map<String,List<Post_Comments__c>>();
        map<String,String> caseIdByPostId                         = new map<String,String>();
        map<String,String> postCommentIdByPostId                  = new map<String,String>();
        map<String,String> caseIdByPostCommentId                  = new map<String,String>();
        List<String> casePostIds                                  = new List<String>();
        List<Post_Comments__c> newpostCommentList                           = new List<Post_Comments__c>();
        List<Post_Comments__c> newpostCommentForExistingPosts               = new List<Post_Comments__c>();
        List<Post_Comments__c> postCommentsForExistingPostsToBeInserted     = new List<Post_Comments__c>();

        List<case> existingCaseList = [Select id,subject,Description,Caption__c,Post_Id__c from case where recordTypeId = :caseRecordTypeId and Origin = 'Instagram' AND Brand__c='Hyphen'];
        List<Post_Comments__c> postCommentDataList = new List<Post_Comments__c>();
        postCommentDataList  = [Select Comment__c,Comment_Id__c,case__c,Case__r.Post_Id__c,Commented_By__c,Post_Url__c,Post_comment_Time__c from Post_Comments__c where case__c IN :existingCaseList ]; 
        
        for(Post_Comments__c postCommRec : postCommentDataList){
            postCommentIdByPostId.put(postCommRec.Comment_Id__c,postCommRec.Id);
            caseIdByPostCommentId.put(postCommRec.Comment_Id__c,postCommRec.Case__c);
            if(commentsOnPostByPostId.containsKey(postCommRec.Case__c)){
                commentsOnPostByPostId.get(postCommRec.Case__r.Post_Id__c).add(postCommRec);
            }else{
                list<Post_Comments__c> postCommNewList = new list<Post_Comments__c>();
                postCommNewList.add(postCommRec);
                commentsOnPostByPostId.put(postCommRec.Case__r.Post_Id__c,postCommNewList);
            }
        }
        
        for(Case caseRec : existingCaseList){
            list<Post_Comments__c> postCommNewList = new list<Post_Comments__c>();
            caseIdByPostId.put(caseRec.Post_Id__c,caseRec.Id);
            if(!commentsOnPostByPostId.keyset().contains(caseRec.Post_Id__c)){
                commentsOnPostByPostId.put(caseRec.Post_Id__c,postCommNewList);
            }
        }

        FacebookApiResponse responseWrapper = (FacebookApiResponse) JSON.deserialize(response, FacebookApiResponse.class);
        system.debug('responseWrapper'+responseWrapper);
        system.debug('responseWrapper'+responseWrapper.data.size());
        if( responseWrapper.data.size() == 50 ){
            system.debug('50 cases are there lets proceed'+responseWrapper.paging.cursors.after);
            Instagram_Api_Details__c instaSetting = Instagram_Api_Details__c.getOrgDefaults();
            instaSetting.Id = instaSetting.Id;
            instaSetting.next_Pagination_Post_Token__c = responseWrapper.paging.cursors.after;
            update instaSetting;
        }
        for(FacebookApiResponse.DataWrapper postInfo : responseWrapper.data){
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
                    upsert newcase Post_Id__c;
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
                            newpostCommentList.add(commentRec);
                        }      
                    }
                }
            }else{
                if(postInfo.comments != null){
                    for(FacebookApiResponse.CommentData postInfoRec : postInfo.comments.data){
                        if(commentsOnPostByPostId.containsKey(postInfo.Id)){
                            List<String> postCommentIds = new List<String>();
                            if(commentsOnPostByPostId.get(postInfo.Id).size() > 0){
                                for(Post_Comments__c poCom :  commentsOnPostByPostId.get(postInfo.Id)){
                                    postCommentIds.add(poCom.Comment_Id__c);
                                }    
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
                                newpostCommentForExistingPosts.add(commentRec);
                            }else{
                                //This will come here comments have to be updated..
                                Post_Comments__c commentRec = new Post_Comments__c();
                                commentRec.Id = postCommentIdByPostId.get(postInfoRec.Id);
                                if(caseIdByPostCommentId.ContainsKey(postInfoRec.Id)){
                                    caseIdsToBeUpdated.add(caseIdByPostCommentId.get(postInfoRec.Id));    
                                }
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
        
        for(Post_Comments__c postCommRec : newpostCommentForExistingPosts){
            if(postCommentIdByPostId.keySet().contains(postCommRec.Comment_Id__c)){
                
            }else{
                postCommentsForExistingPostsToBeInserted.add(postCommRec);
            }
        }
        
        
        system.debug('These cases have new comments do have a look'+insertedCaseList.size());
        //This is for new Posts that are inserted :
        if(postCommentsForExistingPostsToBeInserted.size() > 0){
            upsert postCommentsForExistingPostsToBeInserted Comment_Id__c;
            //Database.insert(postCommentsForExistingPostsToBeInserted, false);    
        }
        
        if(postCommentListToBeUpdated.size() > 0){
            Database.update(postCommentListToBeUpdated,false);
        }
        
    }
    
}