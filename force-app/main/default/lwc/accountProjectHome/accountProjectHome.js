import { LightningElement } from "lwc";

/**
 * Componente para gestionar la vista principal de proyectos de cuenta.
 * Actúa como contenedor y coordinador entre los componentes de búsqueda, resumen, lista y formulario.
 */
export default class AccountProjectHome extends LightningElement {
  accountId;

  /**
   * Maneja la selección de una cuenta desde el componente de búsqueda.
   * Actualiza el ID de la cuenta seleccionada y dispara una actualización.
   * @param {CustomEvent} event - El evento que contiene el ID de la cuenta seleccionada
   */
  handleAccountSelect(event) {
    this.accountId = event.detail;
  }

  /**
   * Maneja la creación de un nuevo proyecto.
   * Dispara una actualización de los componentes hijos.
   * @param {CustomEvent} event - El evento de creación
   */
  handleCreateProject() {
    this.template.querySelector("c-project-list")?.refresh();
    this.template.querySelector("c-account-summary")?.refresh();
  }

  /**
   * Maneja la eliminación de un proyecto.
   * Dispara una actualización de los componentes hijos.
   * @param {CustomEvent} event - El evento de eliminación
   */
  handleDeleteProject() {
    this.template.querySelector("c-project-list")?.refresh();
    this.template.querySelector("c-account-summary")?.refresh();
  }
}
