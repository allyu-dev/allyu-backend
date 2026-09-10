Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.IO.Compression

$output = Join-Path $PSScriptRoot 'Especificacion_Tecnica_Allyu_v1.docx'
$work = Join-Path $env:TEMP ('allyu-docx-' + [Guid]::NewGuid().ToString())
New-Item -ItemType Directory -Path "$work\_rels", "$work\word\_rels", "$work\docProps" -Force | Out-Null

function E([string]$value) { [System.Security.SecurityElement]::Escape($value) }
function RenderRun([string]$text, [bool]$bold = $false) {
  $b = if ($bold) { '<w:b/>' } else { '' }
  "<w:r><w:rPr>$b</w:rPr><w:t xml:space=`"preserve`">$(E $text)</w:t></w:r>"
}
function P([string]$text, [string]$style = 'Normal', [bool]$bold = $false) {
  "<w:p><w:pPr><w:pStyle w:val=`"$style`"/></w:pPr>$(RenderRun $text $bold)</w:p>"
}
function Bullet([string]$text) {
  "<w:p><w:pPr><w:numPr><w:ilvl w:val=`"0`"/><w:numId w:val=`"1`"/></w:numPr></w:pPr>$(RenderRun $text)</w:p>"
}
function Table([object[]]$rows, [int[]]$widths) {
  $grid = ($widths | ForEach-Object { "<w:gridCol w:w=`"$_`"/>" }) -join ''
  $body = for ($r = 0; $r -lt $rows.Count; $r++) {
    $row = $rows[$r]
    $isHeader = $r -eq 0
    $cells = for ($i = 0; $i -lt $row.Count; $i++) {
      $fill = if ($isHeader) { '<w:shd w:val="clear" w:fill="E8EEF5"/>' } else { '' }
      "<w:tc><w:tcPr><w:tcW w:w=`"$($widths[$i])`" w:type=`"dxa`"/>$fill</w:tcPr>$(P ([string]$row[$i]) 'TableText' $isHeader)</w:tc>"
    }
    "<w:tr>$($cells -join '')</w:tr>"
  }
  "<w:tbl><w:tblPr><w:tblW w:w=`"9360`" w:type=`"dxa`"/><w:tblLayout w:type=`"fixed`"/><w:tblBorders><w:top w:val=`"single`" w:sz=`"4`" w:color=`"D9E2F3`"/><w:left w:val=`"single`" w:sz=`"4`" w:color=`"D9E2F3`"/><w:bottom w:val=`"single`" w:sz=`"4`" w:color=`"D9E2F3`"/><w:right w:val=`"single`" w:sz=`"4`" w:color=`"D9E2F3`"/><w:insideH w:val=`"single`" w:sz=`"4`" w:color=`"D9E2F3`"/><w:insideV w:val=`"single`" w:sz=`"4`" w:color=`"D9E2F3`"/></w:tblBorders><w:tblCellMar><w:top w:w=`"80`" w:type=`"dxa`"/><w:start w:w=`"120`" w:type=`"dxa`"/><w:bottom w:w=`"80`" w:type=`"dxa`"/><w:end w:w=`"120`" w:type=`"dxa`"/></w:tblCellMar></w:tblPr><w:tblGrid>$grid</w:tblGrid>$($body -join '')</w:tbl>"
}

$body = @()
$body += P 'ESPECIFICACION TECNICA' 'Kicker' $true
$body += P 'Allyu' 'Title' $true
$body += P 'Backend para aprendizaje de ingles tecnico en perfiles de TI' 'Subtitle'
$body += P 'Version 1.0 | Alcance factible para MVP | 31 de agosto de 2026' 'Meta'
$body += P 'Resumen ejecutivo' 'Heading1'
$body += P 'Allyu es una plataforma de microaprendizaje de ingles tecnico dirigida a personas que trabajan o se preparan para trabajar en TI. El MVP debe resolver un recorrido completo y medible: autenticar al usuario, asignar su perfil tecnico y nivel, entregar una leccion basada en un escenario real, registrar progreso y mostrar avance. La IA se usara como generador controlado y con cache; no como fuente de datos sin persistencia.'
$body += P 'Estado actual del repositorio' 'Heading2'
$body += Table @(
  @('Area','Estado','Decision de alcance'),
  @('Servidor Express, TypeScript y ESM','Implementado','Conservar y consolidar configuracion.'),
  @('Firebase Admin y Firestore','Implementado','Mantener para MVP; usar variables de entorno en despliegue.'),
  @('Modulo User: crear y consultar','Implementado parcialmente','Proteger con token Firebase y eliminar UID libre del body.'),
  @('Roles, lecciones y ejercicios','Entidades vacias','Implementar como siguientes modulos.'),
  @('Gemini AI','Dependencia instalada','Integrar despues de cache y validacion de esquema.'),
  @('Pruebas, CI/CD, Docker','Pendiente','Incorporar al cerrar el flujo principal.')
) @(2600,2400,4360)

$body += P '1. Objetivo y limites del MVP' 'Heading1'
$body += P 'El MVP no intenta construir una plataforma educativa completa. Su objetivo es validar que un usuario pueda recibir contenido relevante de ingles tecnico y avanzar mediante ejercicios cortos.'
$body += Bullet 'Registro y sincronizacion segura del perfil desde Firebase Authentication.'
$body += Bullet 'Seleccion de rol tecnico y nivel inicial mediante una evaluacion corta y determinista.'
$body += Bullet 'Catalogo inicial de roles y escenarios curados por el equipo.'
$body += Bullet 'Entrega de lecciones cacheadas; Gemini solo se consulta cuando falte una combinacion requerida.'
$body += Bullet 'Registro de intentos y progreso por usuario, con XP y racha calculados en el backend.'
$body += P 'Fuera del MVP: chat libre con IA, red social, pagos, ranking global, recomendaciones complejas y generacion ilimitada en tiempo real.'

$body += P '2. Arquitectura propuesta' 'Heading1'
$body += P 'Se adopta una Clean Architecture pragmatica. La regla central es que dominio y casos de uso no deben importar Express, Firestore, Firebase ni Gemini. Las capas externas dependen de las internas, nunca al reves.'
$body += Table @(
  @('Capa','Responsabilidad','Ejemplos'),
  @('Presentation','HTTP, rutas, DTOs, respuestas y middleware.','routes, controllers, AuthMiddleware, validation.'),
  @('Application','Orquesta reglas de negocio por caso de uso.','SyncUser, EvaluatePlacement, GetNextLesson, SaveProgress.'),
  @('Domain','Entidades, tipos y contratos independientes.','User, Role, Lesson, Exercise, IUserRepository.'),
  @('Infrastructure','Implementaciones tecnicas y servicios externos.','Firestore repositories, Firebase Admin, Gemini adapter.')
) @(1800,3900,3660)
$body += P 'Flujo de una solicitud protegida' 'Heading2'
$body += P 'Flutter o Postman -> ruta Express -> AuthMiddleware valida Bearer token -> controller valida DTO -> caso de uso -> interfaz de repositorio o servicio -> adaptador Firestore/Gemini -> respuesta JSON. El UID siempre se obtiene del token verificado, no del body ni de un parametro confiado al cliente.'
$body += P 'Estructura de carpetas objetivo' 'Heading2'
$body += P 'src/domain/{entities,repositories,services}; src/application/{dtos,use-cases}; src/infrastructure/{database/firestore,external/gemini,firebase}; src/presentation/{controllers,middlewares,routes,validators}; src/config para composicion de dependencias; tests/{unit,integration}.'

$body += P '3. Modulos y casos de uso' 'Heading1'
$body += Table @(
  @('Modulo','Casos de uso del MVP','Resultado'),
  @('Auth y usuario','SyncUser, GetMyProfile, UpdateProfile','Perfil asociado al UID real.'),
  @('Catalogo','ListRoles, GetRole','Roles tecnicos disponibles.'),
  @('Placement','EvaluatePlacementTest','Nivel A1, A2, B1 o B2 y rol seleccionado.'),
  @('Lecciones','GetNextLesson, GetLessonById','Leccion desde cache o generada y validada.'),
  @('Progreso','SubmitExerciseAttempt, CompleteLesson, GetProgress','Puntaje, XP, racha y avance persistido.')
) @(1900,3700,3760)
$body += P 'Regla de responsabilidad' 'Heading2'
$body += P 'El controller no crea repositorios directamente. La aplicacion debe tener un punto de composicion, por ejemplo src/config/container.ts, que instancia FirestoreUserRepository y lo inyecta en los casos de uso. Esto permite pruebas unitarias con repositorios falsos y evita acoplamiento de HTTP con Firestore.'

$body += P '4. Seguridad y autenticacion' 'Heading1'
$body += P 'Todas las rutas que lean o modifiquen informacion personal deben requerir Authorization: Bearer <Firebase ID Token>. AuthMiddleware usa firebase-admin para verificar el token y adjunta uid y email autenticados a req.auth.'
$body += Bullet 'POST /users no debe aceptar un id libre para crear perfiles en produccion.'
$body += Bullet 'GET /users/:id debe limitarse al propio UID o a una funcion administrativa autorizada.'
$body += Bullet 'La cuenta de servicio no se versiona; serviceAccountKey.json queda fuera de Git.'
$body += Bullet 'El backend valida DTOs, limites de tamanio, enum, tipos y permisos antes de acceder a Firestore.'
$body += Bullet 'Las respuestas 500 no exponen mensajes internos, claves ni detalles de Firebase.'

$body += P '5. Modelo de datos Firestore' 'Heading1'
$body += P 'Firestore no tiene foreign keys. La integridad se controla en los casos de uso y con identificadores consistentes. Se recomienda IDs legibles para catalogos y UID de Firebase para users.'
$body += Table @(
  @('Coleccion','Documento y campos principales','Uso'),
  @('users','{uid}: email, displayName?, roleId?, englishLevel?, xp, streak, lastActivityDate?, createdAt, updatedAt','Perfil y resumen de avance.'),
  @('roles','{roleId}: name, description, iconKey, isActive, order','Catalogo curado de perfiles TI.'),
  @('roadmaps','{roleId_level}: roleId, level, scenarioIds, version, updatedAt','Ruta por rol y nivel.'),
  @('lessons','{role_level_scenario_version}: roleId, level, scenarioId, content, source, schemaVersion, createdAt','Cache reutilizable de contenido.'),
  @('users/{uid}/progress','{lessonId}: lessonId, status, bestScore, attempts, completedAt, updatedAt','Progreso privado y consulta eficiente.'),
  @('users/{uid}/attempts','{attemptId}: lessonId, exerciseId, answer, isCorrect, score, createdAt','Historial; no guardar respuestas correctas del cliente.')
) @(1800,5100,2460)
$body += P 'Diseño de leccion recomendado' 'Heading2'
$body += P 'Una leccion contiene metadata (roleId, level, scenarioId, version), objetivo de aprendizaje, vocabulario y una lista de ejercicios. Cada ejercicio contiene id, type, prompt, options cuando aplique, answerKey solo para el backend, explanation y puntos. En una respuesta al cliente se omite answerKey.'
$body += P 'Indices iniciales' 'Heading2'
$body += Bullet 'lessons: roleId + level + scenarioId + schemaVersion.'
$body += Bullet 'roadmaps: roleId + level.'
$body += Bullet 'users/{uid}/progress: status + updatedAt, si se lista por estado.'
$body += Bullet 'Los indices exactos se crean solo cuando una consulta compuesta de Firestore los solicite; documentarlos en firestore.indexes.json.'

$body += P '6. Gemini AI: generacion controlada y cache' 'Heading1'
$body += P 'Gemini se integra mediante una interfaz ILessonGenerator. GetNextLesson primero busca una leccion con la clave de cache roleId + level + scenarioId + schemaVersion. Si existe, la devuelve. Si no existe, solicita JSON estructurado a Gemini, valida el resultado con un esquema, persiste la leccion y la retorna.'
$body += Table @(
  @('Control','Regla'),
  @('Entrada','Prompt con rol, nivel, escenario, idioma de instrucciones y limite de ejercicios.'),
  @('Salida','JSON estricto; validacion antes de guardar.'),
  @('Cache','Una sola leccion versionada por clave de contenido.'),
  @('Costo','Limite de solicitudes por usuario/dia y reuso de cache.'),
  @('Calidad','Escenarios iniciales curados y prueba manual de cada plantilla de prompt.'),
  @('Fallo','Si Gemini falla y no hay cache, devolver error controlado 503; no inventar contenido.')
) @(2200,7160)

$body += P '7. API REST del MVP' 'Heading1'
$body += Table @(
  @('Metodo','Ruta','Autorizacion','Proposito'),
  @('GET','/health','No','Verifica disponibilidad del servicio.'),
  @('POST','/api/v1/users/sync','Bearer','Crea o sincroniza el perfil del UID autenticado.'),
  @('GET','/api/v1/users/me','Bearer','Devuelve perfil propio.'),
  @('PATCH','/api/v1/users/me','Bearer','Actualiza campos permitidos: rol o preferencias.'),
  @('GET','/api/v1/roles','Bearer','Lista roles activos.'),
  @('POST','/api/v1/placement/evaluate','Bearer','Evalua respuestas y persiste nivel.'),
  @('GET','/api/v1/lessons/next','Bearer','Obtiene siguiente leccion para el usuario.'),
  @('POST','/api/v1/lessons/:lessonId/attempts','Bearer','Registra intento validado por backend.'),
  @('POST','/api/v1/lessons/:lessonId/complete','Bearer','Cierra leccion y actualiza progreso.')
) @(900,3000,1500,3960)
$body += P 'Convenciones HTTP' 'Heading2'
$body += P 'Usar 200 para lecturas y sincronizacion existente, 201 al crear un recurso, 204 para acciones sin body, 400 para DTO invalido, 401 sin token, 403 sin permiso, 404 no encontrado, 409 para conflicto de estado, 429 para limite y 500/503 para fallos internos o de dependencia. Definir un formato uniforme: { error: { code, message, details? } }.'

$body += P '8. Plan de implementacion factible' 'Heading1'
$body += Table @(
  @('Fase','Entregable','Criterio de terminado'),
  @('0. Base tecnica','Prettier, ESLint, .env.example, logger, manejo global de errores.','npm run build y pruebas base pasan.'),
  @('1. Usuario seguro','AuthMiddleware, /users/sync y /users/me.','Un token real solo accede a su propio perfil.'),
  @('2. Catalogo y placement','Roles seed, evaluacion corta y roadmap asignado.','Usuario obtiene roleId y englishLevel validos.'),
  @('3. Lecciones sin IA','Lecciones seed y progreso.','Recorrido completo reproducible sin costo de IA.'),
  @('4. Gemini con cache','ILessonGenerator, esquema, cache, limites.','Generacion solo ante cache miss y contenido valido.'),
  @('5. Calidad y despliegue','Tests, CI, Docker, observabilidad y entorno productivo.','Despliegue repetible con secretos fuera del codigo.')
) @(1200,4200,3960)

$body += P '9. Calidad, pruebas y operacion' 'Heading1'
$body += Bullet 'Pruebas unitarias: casos de uso con repositorios y generador falsos.'
$body += Bullet 'Pruebas de integracion: rutas Express con Firebase Emulator o proyecto de prueba aislado.'
$body += Bullet 'Contrato de API: coleccion Postman o especificacion OpenAPI versionada.'
$body += Bullet 'CI: npm ci, format:check, typecheck, test y build en cada pull request.'
$body += Bullet 'Observabilidad: requestId, logs JSON sin datos sensibles, errores reportados y health check.'
$body += Bullet 'Backups y datos: exportacion programada de Firestore antes de cambios de esquema relevantes.'

$body += P '10. Riesgos y decisiones pendientes' 'Heading1'
$body += Table @(
  @('Riesgo o decision','Mitigacion o definicion requerida'),
  @('Costo y variabilidad de IA','Cache, cuotas, version de prompt y contenido seed como respaldo.'),
  @('Respuestas correctas expuestas','No enviar answerKey; validar intentos en backend.'),
  @('Reglas Firestore','Definir si Flutter accede directo a Firestore. Para este MVP se recomienda solo backend para datos de progreso y lecciones.'),
  @('Racha','Definir zona horaria de negocio y regla exacta: una leccion completada por dia.'),
  @('Contenido por voz','Mantener audio/speaking fuera de la primera fase o integrar proveedor separado con requisitos claros.'),
  @('Privacidad','Definir retencion de intentos, eliminacion de cuenta y datos que nunca se mandan a Gemini.')
) @(3000,6360)

$body += P 'Cierre' 'Heading1'
$body += P 'La arquitectura es viable si se construye por verticales: primero usuario seguro, luego catalogo y placement, despues lecciones y progreso sin IA, y finalmente Gemini con cache. Esta secuencia evita que la complejidad de IA o de gamificacion bloquee la validacion del producto principal.'

$section = '<w:sectPr><w:headerReference w:type="default" r:id="rId1"/><w:footerReference w:type="default" r:id="rId2"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="708" w:footer="708"/></w:sectPr>'
$document = "<?xml version=`"1.0`" encoding=`"UTF-8`" standalone=`"yes`"?><w:document xmlns:w=`"http://schemas.openxmlformats.org/wordprocessingml/2006/main`" xmlns:r=`"http://schemas.openxmlformats.org/officeDocument/2006/relationships`"><w:body>$($body -join '')$section</w:body></w:document>"

$styles = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?><w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="Calibri" w:hAnsi="Calibri"/><w:sz w:val="22"/></w:rPr></w:rPrDefault></w:docDefaults><w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:pPr><w:spacing w:after="120" w:line="264" w:lineRule="auto"/></w:pPr></w:style><w:style w:type="paragraph" w:styleId="Title"><w:name w:val="Title"/><w:rPr><w:b/><w:color w:val="0B2545"/><w:sz w:val="52"/></w:rPr><w:pPr><w:spacing w:before="240" w:after="80"/></w:pPr></w:style><w:style w:type="paragraph" w:styleId="Kicker"><w:name w:val="Kicker"/><w:rPr><w:color w:val="2E74B5"/><w:sz w:val="22"/></w:rPr><w:pPr><w:spacing w:before="120" w:after="40"/></w:pPr></w:style><w:style w:type="paragraph" w:styleId="Subtitle"><w:name w:val="Subtitle"/><w:rPr><w:color w:val="4F5B66"/><w:sz w:val="28"/></w:rPr><w:pPr><w:spacing w:after="100"/></w:pPr></w:style><w:style w:type="paragraph" w:styleId="Meta"><w:name w:val="Meta"/><w:rPr><w:color w:val="667085"/><w:sz w:val="18"/></w:rPr><w:pPr><w:spacing w:after="280"/></w:pPr></w:style><w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:rPr><w:b/><w:color w:val="2E74B5"/><w:sz w:val="32"/></w:rPr><w:pPr><w:keepNext/><w:spacing w:before="300" w:after="140"/></w:pPr></w:style><w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:rPr><w:b/><w:color w:val="1F4D78"/><w:sz w:val="26"/></w:rPr><w:pPr><w:keepNext/><w:spacing w:before="220" w:after="100"/></w:pPr></w:style><w:style w:type="paragraph" w:styleId="TableText"><w:name w:val="Table Text"/><w:basedOn w:val="Normal"/><w:rPr><w:sz w:val="18"/></w:rPr><w:pPr><w:spacing w:after="0" w:line="220" w:lineRule="auto"/></w:pPr></w:style></w:styles>
'@
$numbering = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><w:numbering xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:abstractNum w:abstractNumId="0"><w:lvl w:ilvl="0"><w:start w:val="1"/><w:numFmt w:val="bullet"/><w:lvlText w:val="•"/><w:lvlJc w:val="left"/><w:pPr><w:tabs><w:tab w:val="num" w:pos="720"/></w:tabs><w:ind w:left="720" w:hanging="360"/></w:pPr></w:lvl></w:abstractNum><w:num w:numId="1"><w:abstractNumId w:val="0"/></w:num></w:numbering>'
$header = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><w:hdr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:p><w:pPr><w:jc w:val="right"/></w:pPr><w:r><w:rPr><w:color w:val="667085"/><w:sz w:val="18"/></w:rPr><w:t>Allyu | Especificacion tecnica del backend</w:t></w:r></w:p></w:hdr>'
$footer = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:p><w:pPr><w:jc w:val="right"/></w:pPr><w:r><w:rPr><w:color w:val="667085"/><w:sz w:val="18"/></w:rPr><w:t>Allyu - Documento de trabajo | Pagina </w:t></w:r><w:fldSimple w:instr="PAGE"/></w:p></w:ftr>'
$contentTypes = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/><Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/><Override PartName="/word/numbering.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.numbering+xml"/><Override PartName="/word/header1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.header+xml"/><Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/><Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/></Types>'
$rels = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/></Relationships>'
$docRels = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/header" Target="header1.xml"/><Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Target="footer1.xml"/><Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/><Relationship Id="rId4" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/numbering" Target="numbering.xml"/></Relationships>'
$core = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><dc:title>Especificacion Tecnica Allyu v1</dc:title><dc:creator>Allyu</dc:creator><dcterms:created xsi:type="dcterms:W3CDTF">2026-08-31T00:00:00Z</dcterms:created></cp:coreProperties>'

[IO.File]::WriteAllText("$work\[Content_Types].xml", $contentTypes, [Text.UTF8Encoding]::new($false))
[IO.File]::WriteAllText("$work\_rels\.rels", $rels, [Text.UTF8Encoding]::new($false))
[IO.File]::WriteAllText("$work\word\document.xml", $document, [Text.UTF8Encoding]::new($false))
[IO.File]::WriteAllText("$work\word\styles.xml", $styles, [Text.UTF8Encoding]::new($false))
[IO.File]::WriteAllText("$work\word\numbering.xml", $numbering, [Text.UTF8Encoding]::new($false))
[IO.File]::WriteAllText("$work\word\header1.xml", $header, [Text.UTF8Encoding]::new($false))
[IO.File]::WriteAllText("$work\word\footer1.xml", $footer, [Text.UTF8Encoding]::new($false))
[IO.File]::WriteAllText("$work\word\_rels\document.xml.rels", $docRels, [Text.UTF8Encoding]::new($false))
[IO.File]::WriteAllText("$work\docProps\core.xml", $core, [Text.UTF8Encoding]::new($false))
if (Test-Path $output) { Remove-Item -LiteralPath $output -Force }
$stream = [IO.File]::Open($output, [IO.FileMode]::CreateNew)
$archive = [IO.Compression.ZipArchive]::new($stream, [IO.Compression.ZipArchiveMode]::Create)
try {
  Get-ChildItem -Path $work -Recurse -File | ForEach-Object {
    $relative = $_.FullName.Substring($work.Length + 1).Replace('\', '/')
    $entry = $archive.CreateEntry($relative, [IO.Compression.CompressionLevel]::Optimal)
    $entryStream = $entry.Open()
    $sourceStream = [IO.File]::OpenRead($_.FullName)
    try { $sourceStream.CopyTo($entryStream) } finally { $sourceStream.Dispose(); $entryStream.Dispose() }
  }
} finally {
  if ($null -ne $archive) { $archive.Dispose() }
  $stream.Dispose()
}
Remove-Item -LiteralPath $work -Recurse -Force
Write-Output $output
