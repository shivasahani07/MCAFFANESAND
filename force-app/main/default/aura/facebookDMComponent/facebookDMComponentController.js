({
    doInit : function(component, event, helper) {
        debugger;
        var recId = component.get("v.recordId");
        var action = component.get("c.getCaseDetails");

        action.setParams({
            recordId: recId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var serverresponse = response.getReturnValue();
            if (state === 'SUCCESS' && serverresponse) {
                component.set("v.tweetDescription",serverresponse.description);
                component.set("v.recepientid", serverresponse.recepientId);
                component.set("v.brand", serverresponse.brand);
                /* component.set("v.filteredCommentList", serverresponse); */
                component.set("v.relatedCommentList",serverresponse.commentWrapperList);
                component.set("v.rawList",serverresponse.commentWrapperList);
                //temResultSize=serverresponse.commentWrapperList.length;
                /* component.set("v.totalPages", Math.ceil(response.getReturnValue().length / component.get("v.pageSize"))); */
                 var lengthVar = component.get("v.relatedCommentList").length;
                console.log('length///'+lengthVar);
                component.set("v.totalRecords",lengthVar); 
                //---------------------------------------------------------------------------
                //number of records in each page---------------------------------------------
                var perPage = component.get("v.perPageSize");
                //---------------------------------------------------------------------------
                var values=[];
                console.log('perPage///'+perPage);
                //If total number of records are more than 5 or equals 5-----------------------
                if(lengthVar >= perPage){
                    for(var i=0;i<perPage;i++){
                        values.push(serverresponse.commentWrapperList[i]);
                    }
                }//--------------------------------------------------------------------------
                else{//If total number of recommentWrapperListords are lesser than 5--------------------------
                    for(var i=0;i<lengthVar;i++){
                        values.push(serverresponse.commentWrapperList[i]);
                    }
                }//--------------------------------------------------------------------------
                console.log('values///'+values);
                component.set("v.PaginationList",values);
                component.set("v.startValue",0);
                //if there are only 5 records or lesser than that in total-------------------
                if(lengthVar <= (component.get("v.startValue")+perPage)){
                    component.set("v.isLastPage",true);
                }
                component.set("v.endValue",component.get("v.startValue")+perPage-1);
            }else{
                
            }
        });
        $A.enqueueAction(action); 
    },

    handleSearch: function(component, event, helper) {
        debugger;
        var searchKeyword = event.currentTarget.value;
        //var searchKeyword = component.get("v.searchKeyword");
        if(searchKeyword && searchKeyword.length < 2)
            return;

        var data = component.get("v.rawList");
        searchKeyword = searchKeyword.toLowerCase();
        var filteredData = data.filter(item => {
            debugger;
            const { comment, CommentedBy } = item;
            const lowerCaseName = comment ? comment.toLowerCase() : '';
            const lowerCaseBy = CommentedBy ? CommentedBy.toLowerCase() : '';
            // Debugging statement
            //console.log("Item Name:", lowerCaseName);
            return lowerCaseName.includes(searchKeyword) || lowerCaseBy.includes(searchKeyword);
        });
        //var filteredData = data.filter(item => item.comment.toLowerCase().includes(searchKeyword.toLowerCase()));
        component.set("v.relatedCommentList", filteredData);
    },
    
    /* changePage: function(component, event, helper) {
        var page = event.currentTarget.dataset.page;
        component.set("v.currentPage", page);
    }, */

    openModel : function(component, event, helper) {
        debugger;
        var comment       = event.getSource().get('v.value');
        var commentedBy   = event.getSource().get('v.name');
        var commentId     = event.getSource().get('v.title');
        var parentId      = event.getSource().get('v.variant');
        
        component.set("v.parentCommentId",parentId);
        component.set("v.selectedCommentId",commentId);
        component.set("v.selectedCommentValue",comment);
        component.set("v.selectedCommentRepliedBy",commentedBy);
        component.set("v.isModalOpen",true);
    },
    closeModel : function(component, event, helper) {
        debugger;
        component.set("v.isModalOpen",false);
        component.set("v.showReplies",false);
    },
    postComment : function(component, event, helper) {
        debugger;
        component.set("v.spinner",true);
        var commentId      = component.get("v.selectedCommentId");
        var recId      = component.get("v.recepientid");
        var commentMessage = component.get("v.replyMessage");
        var parentSFID     = component.get("v.parentCommentId");
        var brand          = component.get("v.brand");
        var action         = component.get("c.sendMessage");
	
        action.setParams({
            config: brand,
            recipientId: recId,
            messageText : commentMessage,
            caseId : component.get("v.recordId"),
            parentCommentId: parentSFID,
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Message sent successfully!!"
                });
                toastEvent.fire();
                component.set("v.replyMessage","");
                component.set("v.isModalOpen",false);
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Something went wrong!"
                });
                toastEvent.fire();
            }
            component.set("v.spinner",false);
        });
        $A.enqueueAction(action); 
    },
    
    viewCommentReplies : function(component, event, helper) {
        debugger;
        component.set("v.spinner",true);
        var comment       = event.getSource().get('v.value');
        var commentedBy   = event.getSource().get('v.name');
        var commentId     = event.getSource().get('v.title');
        component.set("v.selectedCommentId",commentId);
        component.set("v.selectedCommentValue",comment);
        component.set("v.selectedCommentRepliedBy",commentedBy);
        var action         = component.get("c.getRepliesDetails");
        action.setParams({
            commentId: commentId,
         });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var serverresponse = response.getReturnValue();
                if(serverresponse.length > 0){
                    component.set("v.relatedReplyList",serverresponse);
                    component.set("v.showReplies",true);
                    component.set("v.spinner",false);    
                }else{
                    component.set("v.relatedReplyList",[]);
                    component.set("v.showReplies",true);
                    component.set("v.spinner",false);  
                }
                
            }else{
                
            }
        });
        $A.enqueueAction(action); 
    },
    
    next: function(component, event, helper) {
        debugger;
        var sObjectList = component.get("v.relatedCommentList");
        console.log('sObjectList///', sObjectList);
        var startValue = component.get("v.startValue");
        var endValue = component.get("v.endValue");
        var perPage = component.get("v.perPageSize");
        console.log('startValue///', startValue);
        console.log('endValue///', endValue);
        var totalRecords = component.get("v.totalRecords");
        var values = [];
        //for eg-------------------------------------------------------------------------
        // this is page 2 and there are 10 records
        // endValue is 4
        //if total no. of records == 4+5+1 (i.e. 10)
        //Or if total no. of records >  10, then evaluate this part----------------------
        if (totalRecords >= endValue + perPage + 1) {
            for (var i = endValue + 1; i < endValue + perPage + 1; i++) {
                values.push(sObjectList[i]);
            }
            if (totalRecords == endValue + perPage + 1) {//if total records == 4+5+1-----------
                component.set("v.isLastPage", true);
            }
        }//------------------------------------------------------------------------------
        else {//if total number of records are lesser than 4+5+1(10) i.e. 8
            for (var i = endValue + 1; i < totalRecords; i++) {
                values.push(sObjectList[i]);
            }
            component.set("v.isLastPage", true);
        }//------------------------------------------------------------------------------
        component.set("v.PaginationList", values);
        var statrtvalue=endValue+1;
        component.set("v.startValue", statrtvalue);
        component.set("v.endValue", endValue + perPage);
        console.log('start value////' + component.get("v.startValue"));
        console.log('end value////' + component.get("v.endValue"));
        
    },
    
    previous: function(component, event, helper) {
        debugger;
        component.set("v.isLastPage", false);
        var sObjectList = component.get("v.relatedCommentList");
        console.log('sObjectList///', sObjectList);
        var startValue = component.get("v.startValue");
        var endValue = component.get("v.endValue");
        var perPage = component.get("v.perPageSize");
        console.log('startValue///', startValue);
        console.log('endValue///', endValue);
        var totalRecords = component.get("v.totalRecords");
        var values = [];
        for (var i = startValue - perPage; i < startValue; i++) {
            console.log('i' + i);
            values.push(sObjectList[i]);
        }
        component.set("v.PaginationList", values);
        component.set("v.startValue", startValue - perPage);
        component.set("v.endValue", startValue - 1);
        console.log('start value////' + component.get("v.startValue"));
        console.log('end value////' + component.get("v.endValue"));
    },
    
})