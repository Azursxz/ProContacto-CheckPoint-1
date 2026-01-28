@IsTest
public with sharing class ProyectoEliminacionHandlerTest {
    // Test 1: Proyecto Planeado RECIENTE - NO se puede eliminar
    @IsTest
    static void testNoEliminarPlaneadoReciente() {
        Account cuenta = new Account(Name = 'Test');
        insert cuenta;

        Contact contacto = new Contact(
        FirstName = 'Test',
        LastName = 'Contact',
        AccountId = cuenta.Id
        );
        insert contacto;
        Proyecto__c proyecto = new Proyecto__c(
            Name = 'Test',
            Account__c = cuenta.Id,
            Contacto__c = contacto.Id,
            Presupuesto__c = 5000,
            Estado__c = 'Planeado',
            Fecha_de_Inicio__c = Date.today()  // HOY (< 1 año)
        );
        insert proyecto;
        try {
            delete proyecto;
            System.assert(false, 'Deberia fallar');
        } catch (Exception e) {
            System.assert(true, 'Correcto: no permite eliminar');
        }
    }

    // Test 2: Proyecto NO Planeado - SÍ se puede eliminar
    @IsTest
    static void testEliminarNoPlaneado() {
        Account cuenta = new Account(Name = 'Test');
        insert cuenta;

        Contact contacto = new Contact(
        FirstName = 'Test',
        LastName = 'Contact',
        AccountId = cuenta.Id
        );
        insert contacto;
        Proyecto__c proyecto = new Proyecto__c(
            Name = 'Test',
            Account__c = cuenta.Id,
            Contacto__c = contacto.Id,
            Presupuesto__c = 5000,
            Estado__c = 'Finalizado',  // DIFERENTE de 'Planeado'
            Fecha_de_Inicio__c = Date.today()
        );
        insert proyecto;
        // Esto deberia funcionar sin error
        delete proyecto;
        System.assertEquals(0, [SELECT COUNT() FROM Proyecto__c WHERE Id = :proyecto.Id]);
    }

    @IsTest
    static void testEliminarPlaneadoAntiguo() {
        // Activar bypass SOLO para este test
        Bypass_Validations__c bypass = new Bypass_Validations__c(
            SetupOwnerId = UserInfo.getOrganizationId(), //activa bypass a nivel org solo dentro del test
            Bypass__c = true
        );
        insert bypass;
        Account cuenta = new Account(Name = 'Test');
        insert cuenta;
        Contact contacto = new Contact(
        FirstName = 'Test',
        LastName = 'Contact',
        AccountId = cuenta.Id
        );
        insert contacto;
        Proyecto__c proyecto = new Proyecto__c(
            Name = 'Test Antiguo',
            Account__c = cuenta.Id,
            Contacto__c = contacto.Id,
            Presupuesto__c = 5000,
            Estado__c = 'Planeado',
            Fecha_de_Inicio__c = Date.today().addYears(-1).addDays(-10)
        );
        insert proyecto;
        delete proyecto;
        System.assertEquals(0, [SELECT COUNT() FROM Proyecto__c WHERE Id = :proyecto.Id]);
    }

    @IsTest
static void testNoEliminarSinFechaInicio() {
    // Cuenta
    Account cuenta = new Account(Name = 'Cuenta Test');
    insert cuenta;
    // Contacto asociado (para pasar otras validations)
    Contact contacto = new Contact(
        LastName = 'Contacto Test',
        AccountId = cuenta.Id
    );
    insert contacto;
    // Proyecto SIN Fecha_de_Inicio__c
    Proyecto__c proyecto = new Proyecto__c(
        Name = 'Proyecto Sin Fecha',
        Account__c = cuenta.Id,
        Contacto__c = contacto.Id,
        Presupuesto__c = 5000,
        Estado__c = 'Planeado'
    );
    insert proyecto;
    // Intentar eliminar
    try {
        delete proyecto;
        System.assert(false, 'Debería lanzar error por no tener fecha de inicio');
    } catch (DmlException e) {
        // Validar mensaje de error
        System.assert(
            e.getMessage().contains('no tiene fecha de inicio definida'),
            'El mensaje de error no es el esperado'
        );
    }
}
}