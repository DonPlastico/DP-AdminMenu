<p align="center">
<h1 align="center">🛡️ [FiveM] ¡EL PANEL DE ADMINISTRACIÓN DEFINITIVO! | DP-AdminMenu 🛡️</h1>

<img width="960" height="auto" align="center" alt="DP-AdminMenu" src="Images (Can Remove it if u want)/Miniaturas YT.png" />

</p>

<div align="center">

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![FiveM](https://img.shields.io/badge/FiveM-Script-important)](https://fivem.net/)
[![QBCore](https://img.shields.io/badge/QBCore-Framework-success)](https://github.com/qbcore-framework)

</div>

<h2 align="center"> 📝 Descripción General</h2>
¡Toma el control absoluto de tu servidor FiveM! <b>DP-AdminMenu</b> es un panel de administración extremadamente completo, intuitivo y avanzado, diseñado y desarrollado desde cero por DP-Scripts (actualmente optimizado para QB-Core). Su interfaz moderna y fluida permite gestionar todos los aspectos del servidor en tiempo real, desde la moderación de jugadores hasta la edición de bases de datos, todo sin salir del juego ni tocar código.

<details>
<summary><h2 align="center">¿Qué es y qué hace?</h2></summary>
Es un ecosistema completo para el equipo de Staff. Entre sus múltiples sistemas integrados destacan:
<br><br>
- <b>👥 Gestión de Jugadores:</b> Listado en tiempo real con panel de control individual. Permite ver múltiples datos (inventario, propiedades, vehículos, constantes vitales), espiar/espectear, tomar capturas de su pantalla, controlarlos y acceder a un menú troll avanzado. <br>
- <b>⚡ Acciones Globales:</b> Apartado para controlar opciones del administrador (noclip, godmode), vehículos (reparar, tunear, borrar), servidor (anuncios, clima, limpieza de entidades) y herramientas de desarrollo (coordenadas, visor de entidades). <br>
- <b>🚨 Sistema de Reportes:</b> Gestión de tickets integrada con soporte para previsualización de imágenes adjuntas. <br>
- <b>🔨 Sanciones y Castigos:</b> Sistema custom de Baneos, Kicks, Warns y CK de personajes gestionable 100% desde la interfaz, sin necesidad de entrar a la base de datos externa. <br>
- <b>💬 Chat de Staff Avanzado:</b> Canal privado in-game con integración de iconos, gifs, videos y previsualización de imágenes directamente en el menú. <br>
- <b>💼 Gestor de Trabajos y Bandas:</b> Auto-detección del <i>framework</i>. Muestra listas de jugadores en cada trabajo/banda, sus rangos, salarios y permite crear, editar o eliminar oficios y rangos al vuelo. <br>
- <b>🚗 Catálogo de Vehículos:</b> Detecta todos los vehículos, muestra iconos auto-ajustables, categorías, precios y códigos de spawn. Puedes spawnearlos para ti, para otro jugador o enviarlos directamente al garaje de alguien con las llaves puestas. <br>
- <b>📦 Gestor de Ítems Global:</b> Base de datos en vivo de todos los objetos y armas. Muestra su icono real, peso, munición y permite dártelo o enviarlo a cualquier jugador conectado. <br>
- <b>📊 Dashboard y Estado del Servidor:</b> Panel principal con métricas en tiempo real (jugadores, admins on, tiempo de sesión, reportes), gráficas interactivas (diario, semanal, mensual) y registro de actividad (logs de qué admin hizo qué). <br>
- <b>⚙️ Configuración al Vuelo:</b> Sistema de Whitelist propio activable desde el menú, Staff Mode (para recibir o no notificaciones), escala de la interfaz ajustable y posicionamiento libre (arrastrar y soltar) por la pantalla. <br>
- <b>🛡️ Seguridad Integrada:</b> Anti-Cheat básico incluido y múltiples ventanas de confirmación (modals) rediseñadas para una experiencia de usuario (UX) impecable y segura.
</details>

<details>
<summary><h2 align="center">¿Cómo funciona?</h2></summary>
Al usar el comando o tecla de acceso configurada, la interfaz (NUI) bloqueará o no la cámara (según tus preferencias) y te presentará un Dashboard con los datos vitales del servidor. 
<br><br>
A través de sus pestañas superiores, los administradores pueden navegar de forma instantánea entre la lista de jugadores, el catálogo de ítems, el chat interno o la gestión de clanes. Al interactuar con cualquier botón (ej. "Banear", "Dar Ítem" o "Cambiar Clima"), el script abre modales modernos y limpios que piden confirmación o datos adicionales (como tiempo de sanción, garaje de destino o color de coche). Todo se sincroniza en tiempo real con tu base de datos y con el cliente de los demás jugadores.
</details>

<details>
<summary><h2 align="center">¿Qué te permite?</h2></summary>
✅ Moderar jugadores de forma encubierta o directa 🕵️.<br>
✅ Gestionar la base de datos (Trabajos, Bandas, Bans) sin salir del juego 💻.<br>
✅ Entregar vehículos directamente a garajes (compatible con DP-Garages) 🔑.<br>
✅ Visualizar gráficas de flujo de jugadores y rendimiento 📈.<br>
✅ Mantener un chat privado de Staff con multimedia 💬.<br>
✅ Sancionar y registrar historial de castigos automáticamente ⚖️.<br>
✅ Configurar tu propio entorno (Clima, Hora, Apagones) al instante ⛈️.<br>
✅ Tener un control total sobre el inventario y las propiedades (compatible con DP-Propiedades) 🏠.<br>
✅ Escalar y mover el panel libremente a tu gusto 🎨.<br>
</details>
<br><br>
<h2 align="center"> 🚀 Instalación</h2>

<details>
<summary><h2 align="center">Requisitos previos</h2></summary>
- Servidor FiveM con <b>QB-Core</b> instalado y actualizado.<br>
- Base de datos MySQL configurada (oxmysql).<br>
</details>

<details>
<summary><h2 align="center">Pasos de instalación</h2></summary>
1. **Descargar el script** desde el repositorio oficial o tienda de DP-Scripts.<br>
2. **Colocar la carpeta** en tu servidor (preferiblemente dentro de tu carpeta `[admin]` o `[qb]`) con el nombre exacto `DP-AdminMenu`.<br>
   - ⚠️ <i>Asegúrate de no renombrar el recurso para evitar problemas de rutas HTML/JS.</i><br>
3. **Configuración de la Base de Datos**.<br>
   - Abre el archivo `bans_warns.sql` (o el nombre que tenga tu archivo SQL incluido).<br>
   - Ejecútalo en tu base de datos para generar las tablas necesarias para el sistema de sanciones, warns y logs.<br>
4. **Configuración del script**.<br>
   - Revisa el archivo `config.lua` o `server/config.lua` para establecer los permisos necesarios (god, admin, mod) y las teclas de apertura.<br>
5. **Asegurar el recurso**.<br>
   - Añade `ensure DP-AdminMenu` en tu archivo `server.cfg`.<br>
</details>
<br><br>
<h2 align="center"> ⚙️ Dependencias</h2>
Este script está diseñado para funcionar nativamente con el entorno QB.

<details>
<summary><h2 align="center">📦 Requisitos del Sistema</h2></summary>

| Recurso                                                                                       | Descripción / Estado |
| --------------------------------------------------------------------------------------------- | -------------------- |
| <img src="https://placehold.co/20x20/555555/FFFFFF?text=QB" alt="QB"> **qb-core** | 🔴 OBLIGATORIO       |
| <img src="https://placehold.co/20x20/555555/FFFFFF?text=SQL" alt="SQL"> **oxmysql** | 🔴 OBLIGATORIO       |
| <img src="https://placehold.co/20x20/555555/FFFFFF?text=DP" alt="DP"> **DP-Garages** | 🟢 OPCIONAL          |
| <img src="https://placehold.co/20x20/555555/FFFFFF?text=DP" alt="DP"> **DP-Notify** | 🟢 OPCIONAL          |
| <img src="https://placehold.co/20x20/555555/FFFFFF?text=DP" alt="DP"> **DP-Fuelv2** | 🟢 OPCIONAL          |
| <img src="https://placehold.co/20x20/555555/FFFFFF?text=DP" alt="DP"> **DP-Propiedades** | 🟢 OPCIONAL          |

</details>
<br><br>

<h2 align="center"> 🖼️ Vistas Previas</h2>
Explora el poder y el diseño de las distintas secciones del panel.

<summary><h2>Lista de jugadores activos</h2></summary>
<img width="350" height="auto" src="Images (Can Remove it if u want)/home.png" />
<img width="350" height="auto" src="Images (Can Remove it if u want)/home disable.png" />
<br><br>

<summary><h2>Lista de acciones disponibles</h2></summary>
<img width="350" height="auto" src="Images (Can Remove it if u want)/actions 1.png" />
<img width="350" height="auto" src="Images (Can Remove it if u want)/actions 2.png" />
<img width="350" height="auto" src="Images (Can Remove it if u want)/actions clima modal.png" />
<img width="350" height="auto" src="Images (Can Remove it if u want)/actions modal vehicle upgrade.png" />
<img width="350" height="auto" src="Images (Can Remove it if u want)/actions modal vehicle color.png" />
<img width="350" height="auto" src="Images (Can Remove it if u want)/actions modal vehicle color picker.png" />
<br><br>

<summary><h2>Lista de reportes activos</h2></summary>
<img width="350" height="auto" src="Images (Can Remove it if u want)/reports.png" />
<br><br>

<summary><h2>Lista de baneos activos</h2></summary>
<img width="350" height="auto" src="Images (Can Remove it if u want)/bans.png" />
<img width="350" height="auto" src="Images (Can Remove it if u want)/bans extend modal.png" />
<br><br>

<summary><h2>Chat interno</h2></summary>
<img width="350" height="auto" src="Images (Can Remove it if u want)/chat.png" />
<img width="350" height="auto" src="Images (Can Remove it if u want)/chat modal icons.png" />
<br><br>

<summary><h2>Lista de trabajos</h2></summary>
<img width="350" height="auto" src="Images (Can Remove it if u want)/jobs.png" />
<img width="350" height="auto" src="Images (Can Remove it if u want)/jobs modal change job.png" />
<img width="350" height="auto" src="Images (Can Remove it if u want)/jobs modal change ranks.png" />
<img width="350" height="auto" src="Images (Can Remove it if u want)/jobs modal rank 1.png" />
<img width="350" height="auto" src="Images (Can Remove it if u want)/jobs modal rank 2.png" />
<br><br>

<summary><h2>Lista de organizaciones</h2></summary>
<img width="350" height="auto" src="Images (Can Remove it if u want)/gangs.png" />
<img width="350" height="auto" src="Images (Can Remove it if u want)/gangs modal change gang.png" />
<img width="350" height="auto" src="Images (Can Remove it if u want)/gangs modal change ranks.png" />
<img width="350" height="auto" src="Images (Can Remove it if u want)/gangs modal rank 1.png" />
<img width="350" height="auto" src="Images (Can Remove it if u want)/gangs modal rank 2.png" />
<br><br>

<summary><h2>Catálogo de vehículos</h2></summary>
<img width="350" height="auto" src="Images (Can Remove it if u want)/vehicles.png" />
<img width="350" height="auto" src="Images (Can Remove it if u want)/vehicles modal gift.png" />
<br><br>

<summary><h2>Gestor de ítems</h2></summary>
<img width="350" height="auto" src="Images (Can Remove it if u want)/items.png" />
<img width="350" height="auto" src="Images (Can Remove it if u want)/items modal give.png" />
<br><br>

<summary><h2>Panel de gestiones</h2></summary>
<img width="350" height="auto" src="Images (Can Remove it if u want)/status.png" />
<img width="350" height="auto" src="Images (Can Remove it if u want)/status scale.png" />
<img width="350" height="auto" src="Images (Can Remove it if u want)/status move.png" />
<br><br>

<summary><h2>OTROS</h2></summary>
<img width="350" height="auto" src="Images (Can Remove it if u want)/announce.png" />
<img width="959" height="auto" src="Images (Can Remove it if u want)/actions modal tactic map.png" />
<img width="350" height="auto" src="Images (Can Remove it if u want)/entity.png" />
<img width="350" height="auto" src="Images (Can Remove it if u want)/superspeed, superjump, tags, noclip.png" />
<img width="350" height="auto" src="Images (Can Remove it if u want)/report modal.png" />
<br><br>

<h2 align="center"> 🎥 Video Demostrativo</h2>
<p align="center">
<summary><h2 align="center">Ver Funcionamiento</h2></summary>
<a href="https://youtu.be/TU_ENLACE_DE_YOUTUBE">
<img width="959" height="auto" alt="Video Demostrativo DP-AdminMenu" src="Images (Can Remove it if u want)/Miniaturas YT.png" />
</a>
</p>
<br><br>

<h2 align="center"> 🔮 Posibles Mejoras Futuras</h2>
El panel ya es increíblemente robusto, pero el roadmap de desarrollo contempla opciones de expansión interesantes:

<details>
<summary><h2 align="center">🚧 Roadmap y Sugerencias</h2></summary>

| IDEA                            | EXPLICACIÓN                                                                        |
| ------------------------------- | ---------------------------------------------------------------------------------- |
| **Soporte Multi-Framework** | Adaptar el backend para que sea 100% compatible con ESX, Qbox y Standalone.        |
| **Integración con Discord** | Enviar logs automáticos (baneos, kicks, spawn de objetos) a webhooks de Discord.   |
| **Permisos Granulares (ACL)** | Permitir que ciertos roles (ej. Moderador) solo vean ciertas pestañas y no el root.|
| **Sistema Multi-Idioma** | Configuración rápida de traducciones (EN, ES, FR, DE) desde el config.lua.         |
| **Notas de Administrador** | Un bloc de notas interno asociado a cada jugador que solo el Staff pueda leer.     |

</details>

---

<div align="center">
<b>Autor:</b> DP-Scripts<br>
<b>Versión:</b> 1.2.5
</div>
