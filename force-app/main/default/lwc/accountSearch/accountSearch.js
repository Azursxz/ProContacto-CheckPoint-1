import { LightningElement } from "lwc";
/**
 * Componente para buscar cuentas utilizando un selector de registros.
 */
export default class AccountSearch extends LightningElement {
  /**
   * Maneja el evento de cambio del selector de registros.
   * Envía un evento personalizado con el ID de la cuenta seleccionada.
   * @param {CustomEvent} event - El evento de cambio del campo de entrada
   */
  handleChange(event) {
    this.dispatchEvent(
      new CustomEvent("accountselect", {
        detail: event.detail.recordId
      })
    );
  }
}
