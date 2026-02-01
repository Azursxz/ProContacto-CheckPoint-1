# Proyecto CheckPoint 1

## 1: Modelado de objetos

![Modelado Objetos](https://github.com/Azursxz/ProContacto-CheckPoint-1/raw/main/Modelado%20Objetos.png)


## 2: Automatizaciones

### Presupuesto promedio proyectos estado "En progreso"

Creamos 2 roll-up summary:
- `Cantidad de proyectos en proceso` que cuenta la cantidad de proyectos con el estado `En Progreso`
- `Presupuesto total proyectos en proceso` que suma el presupuesto de todos los proyectos con el estado `En Progreso`

Y luego los usamos en un campo formula `Presupuesto promedio proyecto en proceso` que calcula el promedio


### Eliminar proyectos iniciados hace mas de 1 año con estado "Planeado"

Para este ejercicio creamos un record-triggered flow asociado al objeto `Proyecto` 
`Proyecto [RTF] | (DEL) - (FFU) | Eliminacion proyectos planeados luego de 1 año`

### Evitar que se supere limite maximo de proyectos asociados a cuenta con estado "En progreso"

Para este ejercicio utilizamos el roll-up summary que creamos en el ejercicio 1  `Cantidad de proyectos en proceso`
junto con el campo `Maximo proyectos activos` y a estos los usamos en la validation rule `Validacion_cantidad_maxima_de_procesos` asociada a `Proyecto`

### Actualizar campo Descripcion del contacto

Para este ejercicio realizamos un record-triggered flow asociado a `Contact`
`Contact [RTF] | (COU)-(ARR) | Actualizar Descripcion`


## 3: Comunicacion entre componentes

![Comunicacion entre componentes](https://github.com/Azursxz/ProContacto-CheckPoint-1/blob/main/comunicacion.drawio.png)


## 4: Creacion App "CheckPoint 1"

Para poder realizar este ejercicio vamos a `setup` -> `Lightning Experience App Manager` -> `New Lightning App` 
en la cual agregamos las Tabs que nos pide el ejercicio

Para agregar el `related list` a `Accounts` y `Contacts` vamos a
`setup`-> `object manager` -> seleccionamos el objeto -> `page layouts` y agregamos proyectos en el apartado de `related list`




