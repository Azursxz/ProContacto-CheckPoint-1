import { LightningElement } from 'lwc';

export default class AccountProjectHome extends LightningElement {
    accountId;
    refreshKey = 0;

    handleAccountSelect(event) {
        this.accountId = event.detail;
        setTimeout(() => {
            this.refreshKey++;
        }, 100);
    }

    handleCreateProject(event) {
        this.refreshKey++;
    }

    handleDeleteProject(event){
        this.refreshKey++;
    }



}
