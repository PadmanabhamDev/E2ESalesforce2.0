/**
 * REST resource for creating Account records.
 */
@RestResource(urlMapping='/accounts')
global with sharing class AccountRestService {

    /**
     * Creates a new Account from the specified name value.
     *
     * @param name Name of the Account to create.
     * @return A success or error message describing the result.
     */
    @HttpPost
    global static String createAccounts(String name){
        if(String.IsBlank(name)){
            return 'Error : Name field is required for Creating Account';
        }
        Account acc = new Account();
        acc.Name = name;
        try{
            insert acc;
            return 'Account Created Succesfully '+acc.Id;
        }catch(Exception ex){
            return ('Error is creating account '+ex.getMessage());
        }
    }
}