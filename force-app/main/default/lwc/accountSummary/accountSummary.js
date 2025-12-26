import { LightningElement, api, wire } from 'lwc';
import getAccount from '@salesforce/apex/AccountProjectController.getAccount';
import getAccountSummary from '@salesforce/apex/AccountProjectController.getAccountSummary';

export default class AccountSummary extends LightningElement {
    @api accountId;
    @api refreshKey;
    account;
    summary = {};

    wiredSummaryResult;


    @wire(getAccount, { accountId: '$accountId'})
    wiredAccount({ data }) {
        if (data) this.account = data;
    }

    @wire(getAccountSummary, { accountId: '$accountId', refreshKey: '$refreshKey' })
    wiredSummary(result) {
        this.wiredSummaryResult = result;
        if (result.data) {
            this.summary = result.data;
        }
    }

    
}
