@isTest
private class TestInstagramMentionCreationBatch {
   @isTest
    static void testBatchWithCallouts() {
        Test.setMock(HttpCalloutMock.class, new DynamicHttpCalloutTest());

        // Create test data if needed
        Test.startTest();
        InstagramMentionCreationBatch batch = new InstagramMentionCreationBatch();
        Id batchInstanceId = Database.executeBatch(batch);
         Test.stopTest();
        // Wait for the batch to finish (adjust timeout as needed)
        
       
        
        // Perform assertions or verifications
    }
}