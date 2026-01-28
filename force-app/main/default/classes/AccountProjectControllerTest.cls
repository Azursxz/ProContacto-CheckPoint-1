@IsTest
public class AccountProjectControllerTest {
    @IsTest
    static void testGetAccount() {
        // Crear cuenta de prueba
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        Test.startTest();
        // Llamar al método bajo prueba
        Account result = AccountProjectController.getAccount(testAccount.Id);
        Test.stopTest();
        // Verificaciones
        System.assertNotEquals(null, result, 'La cuenta no debería ser null');
        System.assertEquals(testAccount.Id, result.Id, 'El ID debería coincidir');
        System.assertEquals('Test Account', result.Name, 'El nombre debería coincidir');
    }


 @IsTest
    static void testGetAccountSummary() {
        // Crear cuenta de prueba
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        Contact contacto = new Contact(
        FirstName = 'Test',
        LastName = 'Contact',
        AccountId = testAccount.Id
        );
        insert contacto;
        // Crear proyectos relacionados con la cuenta
        Proyecto__c proyecto1 = new Proyecto__c(
            Name = 'Proyecto 1',
            Account__c = testAccount.Id,
            Contacto__c = contacto.Id,
            Presupuesto__c = 5000,
            Estado__c = 'Finalizado',
            Recursos__c = 5
        );
        Proyecto__c proyecto2 = new Proyecto__c(
            Name = 'Proyecto 2',
            Account__c = testAccount.Id,
            Contacto__c = contacto.Id,
            Presupuesto__c = 8000,
            Estado__c = 'Finalizado',
            Recursos__c = 3
        );
        insert new List<Proyecto__c>{proyecto1, proyecto2};
        Test.startTest();
        // Llamar al método bajo prueba con refreshKey (aunque no se usa en el método)
        Map<String, Decimal> result = AccountProjectController.getAccountSummary(testAccount.Id, 1);
        Test.stopTest();
        // Verificaciones
        System.assertNotEquals(null, result, 'El resultado no debería ser null');
        System.assertEquals(2, result.size(), 'Debería tener 2 valores en el mapa');
        System.assertEquals(13000, result.get('totalBudget'), 'Total budget debería ser 13000');
        System.assertEquals(8, result.get('totalResources'), 'Total recursos debería ser 8');
    }

    @IsTest
static void testGetProjects() {
    // Crear cuenta de prueba
    Account testAccount = new Account(Name = 'Test Account');
    insert testAccount;
    // Crear contacto (para probar Contacto__r.Name)
    Contact testContact = new Contact(
        FirstName = 'Test',
        LastName = 'Contact',
        AccountId = testAccount.Id
    );
    insert testContact;
    // Crear múltiples proyectos para mejor cobertura
    List<Proyecto__c> proyectos = new List<Proyecto__c>();
    // Proyecto con contacto
    proyectos.add(new Proyecto__c(
        Name = 'Proyecto Test 1',
        Account__c = testAccount.Id,
        Presupuesto__c = 5000,
        Estado__c = 'En Progreso',
        Contacto__c = testContact.Id
    ));
    // Proyecto sin contacto (para cubrir el caso null)
    proyectos.add(new Proyecto__c(
        Name = 'Proyecto Test 2',
        Account__c = testAccount.Id,
        Presupuesto__c = 10000,
        Estado__c = 'Finalizado',
        Contacto__c = testContact.Id
    ));
    insert proyectos;
    Test.startTest();
    // Método devuelve List<Map<String, Object>>
    List<Map<String, Object>> result = AccountProjectController.getProjects(testAccount.Id);
    Test.stopTest();
    // Verificaciones
    System.assertNotEquals(null, result, 'El resultado no debe ser nulo');
    System.assertEquals(2, result.size(), 'Debe haber 2 proyectos');

}


@IsTest
    static void testDeleteProject() {
         // Crear cuenta de prueba
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        // Crear contacto (para probar Contacto__r.Name)
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = testAccount.Id
        );
        insert testContact;
        // Valor para Estado__c (usa uno real de tu org)
        String estado = 'En Progreso';
        // Crear AL MENOS UN proyecto
        Proyecto__c proyecto = new Proyecto__c(
            Name = 'Proyecto Test',
            Account__c = testAccount.Id,
            Presupuesto__c = 5000,
            Estado__c = estado,
            Contacto__c = testContact.Id
        );
        insert proyecto;
        // Verificar que existe antes de eliminar
        List<Proyecto__c> proyectosAntes = [SELECT Id FROM Proyecto__c WHERE Id = :proyecto.Id];
        System.assertEquals(1, proyectosAntes.size(), 'Debería existir 1 proyecto antes');
        Test.startTest();
        // Llamar al método bajo prueba
        AccountProjectController.deleteProject(proyecto.Id);
        Test.stopTest();
        // Verificar que fue eliminado
        List<Proyecto__c> proyectosDespues = [SELECT Id FROM Proyecto__c WHERE Id = :proyecto.Id];
        System.assertEquals(0, proyectosDespues.size(), 'El proyecto debería estar eliminado');
    }
}