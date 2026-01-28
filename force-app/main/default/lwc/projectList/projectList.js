import { LightningElement, api, wire } from 'lwc';
import getProjects from '@salesforce/apex/AccountProjectController.getProjects';
import deleteProject from '@salesforce/apex/AccountProjectController.deleteProject';
import { refreshApex } from '@salesforce/apex';
import LightningConfirm from 'lightning/confirm';

export default class ProjectList extends LightningElement {
    @api refreshKey;
    _refreshKey;
    wiredResult;
    projects;
    _accountId;

    set refreshKey(value) {
        this._refreshKey = value;

        if (this.wiredResult) {
            refreshApex(this.wiredResult);
        }
    }

    get refreshKey() {
        return this._refreshKey;
    }

    @api
    set accountId(value) {
    this._accountId = value;
    this.projects = [];
    }

    get accountId() {
        return this._accountId;
    }




    columns = [
        { label: 'Proyecto', fieldName: 'Name' },
        { label: 'Contacto', fieldName: 'ContactoName'},
        { label: 'Presupuesto', fieldName: 'Presupuesto__c', type: 'currency' },
        { label: 'Estado', fieldName: 'Estado__c' },
        {
            type: 'button-icon',
            typeAttributes: {
                iconName: 'utility:delete',
                name: 'delete',
                title: 'Eliminar'
            }
        }
    ];

    @wire(getProjects, { accountId: '$_accountId' })
    wiredProjects(result) {
        this.wiredResult = result;
        if (result.data) {
            this.projects = result.data;
        }
        else if (result.error) {
            console.error(result.error);
        }
    }

    async handleRowAction(event) {
        if (event.detail.action.name === 'delete') {
            const confirmed = await LightningConfirm.open({
                message: '¿Eliminar proyecto?',
                label: 'Confirmar'
            });

            if (confirmed) {
                await deleteProject({ projectId: event.detail.row.Id });
                this.dispatchEvent(new CustomEvent('projectdelete'));
                refreshApex(this.wiredResult);
            }

        }
    }




    
}
