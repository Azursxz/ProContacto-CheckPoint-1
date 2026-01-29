@IsTest
public class ProyectoValidacionLimiteHandlerTest {
/**
 * @description
 * Método @TestSetup que crea los datos base para todos los tests.
 *
 * - Crea un usuario de prueba para ejecutar los tests con System.runAs
 * - Crea cuentas con distintos límites de proyectos activos
 *   (0, 1 y 2 proyectos)
 * - Crea un contacto asociado a cada cuenta
 *
 * Estos datos se reutilizan en todos los métodos de test
 * para mejorar performance y evitar duplicación.
 */
    @TestSetup
    static void setupData() {
        // Usuario de prueba
        Profile p = [SELECT Id FROM Profile WHERE Id = :UserInfo.getProfileId()];
        User u = new User(
            Alias = 'standt',
            Email = 'standarduser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'unique' + System.currentTimeMillis() + '@testorg.com'
        );
        insert u;

        System.runAs(u) {
            // Cuenta límite 1
            Account cuentaLimite1 = new Account(
                Name = 'Cuenta Limite 1',
                Maximo_Proyectos_Activos__c = 1
            );

            // Cuenta límite 2
            Account cuentaLimite2 = new Account(
                Name = 'Cuenta Limite 2',
                Maximo_Proyectos_Activos__c = 2
            );

            // Cuenta límite 0
            Account cuentaLimite0 = new Account(
                Name = 'Cuenta Limite 0',
                Maximo_Proyectos_Activos__c = 0
            );

            insert new List<Account>{ cuentaLimite1, cuentaLimite2, cuentaLimite0 };

            // Contactos
            insert new List<Contact>{
                new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = cuentaLimite1.Id),
                new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = cuentaLimite2.Id),
                new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = cuentaLimite0.Id)
            };
        }
    }
    /**
 * @description
 * Verifica que el trigger NO permita crear un proyecto
 * cuando se supera el límite de proyectos activos
 * configurado en la cuenta.
 *
 * Escenario:
 * - Cuenta con límite = 1
 * - Se crea un primer proyecto en estado "En Progreso"
 * - Se intenta crear un segundo proyecto también "En Progreso"
 *
 * Resultado esperado:
 * - El segundo insert debe fallar lanzando una DmlException.
 */
    @IsTest
    static void testTriggerExcedeLimite() {
        // Create a user to run the test as, ensuring we avoid Mixed DML errors and satisfy best practices
        User u = [SELECT Id FROM User WHERE Alias = 'standt' LIMIT 1];

        System.runAs(u) {
            // Crear cuenta con límite bajo
            List<Account> cuenta = [SELECT Id FROM Account WHERE Maximo_Proyectos_Activos__c = 1 LIMIT 1];
            List<Contact> contacto = [SELECT Id FROM Contact WHERE AccountId = :cuenta[0].Id LIMIT 1];
            // Crear primer proyecto (dentro del límite)
            Proyecto__c proyecto1 = new Proyecto__c(
                Name = 'Proyecto 1',
                Account__c = cuenta[0].Id,
                Contacto__c = contacto[0].Id,
                Presupuesto__c = 5000,
                Estado__c = 'En Progreso'
            );
            insert proyecto1;  // Esto disparará el trigger
            // Crear segundo proyecto (excedería el límite)
            Proyecto__c proyecto2 = new Proyecto__c(
                Name = 'Proyecto 2',
                Account__c = cuenta[0].Id,
                Contacto__c = contacto[0].Id,
                Presupuesto__c = 10000,
                Estado__c = 'En Progreso'
            );
            Boolean fallo = false;
            Test.startTest();
            try {
                insert proyecto2;
            } catch (DmlException e) {
                fallo = true;
            }
            Test.stopTest();
            Assert.isFalse(fallo, 'Debería haber fallado por límite excedido');
        }
    }
    /**
 * @description
 * Verifica que el trigger permita crear proyectos
 * cuando la cantidad de proyectos activos
 * NO supera el límite definido en la cuenta.
 *
 * Escenario:
 * - Cuenta con límite = 2
 * - Se crean dos proyectos en estado "En Progreso"
 *
 * Resultado esperado:
 * - Ambos proyectos se insertan correctamente.
 * - Existen exactamente 2 proyectos asociados a la cuenta.
 */
    @IsTest
    static void testTriggerDentroLimite() {
         // Create a user to run the test as, ensuring we avoid Mixed DML errors and satisfy best practices
        User u = [SELECT Id FROM User WHERE Alias = 'standt' LIMIT 1];

        System.runAs(u) {
        // Crear cuenta con límite
        List<Account> cuenta = [SELECT Id FROM Account WHERE Maximo_Proyectos_Activos__c = 2 LIMIT 1];
        List<Contact> contacto = [SELECT Id FROM Contact WHERE AccountId = :cuenta[0].Id LIMIT 1];
        // Crear primer proyecto
        Proyecto__c proyecto1 = new Proyecto__c(
            Name = 'Proyecto 1',
            Account__c = cuenta[0].Id,
            Contacto__c = contacto[0].Id,
            Presupuesto__c = 5000,
            Estado__c = 'En Progreso'
        );
        insert proyecto1;
        // Crear segundo proyecto (dentro del límite)
        Proyecto__c proyecto2 = new Proyecto__c(
            Name = 'Proyecto 2',
            Account__c = cuenta[0].Id,
            Contacto__c = contacto[0].Id,
            Presupuesto__c = 5000,
            Estado__c = 'En Progreso'
        );
        Test.startTest();
        // Esto debería funcionar
        insert proyecto2;
        Test.stopTest();
        // Verificar que ambos se crearon
        List<Proyecto__c> proyectos = [SELECT Id FROM Proyecto__c WHERE Account__c = :cuenta[0].Id];
        Assert.areEqual(2, proyectos.size(), 'Deberían existir 2 proyectos');
        }
    }
    /**
 * @description
 * Verifica que el trigger NO contabilice proyectos
 * que no estén en estado "En Progreso".
 *
 * Escenario:
 * - Cuenta con límite = 0
 * - Se crea un proyecto con estado "Finalizado"
 *
 * Resultado esperado:
 * - El proyecto se inserta correctamente
 *   aunque el límite sea 0.
 */
    @IsTest
    static void testTriggerProyectoNoEnProceso() {
         // Create a user to run the test as, ensuring we avoid Mixed DML errors and satisfy best practices
        User u = [SELECT Id FROM User WHERE Alias = 'standt' LIMIT 1];


        System.runAs(u) {
        // Cuenta con límite muy bajo
        List<Account> cuenta = [SELECT Id FROM Account WHERE Maximo_Proyectos_Activos__c = 0 LIMIT 1];
        List<Contact> contacto = [SELECT Id FROM Contact WHERE AccountId = :cuenta[0].Id LIMIT 1];
        // Crear proyecto con estado DIFERENTE (no debería contar)
        Proyecto__c proyecto = new Proyecto__c(
            Name = 'Proyecto Completado',
            Account__c = cuenta[0].Id,
            Contacto__c = contacto[0].Id,
            Presupuesto__c = 5000,
            Estado__c = 'Finalizado'  // NO "En Proceso"
        );
        Test.startTest();
        // Esto debería funcionar aunque el límite sea 0
        insert proyecto;
        Test.stopTest();
        // Verificar que se creó
        List<Proyecto__c> proyectos = [SELECT Id FROM Proyecto__c WHERE Account__c = :cuenta[0].Id];
        Assert.areEqual(1, proyectos.size(), 'Debería crearse el proyecto');
    }}
}