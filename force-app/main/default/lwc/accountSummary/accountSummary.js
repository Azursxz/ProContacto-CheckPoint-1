import { LightningElement, api, wire } from 'lwc';
import getAccount from '@salesforce/apex/AccountProjectController.getAccount';
import getAccountSummary from '@salesforce/apex/AccountProjectController.getAccountSummary';

export default class AccountSummary extends LightningElement {
    @api accountId;
    @api refreshKey;
    account;
    summary = {};

    wiredSummaryResult;


    @wire(getAccount, { accountId: '$accountId' })
    wiredAccount({ error, data }) {
        if (data) {
            this.account = data;
            this.error = undefined; // Limpia error previo si ahora fue exitoso
        } else if (error) {
            this.error = error;
            this.account = undefined; // Limpia datos viejos si ahora falló
            console.error('Error loading account:', error);
        }
    }

    @wire(getAccountSummary, { accountId: '$accountId', refreshKey: '$refreshKey' })
    wiredSummary(result) {
        this.wiredSummaryResult = result;
        
        if (result.data) {
            this.summary = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.summary = undefined;
            console.error('Error loading summary:', result.error);
        }        
    }

    
}
