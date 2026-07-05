import { LightningElement, track } from "lwc";
import isAccessTokenValid from '@salesforce/apex/HubspotAuthController.isAccessTokenValid';
import getAuthStatus from '@salesforce/apex/HubspotAuthController.getAuthStatus';
import refreshToken from "@salesforce/apex/HubspotAuthController.refreshToken";

export default class HubspotAuthInitiate extends LightningElement {

  @track tokenCode = '';
  @track tokenStatus = '';
  @track isLoading = false;
  @track error;

  connectedCallback() {
    this.handleTokenFlow();
  }

  async handleTokenFlow() {
    this.isLoading = true;
    this.error = null;

    try {
      const result = await isAccessTokenValid();

      this.tokenStatus = result.status;
      this.tokenCode = result.code;

      switch (this.tokenStatus) {

        case 'get token':
          await this.handleAuthorizationCode();
          break;

        case 'refresh token':
          await this.handleRefreshToken();
          break;

        case 'use access token':
          this.handleUseAccessToken();
          break;

        default:
          this.redirectToHubspot();
      }

    } catch (error) {
      this.handleError(error);
    } finally {
      this.isLoading = false;
    }
  }

  async handleAuthorizationCode() {
    const url = window.location.href;
    const code = new URL(url).searchParams.get('c__code');

    if (!code) {
      this.redirectToHubspot();
      return;
    }

    try {
      const result = await getAuthStatus({ code });
      console.log('Auth successful', result);
    } catch (error) {
      this.handleError(error);
    }
  }

  async handleRefreshToken() {
    try {
      const accessToken = await refreshToken({ tokenCode: this.tokenCode });
      console.log('Token refreshed successfully', accessToken);
    } catch (error) {
      this.handleError(error);
    }
  }

  handleUseAccessToken() {
    console.log('Using existing token:', this.tokenCode);
    // Call your business API here
  }

  redirectToHubspot() {
    const authUrl = this.getAuthUrl();
    window.location.href = authUrl;
  }

  getAuthUrl() {
    return "https://mcp-na2.hubspot.com/oauth/authorize/user" +
      "?client_id=53c826dd-7399-4acc-a9c8-11432ffe90cc" +
      "&redirect_uri=https%3A%2F%2Forgfarm-e2ca5826ba-dev-ed.develop.lightning.force.com%2Fapex%2FHubSpotRedirectPage" +
      "&code_challenge=s2xno8IMpGImXJGV1Gj9boZiz59oZLgAYJtiIu3KZeE" +
      "&code_challenge_method=S256";
  }

  handleError(error) {
    console.error('Error:', error);
    this.error = error?.body?.message || error.message || 'Unknown error';
  }
}