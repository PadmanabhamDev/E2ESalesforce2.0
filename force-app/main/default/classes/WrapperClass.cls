public with sharing class WrapperClass {
    
    public class TokenWrapper {
        @AuraEnabled
        public String status {get;set;}
        @AuraEnabled
        public String code {get;set;}
        
        public TokenWrapper(String status, String code){
            this.status = status;
            this.code = code;
        }
    }
}