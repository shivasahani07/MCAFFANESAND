/* 
 * Copyright (c) 2016, salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license. 
 * For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
 */
 
public class CSVFileUtil {
	//from https://developer.salesforce.com/page/Code_Samples#Parse_a_CSV_with_APEX
    public static List<Map<String,String>>  parseCSV(String csvFileBody,Boolean skipHeaders) {
        
        List<Map<String,String>> dataMap= new List<Map<String,String>>();
        Map<String,String> tempMap= new Map<String,String>();
        
        String contents = csvFileBody;
        
        List<List<String>> allFields = new List<List<String>>();

        // replace instances where a double quote begins a field containing a comma
        // in this case you get a double quote followed by a doubled double quote
        // do this for beginning and end of a field
        contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
        // now replace all remaining double quotes - we do this so that we can reconstruct
        // fields with commas inside assuming they begin and end with a double quote
        contents = contents.replaceAll('""','DBLQT');
	//windows case - replace all carriage + new line character to just new line character
	contents = contents.replaceAll('\r\n','\n');
        //now replace all return char to new line character
        contents = contents.replaceAll('\r','\n');
        // we are not attempting to handle fields with a newline inside of them
        // so, split on newline to get the spreadsheet rows
        List<String> lines = new List<String>();
        try {
            lines = contents.split('\n');
        } catch (System.ListException e) {
            System.debug('Limits exceeded?' + e.getMessage());
        }
        Integer num = 0;
        for(String line : lines) {
            // check for blank CSV lines (only commas)
            if (line.replaceAll(',','').trim().length() == 0) break;
            
            List<String> fields = line.split(',');  
            List<String> cleanFields = new List<String>();
            String compositeField;
            Boolean makeCompositeField = false;
            for(String field : fields) {
                if (field.startsWith('"') && field.endsWith('"')) {
                    cleanFields.add(field.replaceAll('DBLQT','"').trim());
                } else if (field.startsWith('"')) {
                    makeCompositeField = true;
                    compositeField = field;
                } else if (field.endsWith('"')) {
                    compositeField += ',' + field;
                    cleanFields.add(compositeField.replaceAll('DBLQT','"').trim());
                    makeCompositeField = false;
                } else if (makeCompositeField) {
                    compositeField +=  ',' + field;
                } else {
                    cleanFields.add(field.replaceAll('DBLQT','"').trim());
                }
            }
            
            allFields.add(cleanFields);
            tempMap= new Map<String,String>();
            
            if(allFields.size()!=1){
                for(Integer i=0;i<allFields[0].size()-1;i++) {
                    tempMap.put(allFields[0][i],cleanFields[i]);
                }
               dataMap.add(tempMap);
            }
        }
        if (skipHeaders) allFields.remove(0);
        
        //system.debug('Data json -->'+JSON.serialize(dataMap));

        return dataMap;       
    }
}