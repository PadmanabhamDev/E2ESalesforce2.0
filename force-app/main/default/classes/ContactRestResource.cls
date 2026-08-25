/**
 * REST resource for upserting Contact records through HTTP PUT requests.
 */
@RestResource(urlMapping='/contacts')
global with sharing class ContactRestResource {
    /**
     * Upserts a Contact record based on email and phone values.
     *
     * @param LastName Contact last name. This field is required.
     * @param FirstName Contact first name.
     * @param Email Contact email address. This field is required.
     * @param Phone Contact phone number.
     * @param Title Contact title.
     * @return A success message for create/update operations or an error message when validation fails.
     */
    @HttpPut
    global static String upsertContact(String LastName,String FirstName,String Email,String Phone,String Title) {
        if(String.IsBlank(LastName) || String.IsBlank(Email)){
            return 'Error : LastName and Email is required fields';
        }
        Contact con1 = new Contact();
        List<Contact> conList = [Select Id From Contact Where Email =:Email and Phone =: Phone Limit 1];
        String operation = '';
        if(!conList.IsEmpty()){
            con1.Id = conList[0].Id;
            con1.LastName = LastName;
            con1.FirstName = FirstName;
            con1.Title = Title;
            operation = 'update';
        }else{
            con1.LastName = LastName;
            con1.FirstName = FirstName;
            con1.Title = Title;
            con1.Email = Email;
            con1.Phone = Phone;
            operation = 'create';
        }

        if(operation == 'update'){
            update con1;
        }
        else{
            insert con1;
        }
        return 'Contact '+ operation +' succesfully with '+ con1.Id;
    }
}