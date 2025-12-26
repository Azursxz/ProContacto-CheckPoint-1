import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ProjectForm extends LightningElement {

   @api accountId;


    handleSuccess(event) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Proyecto creado',
                message: 'El proyecto se creó correctamente',
                variant: 'success'
            })
        );


         this.template
            .querySelectorAll('[data-reset]')
            .forEach(field => field.reset());
    


        // Avisar al componente padre 
        this.dispatchEvent(new CustomEvent('projectcreated'));

    }

    handleError(event) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error al crear proyecto',
                message: event.detail.message,
                variant: 'error'
            })
        );
    }
}
