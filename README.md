CAMBIAR EL CSS

Cosas que no van:

- EN EL <div class="page" id="home">, <button>INFORMACIÓN DEL JUGADOR</button> Y <div class="icon-btn" onclick="" data-tooltip="Detalles del Jugador"> QUE ME SALGA EL MENÚ DE DETALLES DEL JUGADOR

- CAMBIAR EL MODEL DEL IR A:
# CONTEXTO TÉCNICO: DESARROLLO DE MAPA TÁCTICO PARA DP-ADMINMENU (FIVE-M)

**Contexto General:**
Estoy desarrollando un script de administración avanzado llamado "DP-AdminMenu" para servidores FiveM con framework QB-Core. El sistema de teletransporte (GOTO) actual utiliza listas de texto, y deseo reemplazarlo completamente por un "Mapa Táctico Interactivo" visual.

**Arquitectura del Proyecto:**
- Framework: QB-Core.
- Base de datos: oxmysql.
- Frontend: HTML5, CSS3 (Glassmorphism), JavaScript (Vanilla o Leaflet.js).
- Backend: Lua (Client/Server).
- Imagen del Mapa: `html/img/MAP.webp` (Mapa oscuro de GTA V).
- Rango de Coordenadas: X [-4000 a 4500], Y [-4000 a 8000].

**Objetivo de la Tarea:**
Reemplazar el modal `#goto-modal` por una interfaz de mapa interactivo que permita hacer Zoom y Arrastre (Drag). Al hacer clic en puntos específicos (Blips), se debe desplegar un panel lateral con información detallada y la opción de teletransporte.

**Requerimientos Detallados:**

1.  **Lógica de Posicionamiento (JS):**
    - Crear una función matemática para convertir coordenadas vectoriales de GTA V (X, Y) a porcentajes de CSS (Top%, Left%) para que los blips se posicionen de forma exacta sobre la imagen `MAP.webp` independientemente de la resolución.

2.  **Interfaz de Usuario (HTML/CSS):**
    - Rediseñar el modal `#goto-modal` para contener el div del mapa.
    - Implementar un panel lateral derecho (Info Panel) con efecto "Glassmorphism" (blur de fondo), que aparezca con una animación suave al seleccionar un punto.
    - El panel debe mostrar: Imagen del sitio, Título, Descripción y botones de "IR AL LUGAR" y "CERRAR".

3.  **Interactividad (JS):**
    - El mapa debe soportar Zoom con la rueda del ratón y desplazamiento arrastrando con el clic izquierdo.
    - Los Blips deben generarse dinámicamente desde un objeto JSON `gotoLocations`, usando iconos de Material Design Icons (MDI).

4.  **Integración FiveM (Lua):**
    - El botón "IR AL LUGAR" debe disparar un NUI Callback hacia `client/main_cl.lua`.
    - La lógica de teletransporte debe asegurar que el jugador aparezca en las coordenadas {x, y, z} correctas y cargar el mapeado circundante.

5.  **Estructura de Datos Sugerida (Config.lua):**
    ```lua
    Config.GotoLocations = {
        ["MAPEOS"] = {
            { name = "Búnker", coords = vector3(2100.0, 3000.0, 50.0), icon = "mdi-shield", img = "bunker.jpg", description = "Base subterránea de alta seguridad." },
        },
    }
    ```

**Tarea a Realizar:**
Genera el código completo y actualizado para:
1.  **html/index.html**: Nueva estructura del modal y panel lateral.
2.  **html/style.css**: Animaciones de entrada/salida, diseño del mapa y estilos del panel.
3.  **html/script.js**: Lógica de conversión de coordenadas, manejo de zoom/drag y callbacks.
4.  **client/main_cl.lua**: Recepción del callback y ejecución de `SetEntityCoords`.
5.  **config.lua**: Ejemplo de la nueva tabla de ubicaciones con las propiedades `img` y `description`.

*Nota: Prioriza un acabado visual extremadamente profesional y moderno, con animaciones fluidas para cada interacción.*