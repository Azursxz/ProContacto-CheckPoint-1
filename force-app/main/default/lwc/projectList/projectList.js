import { LightningElement, api, wire } from "lwc";
import getProjects from "@salesforce/apex/AccountProjectController.getProjects";
import deleteProject from "@salesforce/apex/AccountProjectController.deleteProject";
import { refreshApex } from "@salesforce/apex";
import LightningConfirm from "lightning/confirm";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

/**
 * Componente ProjectList
 * ---------------------
 * Muestra una lista de proyectos asociados a una Account.
 *
 * Responsabilidades:
 * - Obtener proyectos vía Apex (@wire)
 * - Mostrar los proyectos en un lightning-datatable
 * - Permitir eliminar proyectos
 * - Exponer un método público para refrescar la lista
 * - Notificar al componente padre cuando se elimina un proyecto
 */
export default class ProjectList extends LightningElement {
  /**
   * Referencia al resultado del @wire.
   * Se utiliza por refreshApex para forzar la recarga de datos.
   */
  wiredResult;
  /**
   * Lista de proyectos a mostrar en el datatable.
   * Proviene del método Apex getProjects.
   */
  projects;
  /**
   * Backing property del accountId expuesto como @api.
   */
  _accountId;

  /**
   * Id de la Account.
   * Al cambiar, se limpia la lista de proyectos.
   */
  @api
  set accountId(value) {
    this._accountId = value;
    this.projects = [];
  }

  get accountId() {
    return this._accountId;
  }

  /**
   * Definición de columnas para lightning-datatable
   *
   * Incluye una acción de eliminación por fila.
   */
  columns = [
    { label: "Proyecto", fieldName: "Name" },
    { label: "Contacto", fieldName: "ContactoName" },
    { label: "Presupuesto", fieldName: "Presupuesto__c", type: "currency" },
    { label: "Estado", fieldName: "Estado__c" },
    {
      type: "button-icon",
      typeAttributes: {
        iconName: "utility:delete",
        name: "delete",
        title: "Eliminar"
      }
    }
  ];
  /**
   * Método público expuesto al componente padre.
   * Fuerza la recarga de los proyectos ejecutando refreshApex.
   */
  @api
  refresh() {
    if (this.wiredResult) {
      refreshApex(this.wiredResult);
    }
  }
  /**
   * Obtiene los proyectos asociados a la Account mediante Apex.
   * Se guarda la referencia del wire para poder refrescarla luego.
   */
  @wire(getProjects, { accountId: "$_accountId" })
  wiredProjects(result) {
    this.wiredResult = result;
    if (result.data) {
      this.projects = result.data;
    } else if (result.error) {
      console.error(result.error);
    }
  }

  /**
   * Maneja acciones sobre las filas del datatable.
   * Actualmente soporta la acción "delete".
   *
   * Flujo:
   * 1. Solicita confirmación al usuario
   * 2. Llama al método Apex deleteProject
   * 3. Muestra toast de éxito o error
   * 4. Refresca la lista de proyectos
   * 5. Emite el evento "projectdelete" al componente padre
   *
   * @param {Event} event Evento emitido por lightning-datatable
   */
  async handleRowAction(event) {
    if (event.detail.action.name === "delete") {
      const confirmed = await LightningConfirm.open({
        message: "¿Eliminar proyecto?",
        label: "Confirmar"
      });

      if (!confirmed) {
        return;
      }

      try {
        // Llamada a Apex
        await deleteProject({ projectId: event.detail.row.Id });

        // Éxito
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Proyecto eliminado",
            message: "El proyecto se eliminó correctamente",
            variant: "success"
          })
        );

        this.refresh();
        this.dispatchEvent(new CustomEvent("projectdelete"));
      } catch (error) {
        let message =
          "No se pudo eliminar el proyecto, solo se pueden eliminar proyectos en estado 'Planeado' que hayan iniciado hace mas de un año.";

        if (error?.body?.message) {
          message = error.body.message;
        }

        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error al eliminar",
            message,
            variant: "error"
          })
        );

        console.error("Error eliminando proyecto:", error);
      }
    }
  }
}
