import { LightningElement } from 'lwc';

export default class AccountProjectHome extends LightningElement {
    accountId;
    refreshKey = 0;

    handleAccountSelect(event) {
        this.accountId = event.detail;
        
        this.refreshKey ++;

    }

    handleCreateProject(event) {
        this.refreshKey ++;
    }

    handleDeleteProject(event){
        this.refreshKey ++;
    }



}
