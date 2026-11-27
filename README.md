# Steel Fused Solutions and SS Metal Foundry

Sistema de producción en Laravel 13, PHP 8.3+ y MySQL/MariaDB. Interfaz Blade con CSS y JavaScript propios, paleta industrial oscura, roja y naranja. No requiere Node ni un servidor Express para funcionar.

## Inicio en este equipo

1. Mantener MySQL de XAMPP iniciado (puerto 3306).
2. Ejecutar `iniciar_sistema.bat`.
3. Abrir <http://127.0.0.1:8002>.
4. Consultar `storage/app/acceso-local.txt` para el acceso inicial. El archivo y `.env` están excluidos de Git. Cambiar la contraseña desde Usuarios después del primer acceso.

La instalación local utiliza la base **ssmf_laravel**, independiente de GIS (`saavdranew2`) y de la base del prototipo (`ssmf_db`). El respaldo completo del repositorio original está en la carpeta hermana `SS_Metal_Foundry_backups`. El historial Git se conserva en el repositorio actual.

`instalar_dependencias.bat` instala Composer, crea la base si falta, ejecuta migraciones incrementales y catálogos, importa el backlog sin duplicarlo y crea un administrador si no existe. No borra tablas. Requiere que PHP y Composer estén en PATH y que MySQL esté iniciado. Si PHP de Windows no tiene `pdo_mysql` habilitado, los lanzadores cargan su DLL mediante una configuración local en `storage/app/php-conf`, sin editar el PHP global ni GIS.

## Funcionalidad

- Login real, sesiones, cierre de sesión por POST, protección CSRF, limitación de intentos y usuarios inactivos.
- Backlog de ancho completo, búsqueda por cliente/producto/código/compra, filtros por empresa, tipo de pedido, proceso, programación y rango de fechas.
- Pedidos de fundición **PF** y pedidos de modelo **PM** separados. Los modelos pueden trabajar por piezas sin peso ni horno.
- Programación manual por año y semana ISO. La lista presenta el periodo por fechas; no muestra grupos ni selectores de números de semana. Los pedidos nuevos quedan sin asignar si se dejan vacíos ambos campos.
- Órdenes de compra con números interior y exterior, cliente, empresa, fecha de compra y compromiso. Una compra puede tener varias partidas.
- Catálogos editables de clientes, materiales, productos, compras y cinco niveles de fundición.
- Productos identificados por ID. El código interno puede repetirse entre variantes con diferente descripción o material, como sucede en la fuente original; la combinación código + nombre + material es única.
- Material, peso, maquinado y cantidades del pedido son datos de la partida, para conservar la especificación del trabajo aunque se actualice el catálogo.
- OTs **internas OTI** y **externas OTE**, con serie independientes por empresa y año: `SSMF-OTI-2026-00001`, `SFS-OTE-2026-00001`.
- Folios generados en transacción con bloqueo; no se reservan en pantalla ni se reutiliza un folio para sobrescribir una OT existente.
- Coladas parciales: el peso de una OT no puede superar el pendiente ni la capacidad del horno. Solo una OT activa por pedido y por horno.
- Avance manual con historial de fecha, usuario, fase y observaciones. Al terminar se descuenta el peso o las piezas y se libera el horno en una misma transacción.
- Terminadas con tiempo real, tiempo estimado y cumplimiento contra la fecha de compromiso. El cumplimiento queda sin evaluar si no hay fecha.
- Inspecciones de calidad con C, Si, Mn, P, S, porosidad, dictamen y responsable. No se inventan resultados ni certificaciones.
- CSV de los registros reales e impresión HTML que permite guardar PDF desde el navegador. La impresión incluye los registros del filtro, sin limitarse a la página visible.

Las temperaturas se capturan manualmente. La aplicación no está conectada a sensores, PLC ni espectrómetro y no genera recomendaciones metalúrgicas automáticas. Las gráficas y recomendaciones ficticias del prototipo quedan en el respaldo original.

## Roles

| Rol | Alcance |
|---|---|
| Administrador | Catálogos, pedidos, programación, OTs, hornos, calidad y usuarios |
| Supervisor | Catálogos, pedidos, programación, OTs, hornos y calidad |
| Operador | Consulta, creación y avance de OTs |
| Calidad | Consulta e inspecciones |
| Consulta | Lectura de backlog, proceso, terminadas y reportes |

Ambas empresas comparten el sistema y los catálogos. La empresa de adscripción del usuario es informativa; no establece aislamiento de datos entre empresas. La empresa del pedido se obtiene de su compra y determina el prefijo del código.

## Datos importados y decisiones pendientes

- 70 partidas originales, 17,235 kg pendientes; una partida de modelo en madera se clasifica como modelo.
- La fuente no identifica la empresa de cada partida: la importación inicial usa **SSMF**. La empresa debe confirmarse al revisar las compras; la empresa y el cliente se pueden corregir mientras no haya OTs. Al cambiar de empresa se regeneran los folios de sus pedidos. Una compra con OTs conserva su empresa y cliente.
- No se asignan semanas ni niveles de fundición automáticamente. Los niveles se llaman Nivel 1 a Nivel 5 hasta que se confirmen sus nombres.
- Se conservan las fechas y estados del archivo original. Algunos pedidos antiguos tienen cero peso o datos incompletos; la importación los conserva y las nuevas altas validan los campos necesarios.
- La antigua interfaz tenía seis OTs de demostración en código. No se convierten en producción real ni en resultados de calidad. El respaldo conserva esas muestras completas. No se encontró una base `ssmf_db` local para migrar movimientos reales.
- No se copian las asociaciones inconsistentes de hornos del prototipo. Los hornos A y B comienzan disponibles; C, en mantenimiento.

## Base de datos y SQL

El archivo **`database/sql/ssmf_laravel.sql`** contiene el esquema real con llaves foráneas y datos iniciales del backlog. Seleccionar una **base nueva y vacía** en phpMyAdmin e importar el archivo. No contiene usuarios, contraseñas, sesiones ni registros de pruebas. Después configurar `.env` y ejecutar `php artisan key:generate` y `php artisan foundry:admin` para crear el administrador.

En la instalación de este equipo la base **ya está creada e importada**: no se necesita volver a importar SQL. Para actualizarla se utilizan migraciones, no el archivo SQL inicial.

La estructura se describe en [database/SCHEMA.md](database/SCHEMA.md).

## Comandos

```powershell
# Usar esta función si el PHP global no carga pdo_mysql
. .\tools\runtime.ps1
Invoke-ProjectPhp artisan migrate --force
Invoke-ProjectPhp artisan db:seed --force
Invoke-ProjectPhp artisan foundry:import-backlog
Invoke-ProjectPhp artisan foundry:admin usuario@empresa.com
Invoke-ProjectPhp artisan test --compact
Invoke-ProjectPhp tools/data-check.php
```

Las pruebas utilizan SQLite en memoria y no modifican MySQL. Para exportar nuevamente el SQL inicial: `Invoke-ProjectPhp tools/export-sql.php`. Este exportador omite usuarios y movimientos de producción; no sustituye un respaldo completo de MySQL.

## Organización del código

| Ruta | Responsabilidad |
|---|---|
| `routes/web.php` | Rutas con autenticación y CSRF |
| `app/Http/Controllers` | Solicitudes, validaciones y autorización por rol |
| `app/Models` | Entidades y relaciones Eloquent |
| `app/Services/WorkOrderFlow.php` | Creación, avance y finalización transaccional |
| `app/Services/DocumentCode.php` | Consecutivos por empresa, serie y año |
| `app/Console/Commands` | Importación idempotente y creación de administrador |
| `database/migraciones` | Evolución del esquema |
| `database/seeders` | Empresas, estados, hornos y catálogos base |
| `database/data/backlog.json` | Partidas originales conservadas para importación |
| `resources/views` | Pantallas Blade |
| `public/css/foundry.css` | Diseño adaptable y estilos de impresión |
| `public/js/foundry.js` | Reloj y ayudas del formulario |
| `tools` | Instalación, arranque, comprobación y exportación SQL |
| `tests/Feature/FoundryFlowTest.php` | Flujos, permisos, validaciones e importación |

Para producción, servir únicamente `public/`, configurar HTTPS, establecer `APP_DEBUG=false` y usar una cuenta MySQL propia. El `.env` actual es de desarrollo local.

## Qu? inicia cada componente

- MySQL/MariaDB almacena las tablas y datos en disco. Debe estar iniciado para consultar el sistema.
- XAMPP es una forma de instalar y arrancar MySQL; tambi?n puede usarse MySQL instalado como servicio sin XAMPP.
- `iniciar_sistema.bat` comprueba la conexi?n y las migraciones, y arranca el servidor de Laravel. No enciende MySQL, no recrea tablas ni importa datos.
- `instalar_dependencias.bat` s? ejecuta las migraciones pendientes y la carga inicial de cat?logos y backlog, sin duplicarlos.
- El navegador ejecuta JavaScript y carga los estilos. No hay un servidor Node/Vite en este proyecto.
- Apache de XAMPP no es necesario al usar `php artisan serve` en el puerto 8002.

Apagar MySQL o cerrar Laravel no borra los datos. Las tablas ya creadas se conservan en la base `ssmf_laravel`. El archivo SQL es una exportaci?n para una instalaci?n nueva; no se ejecuta por abrirlo en el editor ni al arrancar el sistema.
