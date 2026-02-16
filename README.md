Hacer funcionar los botones de BANEAR/KICK/WARN/CK del DETALLES DEL JUGADOR


# MEJORA TÉCNICA FINAL: EXPEDIENTE DE SANCIONES CON CONTADORES DINÁMICOS (DP-ADMINMENU)

**Contexto del Proyecto:**
Estoy desarrollando un sistema de "Expediente Criminal" dentro de mi script DP-AdminMenu (QB-Core). Quiero que al abrir el modal de "Detalles del Jugador", la sección de "HISTORIAL DE SANCIONES" muestre un resumen visual rápido y una lista cronológica detallada de sus Bans, Kicks y Warns.

**Objetivo:**
Sincronizar la base de datos de sanciones para mostrar el historial ÚNICAMENTE del jugador consultado, incluyendo contadores individuales por tipo de sanción.

**1. Modificación de Interfaz (index.html):**
En la cabecera de la sección de sanciones, dentro de `.pd-section-title` o justo debajo, añade una fila de contadores rápidos:
- **Badge BANs:** ID `pd-count-bans` (Estilo: Fondo rojo tenue, texto rojo).
- **Badge KICKs:** ID `pd-count-kicks` (Estilo: Fondo gris tenue, texto blanco).
- **Badge WARNs:** ID `pd-count-warns` (Estilo: Fondo naranja tenue, texto naranja).

**2. Lógica del Servidor (main_sv.lua):**
- Modificar el callback `dpadmin:server:getDetailedData`.
- Debe realizar consultas SQL (SELECT) a las tablas de baneos (`bans`) y avisos (`warns`) filtrando por la `license` del jugador (es más persistente que el citizenid).
- Unificar los resultados en una única tabla llamada `history`.
- Ordenar la tabla `history` por fecha (timestamp) de la más reciente (arriba) a la más antigua (abajo).
- **IMPORTANTE:** El servidor debe calcular y enviar un objeto `punishCounts` con los totales: `{ bans: X, kicks: Y, warns: Z }`.

**3. Formateo y Envío de Datos (Server -> JS):**
Cada entrada del historial debe estar estandarizada con:
- `type`: "BAN", "KICK" o "WARN".
- `reason`: El motivo de la sanción.
- `expiry`: Para BANS, indicar "PERMANENTE", "EXPIRADO" o la fecha de fin (DD/MM/AAAA). Para el resto, null.
- `date`: Fecha de creación de la sanción.
- `admin`: Nombre del administrador que la aplicó.
- `active`: (Boolean) Solo para Bans, indica si la sanción sigue vigente hoy.

**4. Renderizado en Frontend (script.js):**
- Actualizar los 3 contadores de la cabecera (`pd-count-bans`, etc.) con los datos de `punishCounts`.
- Limpiar el contenedor `#pd-punishments-list` y generar una "Lista Simple" profesional:
  - **Estructura visual:** `[BADGE TIPO] | [MOTIVO / ESTADO] | [DURACIÓN O FECHA]`.
  - **Colores dinámicos:** - BAN activo: Rojo brillante.
    - BAN expirado/revocado: Gris oscuro.
    - WARN: Naranja.
    - KICK: Gris claro.

**Tarea a realizar:**
Proporciona el código unificado para el Callback del servidor (Lua) y la lógica de renderizado en el NUI (JS) para que el historial sea funcional, preciso y visualmente intuitivo para el staff.