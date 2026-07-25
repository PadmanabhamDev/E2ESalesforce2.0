import Description from '@salesforce/schema/Account.Description';
import Quantity from '@salesforce/schema/Asset.Quantity';
import UnitPrice from '@salesforce/schema/PricebookEntry.UnitPrice';
import { LightningElement, api, track } from 'lwc';

export default class AddProducts extends LightningElement {

    @api recordId;
    @api objectApiName;
    @track records = [];

    connectedCallback() {
        if (this.objectApiName === 'Opportunity') {

        } else if (this.objectApiName === 'Order') {

        } else if (this.objectApiName === 'Quote') {

        }
        this.addRow();
    }

    addRow(event) {
        //event.preventDefault();
        this.records.push({
            Quantity: null,
            Description: null,
            UnitPrice: null,
            ServiceDate: null,
        })
    }
}