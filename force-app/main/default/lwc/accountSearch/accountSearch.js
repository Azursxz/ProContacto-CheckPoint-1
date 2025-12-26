import { LightningElement } from 'lwc';

export default class AccountSearch extends LightningElement {

    handleChange(event) {
        this.dispatchEvent(
            new CustomEvent('accountselect', {
                detail: event.detail.recordId
            })
        );
    }
}
