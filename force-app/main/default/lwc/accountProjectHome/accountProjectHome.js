import { LightningElement } from "lwc";

/**
 * Componente AccountProjectHome
 * -----------------------------
 * Componente contenedor de la vista principal de Proyectos por Account.
 *
 * Responsabilidades:
 * - Mantener el estado de la Account seleccionada
 * - Coordinar la comunicación entre componentes hijos
 * - Orquestar refrescos de datos cuando ocurren eventos relevantes
 *
 * No obtiene ni modifica datos directamente.
 * Toda la lógica de negocio reside en componentes hijos y Apex.
 */
export default class AccountProjectHome extends LightningElement {
  /**
   * Id de la Account actualmente seleccionada.
   *
   * Se propaga a los componentes hijos para:
   * - Obtener el resumen de proyectos
   * - Listar proyectos asociados
   * - Crear nuevos proyectos en la cuenta correcta
   */
  accountId;

  /**
   * Maneja la selección de una Account desde el componente de búsqueda.
   *
   * Flujo:
   * 1. El componente de búsqueda emite un CustomEvent con el accountId
   * 2. Se actualiza el estado local
   * 3. Los componentes hijos reaccionan al nuevo accountId
   *
   * @param {CustomEvent} event Evento que contiene el Id de la Account seleccionada
   */
  handleAccountSelect(event) {
    this.accountId = event.detail;
  }

  /**
   * Maneja la creación de un nuevo proyecto.
   *
   * Este método se ejecuta cuando el componente de formulario
   * emite un evento indicando que el proyecto fue creado exitosamente.
   *
   * Se refrescan explícitamente los componentes hijos que dependen
   * de los datos de proyectos:
   * - Lista de proyectos
   * - Resumen de cuenta
   */
  handleCreateProject() {
    this.template.querySelector("c-project-list")?.refresh();
    this.template.querySelector("c-account-summary")?.refresh();
  }

  /**
   * Maneja la eliminación de un proyecto.
   *
   * Se ejecuta cuando el componente ProjectList emite el evento
   * "projectdelete" luego de una eliminación exitosa.
   *
   * Fuerza la recarga de:
   * - La lista de proyectos
   * - El resumen de la cuenta
   */
  handleDeleteProject() {
    this.template.querySelector("c-project-list")?.refresh();
    this.template.querySelector("c-account-summary")?.refresh();
  }
}
