import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
/**
 * Componente ProjectForm
 * ----------------------
 * Formulario para la creación de proyectos asociados a una Account.
 * Notifica al componente padre cuando el proyecto se crea correctamente.
 */
export default class ProjectForm extends LightningElement {
/**
 * Id de la Account asociado al proyecto.
 * Se recibe desde el componente padre mediante @api.
 */
   @api accountId;


    /**
     * Handler que se ejecuta cuando el registro se crea exitosamente.
     * - Muestra un toast de éxito
     * - Limpia los campos del formulario
     * - Notifica al componente padre que el proyecto fue creado
     *
     * @param {Event} event Evento de éxito emitido por lightning-record-edit-form
     */
    handleSuccess(event) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Proyecto creado',
                message: 'El proyecto se creó correctamente',
                variant: 'success'
            })
        );

        // Resetear los campos del formulario marcados con data-reset

         this.template
            .querySelectorAll('[data-reset]')
            .forEach(field => field.reset());
    


        // Avisar al componente padre 
        this.dispatchEvent(new CustomEvent('projectcreated'));

    }
    /**
     * Handler que se ejecuta cuando ocurre un error al crear el proyecto.
     * Muestra un toast con el mensaje de error devuelto por Salesforce.
     *
     * @param {Event} event Evento de error con el detalle del fallo
     */
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
