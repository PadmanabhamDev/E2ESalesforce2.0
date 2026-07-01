import { LightningElement } from "lwc";
import getAuthStatus from '@salesforce/apex/HubspotAuthController.getAuthStatus'
export default class HubspotAuthInitiate extends LightningElement {


  connectedCallback() {
    const url = window.location.href;
    const code = new URL(url).searchParams.get('c__code');
    getAuthStatus({code : code})
    .then(result =>{
      console.log(JSON.stringify(result));
    })
    .catch(error =>{
      console.log('line error'+JSON.stringify(error));
    })


  }

  handleClick() {
    window.location.href = "https://mcp-na2.hubspot.com/oauth/authorize/user?client_id=53c826dd-7399-4acc-a9c8-11432ffe90cc&redirect_uri=https%3A%2F%2Forgfarm-e2ca5826ba-dev-ed.develop.lightning.force.com%2Fapex%2FHubSpotRedirectPage&code_challenge=_23_T7D3nzB51VVi_5BQmaDVldM4iyVqkX6gZN3CEWE&code_challenge_method=S256";

  }
}