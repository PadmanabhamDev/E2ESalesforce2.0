/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : HubspotAuthController
 * Author          : Padmanabham
 * Created Date    : Jun 26, 2026
 * Last Modified By: Padmanabham
 * Last Modified On: Jun 26, 2026
 * Description     : To get access token in-exchange of auth token
 *  
 * Change History  :
 *  Date          │   Author     │   Change
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 *  Jun 26, 2026  │ Padmanabham  │ Initial version
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 */

public class HubspotAuthController {
    
    @AuraEnabled
	public static WrapperClass.TokenWrapper isAccessTokenValid() {
        //as there is some scenario where we don't have HubSpot_App_Token__c so that's why we are using list
        List<HubSpot_App_Token__c> tokenList = [SELECT Id,Expire_In__c,Access_Token__c,Refresh_Token__c FROM HubSpot_App_Token__c WHERE CreatedById = :UserInfo.getUserId() ORDER BY Expire_In__c DESC LIMIT 1];
		//WrapperClass.TokenWrapper token = new WrapperClass.TokenWrapper();
        // No token record found
        if (tokenList.IsEmpty()) {
            return (new WrapperClass.TokenWrapper('get token', ''));
        }
        // No access token stored
        if (String.isBlank(tokenList[0].Access_Token__c)) {
            return (new WrapperClass.TokenWrapper('get token', ''));
        }
        // Access token expired
        if (System.now() >= tokenList[0].Expire_In__c) {
            return (new WrapperClass.TokenWrapper('refresh token', tokenList[0].Refresh_Token__c));
        }
        // Access token is still valid
        return new WrapperClass.TokenWrapper('use access token', tokenList[0].Access_Token__c);
    }

	@AuraEnabled
	public static String getAuthStatus(String code) {
		
		HubSpot_App_Credentials__mdt credentials = HubSpot_App_Credentials__mdt.getInstance('Salesforce_HubSpot_Integration');
		String clientId = credentials.Client_Id__c;
		String clientSecret = credentials.Client_Secret__c;
		String codeVerifier = credentials.code_Verifier__c;
		String redirectURI = credentials.Redirect_URI__c;

		// 1. Instantiate Http class
		Http http = new Http();
		// 2. craft HttpRequest 
		HttpRequest req = new HttpRequest();
		req.setEndpoint('https://api.hubspot.com/oauth/v3/token');
		req.setMethod('POST');
		req.setHeader('content-type','application/x-www-form-urlencoded');
		String requestBody = 'grant_type=authorization_code'+'&code='+code+'&redirect_uri='+EncodingUtil.urlEncode(redirectURI,'UTF-8')+'&client_id='+clientId+'&client_secret='+clientSecret+'&code_verifier='+codeVerifier;
		req.setBody(requestBody);
		// 3. Send request and handle the response
		HttpResponse res = http.send(req);
		String body = res.getBody();

		if(res.getStatusCode()==200){

			Map<String,Object> resMap = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
			String accessToken = (String)resMap.get('access_token');
			String refreshToken = (String)resMap.get('refresh_token');
			Integer expiresIn = (Integer)resMap.get('expires_in');
			
			System.debug('line 50 '+accessToken);
			System.debug('line 51 '+refreshToken);
			HubSpot_App_Token__c tokens = new HubSpot_App_Token__c();
			//tokens.CreatedById = UserInfo.getUserId();
			tokens.Refresh_Token__c = refreshToken;
			tokens.Access_Token__c = accessToken;
			tokens.Expire_In__c = System.now().addSeconds(expiresIn);
			upsert tokens;

			return accessToken;
		} else{
			System.debug('line 52'+res.getBody());
			return 'Something went wrong. Authentication failed';
		}
	}

	@AuraEnabled
	public static String refreshToken(String tokenCode) {
		try {
			HubSpot_App_Credentials__mdt credentials =
				HubSpot_App_Credentials__mdt.getInstance('Salesforce_HubSpot_Integration');

			Http http = new Http();
			HttpRequest req = new HttpRequest();

			req.setEndpoint('https://api.hubspot.com/oauth/v3/token'); // Recommended
			req.setMethod('POST');
			req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
			req.setTimeout(60000);

			String requestBody =
				'grant_type=refresh_token' +
				'&refresh_token=' + EncodingUtil.urlEncode(tokenCode, 'UTF-8') +
				'&client_id=' + EncodingUtil.urlEncode(credentials.Client_Id__c, 'UTF-8') +
				'&client_secret=' + EncodingUtil.urlEncode(credentials.Client_Secret__c, 'UTF-8');

			req.setBody(requestBody);

			HttpResponse res = http.send(req);

			if (res.getStatusCode() != 200) {
				throw new CalloutException('HubSpot token refresh failed: ' + res.getBody());
			}

			Map<String, Object> resMap =
				(Map<String, Object>) JSON.deserializeUntyped(res.getBody());

			String accessToken = (String) resMap.get('access_token');
			String newRefreshToken = (String) resMap.get('refresh_token');
			Integer expiresIn = (Integer) resMap.get('expires_in');

			// Query existing token record using OLD refresh token
			List<HubSpot_App_Token__c> tokenList = [
				SELECT Id, Expire_In__c, Access_Token__c, Refresh_Token__c
				FROM HubSpot_App_Token__c
				WHERE CreatedById = :UserInfo.getUserId()
				AND Refresh_Token__c = :tokenCode
				LIMIT 1
			];

			if (!tokenList.isEmpty()) {
				HubSpot_App_Token__c tokenRecord = tokenList[0];

				tokenRecord.Access_Token__c = accessToken;
				tokenRecord.Refresh_Token__c = newRefreshToken;
				tokenRecord.Expire_In__c = System.now().addSeconds(expiresIn);

				update tokenRecord;
			} else {
				// Optional: insert fallback
				insert new HubSpot_App_Token__c(
					Access_Token__c = accessToken,
					Refresh_Token__c = newRefreshToken,
					Expire_In__c = System.now().addSeconds(expiresIn)
				);
			}

			return accessToken;

		} catch (Exception e) {
			System.debug('Error in refreshToken: ' + e.getMessage());
			throw new AuraHandledException('Failed to refresh token: ' + e.getMessage());
		}
	}

	public static String getCompanyDetail(String access_token){
		Http http = new Http();
		HttpRequest req = new HttpRequest();
		req.setEndpoint('https://api.hubapi.com/crm/objects/2026-03/Company?limit=10');
		req.setMethod('GET');
		req.setHeader('Authorization', 'Bearer '+access_token);
		req.setHeader('content-type','application/json');
		HttpResponse res = http.send(req);
		if(res.getStatusCode()==200){
			return res.getBody();
		}else{
			return 'Error in retrieving';
		}
	}

	public static String createContacts(String access_token){

		Http http = new Http();
		HttpRequest req = new HttpRequest();
		req.setEndpoint('https://api.hubapi.com/crm/objects/2026-03/Contact/batch/create');
		req.setMethod('POST');
		req.setHeader('Content-Type','application/json');
		req.setHeader('Authorization','Bearer '+access_token);
		req.setBody(' { "inputs": [ { "properties": { "firstname": "TestSalesforce2", "lastname": "Salesforce3", "email": "test3@mail.com", "phone":"1234567890" } } ] } ');
		HttpResponse res = http.send(req);
		if(res.getStatusCode()==201){
			return res.getBody();
		}else{
			return res.getBody();
		}
	}		
}