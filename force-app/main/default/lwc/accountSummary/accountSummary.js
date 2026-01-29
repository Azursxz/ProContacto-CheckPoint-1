import { LightningElement, api, wire } from 'lwc';
import getAccount from '@salesforce/apex/AccountProjectController.getAccount';
import getAccountSummary from '@salesforce/apex/AccountProjectController.getAccountSummary';

/**
 * Componente para mostrar un resumen de los proyectos de la cuenta.
 * Muestra información presupuestaria y contadores de proyectos.
 */
export default class AccountSummary extends LightningElement {
    @api accountId;
    @api refreshKey;
    account;
    summary = {};

    wiredSummaryResult;


    /**
     * Método cableado (wired) para recuperar detalles de la cuenta.
     * @param {Object} result - El objeto resultado del wire
     * @param {Object} result.error - El error si falla el wire
     * @param {Object} result.data - Los datos de la cuenta
     */
    @wire(getAccount, { accountId: '$accountId' })
    wiredAccount({ error, data }) {
        if (data) {
            this.account = data;
            this.error = undefined; // Limpia error previo si ahora fue exitoso
        } else if (error) {
            this.error = error;
            this.account = undefined; // Limpia datos viejos si ahora falló
            console.error('Error loading account:', error);
        }
    }

    /**
     * Método cableado (wired) para recuperar el resumen de proyectos de la cuenta.
     * Se actualiza cuando cambia refreshKey o la cuenta.
     * @param {Object} result - El objeto resultado del wire
     */
    @wire(getAccountSummary, { accountId: '$accountId', refreshKey: '$refreshKey' })
    wiredSummary(result) {
        this.wiredSummaryResult = result;
        
        if (result.data) {
            this.summary = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.summary = undefined;
            console.error('Error loading summary:', result.error);
        }        
    }

    
}
