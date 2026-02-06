CAMBIAR EL CSS

Cosas que no van:

- EN EL <div class="page" id="home">, <button>INFORMACIÓN DEL JUGADOR</button> Y <div class="icon-btn" onclick="" data-tooltip="Detalles del Jugador"> QUE ME SALGA EL MENÚ DE DETALLES DEL JUGADOR

- Hacer que el mensaje de arriba de SISTEMA (ANNOUNCE) QUE TENGA ANIMACION AL APARECER/DESAPARECER DE REBOTE DESDE LA PARTE SUPERIOR DE LA PANTALLA, QUE TENGA UN POQUITO DE TRANSPARENCIA Y METERLE UN SONIDO PARA QUE SE ENTERE TODO EL MUNDO...

- CAMBIAR EL MODEL DEL IR A:
  Contexto del Proyecto: Estoy desarrollando un menú administrativo para un servidor de GTA V (FiveM) usando HTML, CSS y JS. Actualmente tengo un sistema de teletransporte basado en listas de texto (categorías y destinos), pero quiero evolucionarlo a un Mapa Táctico Interactivo. La estructura del proyecto es:
  html/index.html, html/script.js, html/style.css (Interfaz NUI).
  client/main_cl.lua (Lógica de FiveM para teletransporte).
  fxmanifest.lua y config.lua.

Objetivo: Quiero transformar el actual modal de teletransporte (que lo tengo de manera que es listas de categorías y destinos) en un Mapa Táctico Interactivo usando la imagen MAP.webp. Al hacer clic en puntos específicos (blips) del mapa, debe aparecer un panel lateral de información detallada.

Recursos Proporcionados:
Imagen del Mapa: Un mapa negro de GTA V con coordenadas que van aproximadamente desde x: -4000, y: -4000 hasta x: 4500, y: 8000.
Estructura de Datos (JSON): Utilizo un objeto gotoLocations con categorías. Cada entrada tiene name, coords {x, y, z} e icon (MDI).

Requerimientos de Integración:
HTML (index.html): Debes proponer una reestructuración del div #goto-modal. En lugar de los paneles actuales, debe haber un contenedor para el mapa con soporte para zoom/arrastre y un panel lateral derecho para la información del destino.
CSS (style.css): Necesito un diseño estilo "Admin Dashboard" moderno. El panel de información debe estar fuera del cuadro principal del mapa, con efectos de desenfoque (backdrop-filter) y animaciones de entrada.
JS (script.js): - Implementar la lógica para dibujar blips sobre el mapa convirtiendo coordenadas de GTA V (x, y) a porcentajes de la imagen.
Manejar el evento click en los blips para rellenar el panel de detalles (Nombre, Descripción, Imagen).
El botón "IR AL LUGAR" debe enviar un NUICallback hacia el cliente de FiveM con las coordenadas seleccionadas.
Lua (main_cl.lua): Asegúrate de que el código JS sea compatible con el callback que ya procesa el teletransporte en el script original.

Requerimientos Técnicos:
Conversión de Coordenadas: Necesito una función en JavaScript que convierta las coordenadas (x, y) del juego en porcentajes de CSS (top y left) para posicionar los blips sobre la imagen del mapa de forma precisa.Interfaz del Mapa:El contenedor del mapa debe permitir Zoom y Arrastre (Drag) para navegar por la isla.Los blips deben renderizarse dinámicamente sobre el mapa usando los iconos MDI especificados en mis datos.Panel de Detalles (Modal Derecho):Al hacer clic en un blip, se debe abrir un panel elegante a la derecha (fuera del menú principal).Este panel debe mostrar: Una imagen del lugar (basada en una nueva propiedad img en los datos), el Título, una Descripción detallada y dos botones: "IR AL LUGAR" (que ejecute la función de teletransporte) y "CERRAR".
Estética: El diseño debe ser moderno, con fondos translúcidos (glassmorphism), bordes redondeados y animaciones suaves de entrada para el panel lateral y al salir, animaciones para practicamente TODO.

Datos de Ubicaciones: Utilizaré el objeto gotoLocations que ya tengo definido (con categorías como "MAPEOS", "ILEGAL", etc.). Debes añadir soporte para dos nuevas propiedades en cada destino: img (ruta de imagen) y description (texto informativo).

Tarea: Genera el código necesario para client.lua, server.lua, config.lua, dpadmin.sql, index.html, script.js y style.css que reemplace el sistema de listas por este mapa interactivo. El mapa debe sentirse fluido y profesional, permitiendo al administrador ver visualmente dónde se va a teletransportar antes de confirmar. (OVBIAMENTE ESTO SOLO PUEDE ACCEDER LOS ADMINISTRADORES, AUNQUE AL MENÚ DEL DP-AdminMenu EN TEORIA SOLO PUEDEN ACCEDER MODS/ADMINS/STAFF/OWNERS)

ESTRUCTURA:
DP-AdminMenu:
├── 📁 client
│ └── 📄 main_cl.lua
├── 📁 html
│ ├── 🌐 index.html
│ ├── 📄 script.js
│ └── 🎨 style.css
├── 📁 server
│ └── 📄 main_sv.lua
├── 🖼️ Captura de pantalla 2026-02-06 034209.png
├── 🖼️ Captura de pantalla 2026-02-06 034250.png
├── 📝 README.md
├── 📄 config.lua
├── 📄 dpadmin.sql
└── 📄 fxmanifest.lua

💡 Consejos para cuando lo use:
Añade tus datos: Cuando pegues este prompt, pega debajo el objeto gotoLocations completo que hemos actualizado hoy para que la IA sepa qué puntos tiene que dibujar.

Librerías: Si la IA te pregunta, dile que prefieres usar JS nativo para el zoom/drag o una librería ligera como Leaflet.js si quieres algo muy profesional.

Imágenes: Recuerda que para que el panel de la derecha funcione, tendrás que tomar fotos dentro del juego de cada lugar y guardarlas en una carpeta (ej: img/ubicaciones/bunker.jpg).

- MEJORAR EL SISTEMA DE REPORTES, YA QUE QUIERO QUE PUEDAN METER IMAGENES EN UN REPORTE CON LO DE CNTR+V... tal y como está el del chat de administradores, con el BOT DE DISCORD...

