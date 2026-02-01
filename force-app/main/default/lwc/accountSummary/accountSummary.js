import { LightningElement, api, wire } from "lwc";
import getAccount from "@salesforce/apex/AccountProjectController.getAccount";
import getAccountSummary from "@salesforce/apex/AccountProjectController.getAccountSummary";
import { refreshApex } from "@salesforce/apex";

/**
 * Componente para mostrar un resumen de los proyectos de la cuenta.
 * Muestra información presupuestaria y contadores de proyectos.
 */
export default class AccountSummary extends LightningElement {
  /**
   * Id de la cuenta actual.
   * Se recibe desde el componente padre.
   * @type {string}
   */
  @api accountId;
  /**
   * Datos completos de la cuenta recuperados desde Apex.
   * Se asigna en el wire `wiredAccount`.
   * @type {Object}
   */
  account;
  /**
   * Objeto que contiene el resumen de proyectos de la cuenta
   * (contadores, totales, presupuestos, etc.).
   * Inicializado como objeto vacío para evitar errores en el template.
   * @type {Object}
   */
  summary = {};
  /**
   * Referencia al resultado del wire de getAccountSummary.
   * Se utiliza para poder refrescar manualmente el wire
   * mediante refreshApex si fuese necesario.
   * @type {Object}
   */
  wiredSummaryResult;
  /**
   * Método público expuesto al componente padre.
   * Fuerza la recarga de los proyectos ejecutando refreshApex.
   */
  @api
  refresh() {
    if (this.wiredSummaryResult) {
      refreshApex(this.wiredSummaryResult);
    }
  }
  /**
   * Método cableado (wired) para recuperar detalles de la cuenta.
   * @param {Object} result - El objeto resultado del wire
   * @param {Object} result.error - El error si falla el wire
   * @param {Object} result.data - Los datos de la cuenta
   */
  @wire(getAccount, { accountId: "$accountId" })
  wiredAccount({ error, data }) {
    if (data) {
      this.account = data;
      this.error = undefined; // Limpia error previo si ahora fue exitoso
    } else if (error) {
      this.error = error;
      this.account = undefined; // Limpia datos viejos si ahora falló
      console.error("Error loading account:", error);
    }
  }

  /**
   * Método cableado (wired) para recuperar el resumen de proyectos de la cuenta.
   * Se actualiza cuando cambia refreshKey o la cuenta.
   * @param {Object} result - El objeto resultado del wire
   */
  @wire(getAccountSummary, {
    accountId: "$accountId"
  })
  wiredSummary(result) {
    this.wiredSummaryResult = result;

    if (result.data) {
      this.summary = result.data;
      this.error = undefined;
    } else if (result.error) {
      this.error = result.error;
      console.error("Error loading summary:", result.error);
    }
  }
}
