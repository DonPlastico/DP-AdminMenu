Config = {}

-- =========================================
--      MODO DEBUG (TRUE = VER LOGS EN F8)
-- =========================================
Config.Debug = false

-- =========================================
--      CONFIGURACION DE COMANDOS
-- =========================================
Config.Commands = {
    Admin = "dpadmin",
    Report = "dpreports",
    -- Comando de emergencia (Solo consola)
    EmergencyWhitelist = "togglewhitelist_emergency"
}

-- =========================================
--      CONFIGURACION DE WHITELIST
-- =========================================
Config.Whitelist = {
    -- Si 'ForceUnlock' es true, la whitelist se desactiva ignorando la base de datos.
    -- Útil si te quedas fuera y no tienes acceso a la consola (se cambia desde el archivo y se reinicia el script).
    ForceUnlock = false,

    -- Permisos que BYPASSEAN la whitelist (no son expulsados)
    BypassRoles = {"god", "admin", "mod" -- Puedes añadir "whitelist" aquí si creas ese permiso en QB-Core
    }
}

-- ===========================================================
--      COORDENADAS CON LOCALIZACIONES
-- ===========================================================
Config.GotoLocations = {
    -- 1. CRIMINALIDAD ALTA
    ["Atracos / Robos"] = {
        { 
            name = "Bancos Fleeca (Global)", 
            coords = vector3(311.23, -284.58, 54.16), 
            icon = "mdi:bank-transfer", 
            img = "img/Ubicaciones/tstudio_fleeca.png", 
            description = "Red interconectada de sucursales bancarias minoristas. Estas ubicaciones operan bajo un sistema de seguridad estandarizado de nivel medio, gestionando cuentas de ahorro y nóminas de ciudadanos locales. Su diseño modular y acceso directo a pie de calle las convierte en objetivos frecuentes para operaciones de asalto rápido ('Smash and Grab'). La infraestructura incluye bóvedas de aleación ligera y sistemas de alarma silenciosa conectados a la LSPD." 
        },
        { 
            name = "Banco Paleto", 
            coords = vector3(-114.77, 6458.92, 31.47), 
            icon = "mdi:bank", 
            img = "img/Ubicaciones/24paletobank_rsm_standalone.png", 
            description = "Sede principal de 'The Blaine County Savings Bank'. Situado estratégicamente en la ruta costera, este banco custodia los activos líquidos de la industria agrícola y ganadera del norte. A pesar de su apariencia rural, cuenta con una bóveda reforzada de grado militar debido a su aislamiento geográfico. El asalto a esta ubicación requiere una planificación logística precisa debido a los largos tiempos de respuesta de los refuerzos policiales desde la ciudad." 
        },
        { 
            name = "Banco Pacific Standard", 
            coords = vector3(229.07, 213.53, 105.51), 
            icon = "mdi:bank-outline", 
            img = "img/Ubicaciones/cfx-gabz-pacificbank.png", 
            description = "La joya de la corona financiera de Vinewood. Este edificio de arquitectura neoclásica alberga las reservas de oro y efectivo más importantes de San Andreas. El interior destaca por su opulencia y su sistema de seguridad de múltiples capas, que incluye puertas térmicas, piratería de redes locales y control de multitudes en el vestíbulo principal. Es el escenario definitivo para operaciones criminales coordinadas de alto perfil." 
        },
        { 
            name = "Tienda iFruit", 
            coords = vector3(-1228.98, -793.94, 17.38), 
            icon = "mdi:cellphone", 
            img = "img/Ubicaciones/cfx-mxc-ifruitstore.png", 
            description = "Flagship Store tecnológica. Un espacio comercial de diseño vanguardista caracterizado por sus amplias cristaleras y exposición de productos de alta gama (teléfonos, tablets y portátiles). El inventario representa un valor elevado en el mercado negro tecnológico. La estructura abierta facilita una entrada agresiva, pero la visibilidad desde el exterior aumenta exponencialmente el riesgo de ser detectado por patrullas civiles o policiales." 
        },
        { 
            name = "Joyería Vangelico", 
            coords = vector3(-630.57, -235.24, 38.09), 
            icon = "mdi:diamond-stone", 
            img = "img/Ubicaciones/cfx-mxc-jewelry.png", 
            description = "Boutique de lujo situada en la exclusiva zona de Portola Drive. Proveedor oficial de diamantes y metales preciosos para la élite de Los Santos. El establecimiento cuenta con vitrinas de cristal templado que requieren herramientas de impacto contundente. Los sistemas de ventilación son un punto crítico conocido en su arquitectura de seguridad. El botín potencial incluye relojes suizos y joyas de diseño con números de serie rastreables." 
        },
        { 
            name = "Joyería Vangelico", 
            coords = vector3(-762.0, -601.27, 30.28), 
            icon = "mdi:diamond-outline", 
            img = "img/Ubicaciones/falon-vangelico.png", 
            description = "Reinterpretación arquitectónica de la franquicia Vangelico. Esta ubicación alternativa presenta una distribución interior modificada, optimizada para ofrecer una experiencia de cliente más reservada. Para los perpetradores, esto implica líneas de visión más complejas y puntos ciegos adicionales. Mantiene el alto estándar de valor en sus expositores, siendo un objetivo prioritario para redes de contrabando de gemas." 
        },
        { 
            name = "Farmacia", 
            coords = vector3(-509.32, 278.5, 83.31), 
            icon = "mdi:pill", 
            img = "img/Ubicaciones/dip_pharmacy.png", 
            description = "Establecimiento farmacéutico local. Funciona como punto de distribución crítica de medicamentos controlados y suministros de primeros auxilios. Además del efectivo en caja, el verdadero valor reside en el acceso al almacén trasero, donde se custodian precursores químicos y narcóticos bajo llave. Su ubicación urbana facilita rutas de escape rápidas a través de callejones adyacentes." 
        },
        { 
            name = "Farmacia", 
            coords = vector3(115.24, -6.25, 67.8), 
            icon = "mdi:pill", 
            img = "img/Ubicaciones/moreo_pharmacy.png", 
            description = "Centro de salud y parafarmacia central. Este local modernizado ofrece un inventario ampliado de productos médicos. Su diseño interior limpio y organizado esconde un área restringida vulnerable a la incursión forzada. Ideal para la obtención de suministros médicos de emergencia o sustancias reguladas con alto valor de reventa en el mercado ilegal." 
        },
        { 
            name = "Tienda 24/7", 
            coords = vector3(-501.34, 277.02, 83.29), 
            icon = "mdi:cart", 
            img = "img/Ubicaciones/dip_store.png", 
            description = "Supermercado de conveniencia abierto las 24 horas. Un pilar del comercio minorista nocturno. Aunque el flujo de caja individual es bajo comparado con un banco, la baja seguridad física y la presencia mínima de personal lo convierten en un objetivo de oportunidad para delincuentes novatos. Dispone de una caja fuerte trasera con recaudación semanal." 
        },
        { 
            name = "Tiendas 24/7 Reworks", 
            coords = vector3(25.72, -1346.96, 29.49), 
            icon = "mdi:cart-outline", 
            img = "img/Ubicaciones/moreo_247reworks.png", 
            description = "Renovación integral de la franquicia de supermercados. Este mapeado actualiza el diseño interior de las tiendas dispersas por el estado, mejorando la distribución de estanterías y la zona de cobro. La nueva disposición táctica ofrece mejor cobertura para los asaltantes contra la policía que responde desde la entrada principal, aunque reduce las vías de salida traseras." 
        },
        { 
            name = "Maze Bank", 
            coords = vector3(-1375.1, -504.44, 33.16), 
            icon = "mdi:finance", 
            img = "img/Ubicaciones/k4mb1-mazebank.png", 
            description = "Sede corporativa de alto standing. Este complejo financiero no solo gestiona transacciones monetarias, sino que simboliza el poder económico de Los Santos. El interior personalizado cuenta con oficinas ejecutivas, salas de conferencias y una zona de cajas de máxima seguridad. La verticalidad del edificio y sus múltiples accesos requieren una coordinación perfecta entre los equipos de tierra y aire." 
        },
        { 
            name = "The Vault", 
            coords = vector3(231.46, -1095.01, 29.29), 
            icon = "mdi:safe", 
            img = "img/Ubicaciones/map_thevault.png", 
            description = "Instalación de almacenamiento privado de alta seguridad. 'The Vault' es una fortaleza subterránea diseñada para clientes que requieren discreción absoluta fuera del sistema bancario tradicional. Sus pasillos de hormigón reforzado y sistemas de cierre electrónico custodian activos no rastreables. Un objetivo extremadamente difícil que promete recompensas incalculables para quienes logren vulnerar sus defensas." 
        },
        { 
            name = "Gasolinera Paleto Bay", 
            coords = vector3(167.27, 6557.15, 31.86), 
            icon = "mdi:gas-station", 
            img = "img/Ubicaciones/PaletoBayLTD.png", 
            description = "Estación de servicio y área de descanso LTD. Punto neurálgico para el repostaje en la autopista Great Ocean. El establecimiento combina una tienda de conveniencia con surtidores de combustible, añadiendo un peligro ambiental explosivo a cualquier tiroteo que se produzca en la zona. La caja registradora acumula grandes sumas de efectivo de los viajeros y camioneros que transitan la ruta norte." 
        },
        { 
            name = "LD Organics", 
            coords = vector3(-1141.54, -1412.65, 5.1), 
            icon = "mdi:leaf", 
            img = "img/Ubicaciones/kiiya_ldorganics.png", 
            description = "Dispensario de cannabis medicinal y recreativo. Operado bajo la marca de Lamar Davis, este local en los canales de Vespucci mezcla el comercio legal con operaciones de dudosa reputación. El interior temático 'verde' alberga tanto producto cultivado de alta calidad como grandes cantidades de dinero en efectivo pendiente de lavado. Un territorio disputado que requiere precaución extra." 
        },
    },
    ["Misiones / Ilegal"] = {
        { 
            name = "Laboratorio Cocaína", 
            coords = vector3(1093.6, -3196.6, -38.99), 
            icon = "mdi:pill", 
            img = "img/Ubicaciones/BikerCocaine.png", 
            description = "Instalación de procesamiento de alto nivel oculta bajo tierra. Este complejo industrial clandestino cuenta con equipamiento para el refinamiento de pasta base de cocaína a escala masiva. El aire en el interior es altamente tóxico debido a los disolventes químicos. Operado habitualmente por organizaciones de motociclistas, requiere máscaras de gas y armamento pesado para su toma." 
        },
        { 
            name = "Laboratorio Metanfetamina", 
            coords = vector3(1009.5, -3196.6, -38.99), 
            icon = "mdi:flask-outline", 
            img = "img/Ubicaciones/BikerMethLab.png", 
            description = "Laboratorio de síntesis química de cristal. Un entorno volátil lleno de precursores inestables y equipamiento de vidrio. La infraestructura está diseñada para cocinar metanfetamina de alta pureza. Los vapores inflamables hacen que el uso de explosivos en el interior sea extremadamente arriesgado. Se sospecha conexión directa con la red de distribución de Trevor Philips Enterprises." 
        },
        { 
            name = "Granja de Hierba", 
            coords = vector3(1051.49, -3196.53, -39.14), 
            icon = "mdi:leaf", 
            img = "img/Ubicaciones/BikerWeedFarm.png", 
            description = "Plantación hidropónica intensiva. Espacio optimizado con sistemas de iluminación de sodio de alta presión y riego automatizado para el cultivo acelerado de cannabis. La humedad y el calor son constantes. A diferencia de los laboratorios químicos, el peligro aquí reside en la defensa armada de los carteles que protegen la cosecha antes de su secado y empaquetado." 
        },
        { 
            name = "Laboratorio Ácido", 
            coords = vector3(483.42, -2625.07, -50.0), 
            icon = "mdi:flask-empty", 
            img = "img/Ubicaciones/DrugWarsLab.png", 
            description = "Complejo de síntesis de psicodélicos. Una instalación moderna adaptada para la producción de LSD y alucinógenos de diseño. El equipamiento es más sofisticado y compacto que los laboratorios tradicionales. Se asocia a las nuevas facciones 'Fooliganz' que operan al margen de las familias criminales establecidas. Contiene precursores químicos de difícil rastreo." 
        },
        { 
            name = "Fábrica Dinero Falso", 
            coords = vector3(1121.89, -3195.33, -40.4), 
            icon = "mdi:cash-multiple", 
            img = "img/Ubicaciones/BikerCounterfeit.png", 
            description = "Imprenta ilegal de divisas. Local equipado con planchas de impresión offset y papel de fibra de algodón robado. Aquí se producen billetes falsos de baja detectabilidad destinados al lavado en negocios locales. El ruido constante de las máquinas industriales dificulta la comunicación táctica y el sigilo en el interior." 
        },
        { 
            name = "Falsificación Docs", 
            coords = vector3(1165.0, -3196.6, -39.01), 
            icon = "mdi:file-document-edit", 
            img = "img/Ubicaciones/BikerDocumentForgery.png", 
            description = "Oficina de delitos de cuello blanco. Centro de operaciones especializado en la clonación de tarjetas de crédito, pasaportes y documentos de identidad. Menos hostil que un laboratorio de drogas, pero crítico para la infraestructura criminal de la ciudad. Contiene servidores con datos encriptados y equipos de impresión de alta fidelidad." 
        },
        { 
            name = "Fábrica Agentes", 
            coords = vector3(752.31, -997.24, -47.0), 
            icon = "mdi:account-tie-hat", 
            img = "img/Ubicaciones/AgentsFactory.png", 
            description = "Instalación encubierta de la IAA/FIB. Aparentemente una fábrica textil abandonada, el subsuelo alberga un centro de operaciones de inteligencia gubernamental. Zonas de interrogatorio, almacenamiento de pruebas clasificadas y tecnología de vigilancia de grado militar. Entrar aquí sin autorización federal es considerado un acto de terrorismo doméstico." 
        },
        { 
            name = "Fábrica de Lester", 
            coords = vector3(713.84, -961.53, 30.39), 
            icon = "mdi:tshirt-crew-outline", 
            img = "img/Ubicaciones/LesterFactory.png", 
            description = "Nave industrial textil 'Darnell Bros'. Conocida base de operaciones de Lester Crest. Detrás de las máquinas de coser y los rollos de tela, se planifican los golpes más sofisticados de Los Santos. El edificio cuenta con salidas de emergencia ocultas y vigilancia por CCTV perimetral. Punto neurálgico para la logística de atracos." 
        },
        { 
            name = "Laboratorio Mercenarios", 
            coords = vector3(-1916.11, 3749.71, -100.0), 
            icon = "mdi:flask-empty-plus-outline", 
            img = "img/Ubicaciones/MercenariesLab.png", 
            description = "Centro de I+D de Merryweather Security. Instalación subterránea de máxima seguridad dedicada al desarrollo de armas biológicas y tecnología experimental. Protegido por contratistas militares privados. Los pasillos son estrechos y modulares, diseñados para emboscadas defensivas. Nivel de amenaza: Extremo." 
        },
        { 
            name = "Super Yate (Vespucci)", 
            coords = vector3(-2043.97, -1031.58, 11.98), 
            icon = "mdi:sail-boat", 
            img = "img/Ubicaciones/HeistYacht.png", 
            description = "Embarcación de lujo clase 'Aquarius' anclada cerca de la costa. Escenario principal del asalto durante operaciones especiales. El yate combina opulencia con sistemas de defensa antiaérea desactivados. Sus cubiertas multinivel ofrecen combate vertical intenso, desde la sala de máquinas hasta el helipuerto superior." 
        },
        { 
            name = "Super Yate (Paleto)", 
            coords = vector3(-1363.72, 6734.10, 2.44), 
            icon = "mdi:sail-boat", 
            img = "img/Ubicaciones/GunrunningYacht.png", 
            description = "Yate privado fondeado en las aguas del norte. Utilizado como punto de encuentro neutral para traficantes de armas internacionales. Lejos de la jurisdicción inmediata de la LSPD, esta fortaleza flotante suele estar custodiada por mercenarios pesados. Ideal para operaciones de extracción o eliminación VIP." 
        },
        { 
            name = "Portaviones (Este)", 
            coords = vector3(3082.31, -4717.11, 15.26), 
            icon = "mdi:ferry", 
            img = "img/Ubicaciones/HeistCarrier.png", 
            description = "USS Luxington. Buque de guerra activo en maniobras cerca de la costa este. Zona de exclusión aérea estricta. La cubierta está repleta de cazas Lazer y equipamiento militar. El interior es un laberinto de acero que custodia tecnología EMP y secretos de estado. El acceso civil es letalmente restringido." 
        },
        { 
            name = "Portaviones (Oeste)", 
            coords = vector3(-3208.03, 3954.54, 14.0), 
            icon = "mdi:ferry", 
            img = "img/Ubicaciones/SummerCarrier.png", 
            description = "Portaviones en rotación logística. Estacionado en aguas profundas del oeste. Aunque comparte estructura con el Luxington, esta ubicación suele utilizarse para eventos de mercancía de batalla comercial. La disposición de la carga en cubierta proporciona coberturas tácticas únicas para tiroteos a larga distancia." 
        },
        { 
            name = "Barco de Carga", 
            coords = vector3(-344.43, -4062.83, 17.0), 
            icon = "mdi:ferry",
            img = "img/Ubicaciones/ChopShopCargoShip.png", 
            description = "Buque mercante de bandera extranjera en la Terminal. Utilizado frecuentemente para el contrabando de vehículos de lujo (Chop Shop) y exportación de bienes ilícitos. El entorno está lleno de contenedores apilados que crean un laberinto táctico (CQB). Vigilancia privada armada patrulla las pasarelas superiores." 
        },
        { 
            name = "Lavadero de Coches", 
            coords = vector3(26.07, -1398.97, -75.0), 
            icon = "mdi:car-wash", 
            img = "img/Ubicaciones/MoneyCarwash.png", 
            description = "Negocio fachada clásico en Davis. Bajo la operación legítima de lavado de vehículos se esconde una infraestructura para el blanqueo de capitales a pequeña y mediana escala. Referencia directa a operaciones de 'limpieza' de dinero sucio. Cuenta con acceso a desagües que podrían usarse como rutas de escape o descarte de pruebas." 
        },
        { 
            name = "Bunker Tráfico Armas", 
            coords = vector3(892.63, -3245.86, -98.26), 
            icon = "mdi:shield-home", 
            img = "img/Ubicaciones/GunrunningBunker.png", 
            description = "Antiguo silo militar de la Guerra Fría reconvertido. Instalación subterránea masiva diseñada para resistir bombardeos nucleares. Actualmente utilizada para la fabricación y almacenamiento de armamento ilegal de grado militar. Cuenta con campo de tiro, zona de ensamblaje y transporte interno por carritos debido a su gran extensión." 
        },
        { 
            name = "Hangar de Contrabando", 
            coords = vector3(-1267.0, -3013.13, -49.5), 
            icon = "mdi:warehouse",
            img = "img/Ubicaciones/SmugglerHangar.png", 
            description = "Almacén logístico aéreo privado [Smuggler's Run]. Espacio inmenso dedicado al almacenamiento de aeronaves y carga de contrabando. Incluye oficinas administrativas y talleres de modificación de aeronaves. Frecuentemente utilizado por redes de narcotráfico aéreo para mover mercancía a través de las fronteras estatales." 
        },
        { 
            name = "Submarino Kosatka", 
            coords = vector3(1560.0, 400.0, -50.0), 
            icon = "mdi:submarine", 
            img = "img/Ubicaciones/CayoPericoSubmarine.png", 
            description = "Submarino soviético clase Delta reconvertido. Cuartel general móvil de operaciones de infiltración. El interior es claustrofóbico, lleno de torpedos, misiles guiados y tecnología de sonar obsoleta pero funcional. Operado habitualmente por ex-militares rusos. Acceso solo mediante escotillas presurizadas." 
        },
        { 
            name = "Sótano Arcade", 
            coords = vector3(2710.0, -360.78, -56.0), 
            icon = "mdi:controller-classic", 
            img = "img/Ubicaciones/DiamondArcadeBasement.png", 
            description = "Centro de planificación oculto tras una sala de recreativos retro. Equipado con pizarras tácticas, maquetas de objetivos y estaciones de hacking de drones. Es el cerebro logístico detrás de los grandes golpes al Casino Diamond. Incluye una bóveda de práctica y terminales de control global." 
        },
        { 
            name = "Bunker Operaciones", 
            coords = vector3(173.42, 1245.13, 223.1), 
            icon = "mdi:shield-star", 
            img = "img/Ubicaciones/bunker.png", 
            description = "Instalación de Defensa Civil clasificada. Un complejo laberíntico de hormigón reforzado enterrado bajo el Monte Josiah. Alberga servidores de datos gubernamentales, el cañón orbital y salas de guerra. La seguridad es de nivel estatal, con sistemas automatizados y puertas blindadas de varias toneladas." 
        },
        { 
            name = "Isla Oculta", 
            coords = vector3(-3509.07, 6286.78, 18.19), 
            icon = "mdi:island", 
            img = "img/Ubicaciones/hide_island.png", 
            description = "Mapeado personalizado 'Hide Island'. Una formación insular no cartografiada en los límites del radar. Vegetación densa y estructuras precarias sugieren su uso como refugio de emergencia o punto de intercambio discreto lejos de la vigilancia costera. Accesible únicamente por mar o aire." 
        },
        { 
            name = "Lab. Stock 1 (Davis)", 
            coords = vector3(162.10, -1711.32, 22.20), 
            icon = "mdi:package-variant", 
            img = "img/Ubicaciones/int_stocks.png", 
            description = "Piso franco de seguridad baja en Davis. Utilizado por las bandas callejeras locales (Families/Ballas) como punto de corte y empaquetado rápido. Interior genérico con mesas de trabajo básicas. Su ubicación en zona densamente poblada permite dispersarse rápidamente ante redadas policiales." 
        },
        { 
            name = "Lab. Stock 2 (Vespucci)", 
            coords = vector3(-1246.52, -1117.35, 0.78), 
            icon = "mdi:package-variant", 
            img = "img/Ubicaciones/int_stocks.png", 
            description = "Almacén costero en los canales de Vespucci. Nodo logístico utilizado para procesar mercancía llegada por mar. El interior estándar contiene estanterías industriales y zona de carga. La humedad del ambiente y la cercanía al turismo lo hacen ideal para camuflar olores sospechosos." 
        },
        { 
            name = "Lab. Stock 3 (Centro)", 
            coords = vector3(598.24, -423.38, 17.62), 
            icon = "mdi:package-variant", 
            img = "img/Ubicaciones/int_stocks.png", 
            description = "Sótano comercial en el distrito financiero. Operación de 'cuello blanco' oculta a plena vista. Se utiliza para el almacenamiento temporal de contrabando de alto valor antes de su distribución. Acceso discreto a través de zonas de carga traseras de edificios de oficinas." 
        },
        { 
            name = "Lab. Stock 4 (Industrial)", 
            coords = vector3(937.73, -1474.60, 23.04), 
            icon = "mdi:package-variant", 
            img = "img/Ubicaciones/int_stocks.png", 
            description = "Nave en el polígono industrial este. Zona de manufactura genérica controlada por mafias organizadas. El ruido ambiental de las fábricas cercanas proporciona cobertura acústica perfecta para maquinaria de prensado o torturas. Punto caliente para el tráfico de armas ligeras." 
        },
        { 
            name = "Lab. Stock 5 (Chumash)", 
            coords = vector3(-1974.08, -228.99, 27.86), 
            icon = "mdi:package-variant", 
            img = "img/Ubicaciones/int_stocks.png", 
            description = "Residencia de seguridad en la costa oeste. Lejos del caos de la ciudad, este punto sirve como laboratorio satélite para operaciones que requieren discreción. Interior estándar adaptado para almacenamiento de químicos o dinero en efectivo a la espera de transporte." 
        },
        { 
            name = "Lab. Stock 6 (Barrio)", 
            coords = vector3(-67.78, -1291.19, 23.79), 
            icon = "mdi:package-variant", 
            img = "img/Ubicaciones/int_stocks.png", 
            description = "Punto de distribución en zona residencial sur. Casa franca estándar utilizada como almacén intermedio (stash house). Vulnerable a ataques de bandas rivales debido a la falta de fortificación exterior. Contiene suministros básicos para la venta al menudeo." 
        },
        { 
            name = "Lab. Stock 7 (Vinewood)", 
            coords = vector3(800.09, -89.15, 74.91), 
            icon = "mdi:package-variant", 
            img = "img/Ubicaciones/int_stocks.png", 
            description = "Localización en Vinewood Hills. Utilizado por proveedores de drogas de diseño para fiestas privadas de la élite. Aunque el interior es austero, la ubicación sugiere una clientela VIP. Seguridad discreta pero efectiva para evitar llamar la atención de los vecinos adinerados." 
        },
        { 
            name = "Lab. Stock 8 (Paleto)", 
            coords = vector3(-147.76, 6303.59, 24.56), 
            icon = "mdi:package-variant", 
            img = "img/Ubicaciones/int_stocks.png", 
            description = "Depósito rural en Paleto Bay. Nodo norte de la red de contrabando. Utilizado para almacenar mercancía antes de bajarla a la ciudad por la autopista. Su aislamiento permite operaciones más ruidosas, pero los tiempos de huida son limitados si llega la policía estatal." 
        },
        { 
            name = "Lab. Stock 9 (Paleto N)", 
            coords = vector3(-41.53, 6453.30, 24.32), 
            icon = "mdi:package-variant", 
            img = "img/Ubicaciones/int_stocks.png", 
            description = "Anexo de almacenamiento en el extremo norte. Pequeña instalación de apoyo logístico para los laboratorios grandes de Blaine County. Interior básico utilizado para guardar precursores químicos lejos de los laboratorios principales para minimizar pérdidas en caso de redada." 
        },
        { 
            name = "Lab. Stock 10 (Petrolífera)", 
            coords = vector3(1397.31, -2092.37, 45.49), 
            icon = "mdi:package-variant", 
            img = "img/Ubicaciones/int_stocks.png", 
            description = "Escondite en los campos petrolíferos de Murrieta. Rodeado de maquinaria pesada, este punto es ideal para enmascarar actividades industriales ilegales. La infraestructura es precaria y el riesgo de incendio es elevado debido a la proximidad de pozos de extracción." 
        },
        { 
            name = "Lab. Stock 11 (Grapeseed)", 
            coords = vector3(2862.44, 4456.00, 41.32), 
            icon = "mdi:package-variant", 
            img = "img/Ubicaciones/int_stocks.png", 
            description = "Granero reconvertido en Grapeseed. Centro de operaciones agrícolas ilegales. Bajo la apariencia de una granja local, se coordinan envíos de fertilizantes químicos y maquinaria pesada para los cultivos de hierba de la zona. Zona controlada por rednecks armados." 
        },
        { 
            name = "Lab. Stock 12 (Desierto)", 
            coords = vector3(552.58, 2684.17, 35.04), 
            icon = "mdi:package-variant", 
            img = "img/Ubicaciones/int_stocks.png", 
            description = "Refugio aislado en el Gran Desierto de Señora. Punto de descanso para traficantes que cruzan el desierto. Instalación mínima con suministros de supervivencia y almacenamiento temporal. El calor extremo y la visibilidad a kilómetros hacen difícil acercarse sin ser detectado." 
        },
        { 
            name = "Lab. Stock 13 (Sandy)", 
            coords = vector3(963.74, 3632.50, 25.76), 
            icon = "mdi:package-variant", 
            img = "img/Ubicaciones/int_stocks.png", 
            description = "Base de operaciones en Sandy Shores. Ubicado en el corazón del territorio de los traficantes de metanfetamina. Este almacén sirve como nexo central para la distribución local. El entorno es hostil y la presencia policial es escasa pero agresiva cuando aparece." 
        },
        { 
            name = "Lab. Stock 14 (Granja)", 
            coords = vector3(2536.50, 4118.27, 31.46), 
            icon = "mdi:package-variant", 
            img = "img/Ubicaciones/int_stocks.png", 
            description = "Instalación oculta en zona agrícola remota. Lejos de las carreteras principales, este punto se utiliza para operaciones de larga duración que requieren privacidad total. Interior genérico adaptado para vivir y trabajar durante semanas sin salir al exterior." 
        },
        { 
            name = "Lab. Stock 15 (Puerto)", 
            coords = vector3(436.54, -1970.36, 17.29), 
            icon = "mdi:package-variant", 
            img = "img/Ubicaciones/int_stocks.png", 
            description = "Almacén secundario en Elysian Island. Situado entre depósitos de chatarra y muelles de carga. Punto final de la cadena de suministro antes de la exportación. Vigilado por seguridad privada portuaria corrupta. Ideal para tratos de gran volumen." 
        },
        { 
            name = "X-Labs 1 (Mirror)", 
            coords = vector3(1087.76, -306.08, 64.11), 
            icon = "mdi:flask", 
            img = "img/Ubicaciones/uniqx_xlabs1.png", 
            description = "Laboratorio secreto avanzado 'X-Labs'. Instalación subterránea de última generación bajo Mirror Park. Especializada en síntesis química experimental. Cuenta con salas de descontaminación, seguridad biométrica y ventilación filtrada. Un objetivo de alto valor para facciones que buscan dominar el mercado de sintéticos." 
        },
        { 
            name = "X-Labs 2 (Sur)", 
            coords = vector3(-506.31, -1443.54, 13.73), 
            icon = "mdi:flask", 
            img = "img/Ubicaciones/uniqx_xlabs2.png", 
            description = "Segunda sede de la red 'X-Labs'. Ubicada estratégicamente en la zona sur industrial. Este complejo duplica la capacidad de producción de su gemelo en el norte. Diseño interior clínico y moderno, contrastando con la suciedad del exterior. Requiere personal altamente cualificado para operar su maquinaria." 
        },
    },

    -- 2. LOGÍSTICA Y CALLE
    ["Garajes / Almacenes"] = {
        { 
            name = "Garage LS Tuners", 
            coords = vector3(-1350.0, 160.0, -100.0), 
            icon = "mdi:car-cog", 
            img = "img/Ubicaciones/TunerGarage.png", 
            description = "Centro social clandestino en Cypress Flats. Un almacén industrial masivo reconvertido en santuario para la cultura automovilística underground. El espacio es una zona neutral donde corredores y mecánicos exhiben vehículos modificados ilegalmente. Cuenta con pista de pruebas interior, talleres de modificación y un ambiente saturado de humo de neumáticos y música de alto volumen." 
        },
        { 
            name = "Club Coches Vinewood", 
            coords = vector3(1202.40, -3251.25, -50.0), 
            icon = "mdi:steering", 
            img = "img/Ubicaciones/MercenariesClub.png", 
            description = "Instalación de almacenamiento premium en la Terminal. A diferencia de un garaje convencional, este espacio funciona como un club privado para coleccionistas de élite. El interior climatizado protege vehículos de siete cifras contra la corrosión marina. La seguridad es férrea, diseñada para mantener alejados a curiosos y ladrones de coches comunes." 
        },
        { 
            name = "Almacén Vehículos (I/E)", 
            coords = vector3(994.59, -3002.59, -39.64), 
            icon = "mdi:warehouse", 
            img = "img/Ubicaciones/ImportVehicleWarehouse.png", 
            description = "Nave logística de Importación/Exportación. Hub central para operaciones de robo de vehículos a gran escala (Grand Theft Auto). El espacio está equipado para almacenar hasta 40 superdeportivos robados. Incluye un taller subterráneo especializado en la alteración de números de bastidor (VIN) y repintado rápido para 'enfriar' vehículos buscados por la policía." 
        },
        { 
            name = "Almacén Criminal Enterprise", 
            coords = vector3(849.10, -3000.20, -45.97), 
            icon = "mdi:dolly", 
            img = "img/Ubicaciones/CriminalEnterpriseWarehouse.png", 
            description = "Depósito de Mercancía Especial. Un espacio de almacenamiento denso y caótico utilizado por CEOs criminales. Las estanterías están repletas de contrabando variado: desde armas y narcóticos hasta joyas y antigüedades robadas. La disposición laberíntica de las cajas ofrece cobertura táctica en caso de redada, pero el riesgo de incendio es crítico." 
        },
        { 
            name = "Almacén Vehículos 2", 
            coords = vector3(800.13, -3001.42, -65.14), 
            icon = "mdi:warehouse", 
            img = "img/Ubicaciones/CriminalEnterpriseVehicleWarehouse.png", 
            description = "Instalación de desbordamiento logístico. Un segundo nivel de almacenamiento para operaciones de tráfico de vehículos que han excedido su capacidad principal. Este garaje subterráneo suele utilizarse para guardar vehículos de 'gama media' o como punto de transición antes de cargar los coches en contenedores para su exportación marítima." 
        },
        { 
            name = "Garaje Agencia", 
            coords = vector3(-1071.43, -77.03, -93.52), 
            icon = "mdi:garage-lock", 
            img = "img/Ubicaciones/MpSecurityGarage.png", 
            description = "Aparcamiento corporativo de F. Clinton & Partner. Un entorno pulcro y de alta tecnología situado bajo las oficinas de la Agencia. Este no es un simple garaje; alberga la armería de la agencia y el taller de 'Imani Tech', capaz de instalar inhibidores de fijación de misiles y blindaje reforzado en vehículos de lujo." 
        },
        { 
            name = "Garaje Freakshop", 
            coords = vector3(519.24, -2618.78, -50.0), 
            icon = "mdi:garage-alert", 
            img = "img/Ubicaciones/DrugWarsGarage.png", 
            description = "Guarida de los Fooliganz bajo la autopista. Un almacén psicodélico y anárquico conocido como 'The Freakshop'. Sirve como base de operaciones para la tropa de Dax. Es el hogar del laboratorio móvil de ácido (Brickade 6x6). El ambiente es sucio, lleno de grafitis y vapores químicos, reflejando el caos de sus habitantes." 
        },
        { 
            name = "Garaje del Cartel", 
            coords = vector3(1220.13, -2277.84, -50.0), 
            icon = "mdi:tools", 
            img = "img/Ubicaciones/ChopShopCartelGarage.png", 
            description = "Desguace de vehículos de lujo. Operando bajo la fachada de un negocio de reciclaje ('Salvage Yard'), esta instalación se dedica al despiece sistemático de coches robados de alta gama para vender las partes. Equipado con grúas de remolque y herramientas de corte industrial. El suelo está manchado de aceite y la ley aquí es la del mercado negro." 
        },
    },
    ["Barrios / Bandas"] = {
        { 
            name = "Clubhouse Moteros 1", 
            coords = vector3(1107.04, -3157.39, -37.51), 
            icon = "mdi:motorbike", 
            img = "img/Ubicaciones/BikerClubhouse1.png", 
            description = "Sede Capitular (Chapter Mother). Este local de dos plantas representa el corazón administrativo de la MC (Motorcycle Club). La planta baja funciona como un bar privado y taller mecánico con olor permanente a aceite de motor y cerveza rancia. La planta superior alberga la 'Capilla' (sala de reuniones), donde los parches completos votan decisiones ejecutivas lejos de los oídos de los prospectos." 
        },
        { 
            name = "Clubhouse Moteros 2", 
            coords = vector3(998.48, -3164.71, -38.90), 
            icon = "mdi:motorbike", 
            img = "img/Ubicaciones/BikerClubhouse2.png", 
            description = "Clubhouse satélite o de soporte. Una estructura más compacta utilizada por capítulos nómadas o como piso franco secundario. El interior mantiene la estética 'Roadhouse' con billares, dardos y parafernalia del club en las paredes. A pesar de su apariencia recreativa, cuenta con una oficina de gestión de contratos ilegales (Open Road) y almacenamiento de armamento ligero." 
        },
        { 
            name = "The Freakshop", 
            coords = vector3(570.97, -420.07, -70.00), 
            icon = "mdi:flask-empty", 
            img = "img/Ubicaciones/DrugWarsFreakshop.png", 
            description = "Refugio anarquista bajo el paso elevado de la autopista. Base de operaciones de la tropa 'Fooliganz' liderada por Dax. Es un antiguo depósito ferroviario convertido en una comuna psicodélica y taller de armas. El caos visual, los grafitis de neón y el equipo de DJ ocultan una operación seria de distribución de ácido y sabotaje industrial. Territorio extremadamente hostil para forasteros." 
        },
        { 
            name = "Desguace (Chop Shop)", 
            coords = vector3(1077.27, -2274.87, -50.00), 
            icon = "mdi:car-wrench", 
            img = "img/Ubicaciones/ChopShopSalvage.png", 
            description = "Centro de Reciclaje 'Red’s Auto Parts'. Fachada comercial legítima que oculta una operación masiva de desmantelamiento de vehículos robados. El interior está equipado con grúas puente y herramientas de corte para reducir un superdeportivo a piezas en cuestión de minutos, eliminando cualquier rastro rastreable. Gestionado en colaboración con Yusuf Amir." 
        },
        { 
            name = "Rancho La Fuente (Cartel)", 
            coords = vector3(1309.38, 1104.24, 105.68), 
            icon = "mdi:home-group", 
            img = "img/Ubicaciones/energy_lafuente_farm.png", 
            description = "Hacienda fortificada 'La Fuente'. Propiedad de alto valor asociada al Cartel Madrazo. Detrás de los muros de piedra y los establos de caballos de pura sangre, se esconde una fortaleza del narcotráfico. El complejo incluye una mansión principal, zonas de ocio para capos y seguridad perimetral armada las 24 horas. Símbolo de poder e impunidad en la región de Vinewood Hills." 
        },
        { 
            name = "Grove Street", 
            coords = vector3(102.63, -1937.06, 20.8), 
            icon = "mdi:skull", 
            img = "img/Ubicaciones/hoods1.png", 
            description = "Zona Cero de Chamberlain Hills. La legendaria calle sin salida ha sido remodelada, reflejando la cruda realidad de la guerra de bandas entre Families y Ballas. El callejón presenta barricadas improvisadas, grafitis territoriales frescos y una densidad de viviendas que favorece las emboscadas. Entrar en este callejón sin los colores adecuados es una sentencia de muerte." 
        },
        { 
            name = "Forum Drive", 
            coords = vector3(-14.67, -1454.87, 30.46), 
            icon = "mdi:skull", 
            img = "img/Ubicaciones/forumdrive.png", 
            description = "Núcleo histórico de los Chamberlain Gangster Families. Esta calle sin salida (cul-de-sac) en Chamberlain Hills actúa como una fortaleza natural difícil de asaltar debido a sus limitados puntos de acceso. La densidad residencial permite una movilización rápida de miembros de la banda ante amenazas externas. Conocida por ser la residencia de figuras clave en el hampa de Los Santos, es una zona de 'Disparar a la vista' para colores rivales." 
        },
        { 
            name = "Jamestown Street", 
            coords = vector3(307.41, -2017.0, 25.95), 
            icon = "mdi:skull", 
            img = "img/Ubicaciones/jamestown.png", 
            description = "Baluarte principal de Los Santos Vagos en Rancho. Dominada por los bloques de viviendas de protección oficial (Rancho Projects), esta zona presenta una verticalidad peligrosa con múltiples puntos de francotirador en tejados y ventanas. La arquitectura laberíntica de los callejones traseros facilita emboscadas y rutas de escape para el tráfico de narcóticos a pie de calle. Territorio amarillo de alta hostilidad." 
        },
        { 
            name = "Amarillo Vista", 
            coords = vector3(1171.5, -1710.35, 40.4), 
            icon = "mdi:skull", 
            img = "img/Ubicaciones/amarillo.png", 
            description = "Centro de operaciones de la Marabunta Grande en El Burro Heights. Ubicada en las colinas que dominan el sector industrial, esta calle residencial ofrece una ventaja táctica de altura sobre Murrieta Oil Fields. Los grafitis azules y blancos marcan un territorio defendido ferozmente por una de las bandas más agresivas de la ciudad. Se sospecha tráfico de armas nocturno aprovechando la oscuridad del desierto cercano." 
        },
        { 
            name = "The Lost MC (Harmony)", 
            coords = vector3(23.47, 2777.69, 58.2), 
            icon = "mdi:motorbike", 
            img = "img/Ubicaciones/russ_68cus.png", 
            description = "Puesto de avanzada en la Ruta 68. Ubicado estratégicamente en Harmony, este taller y bar sirve como punto de control clave para The Lost MC en el desierto. Controlan el flujo de armas y metanfetamina entre Sandy Shores y la ciudad. El complejo está rodeado de vallas altas y chatarra, diseñado para resistir ataques de bandas rivales como los Aztecas o los O'Neil." 
        },
    },

    -- 3. ECONOMÍA Y CIVIL
    ["Locales / Comercios"] = {
        { 
            name = "Ammunations (Global)", 
            coords = vector3(21.43, -1106.39, 29.80), 
            icon = "mdi:pistol", 
            img = "img/Ubicaciones/3DMarket_Ammunation_V2.png", 
            description = "Red de franquicias de defensa personal patriótica. Estos establecimientos renovados ofrecen un entorno limpio y moderno para la adquisición legal de armamento. Cuentan con galerías de tiro insonorizadas, expositores de cristal blindado y personal armado. Punto de suministro vital para ciudadanos preocupados por la creciente tasa de criminalidad." 
        },
        { 
            name = "Tiendas Binco (Global)", 
            coords = vector3(75.41, -1392.92, 29.37), 
            icon = "mdi:tshirt-crew", 
            img = "img/Ubicaciones/moreo_binco.png", 
            description = "Cadena de moda urbana 'Low Cost'. Populares en barrios obreros como Strawberry y Davis. Ofrecen ropa funcional y estilo callejero a precios accesibles. El interior es básico y funcional, frecuentado por pandilleros locales que buscan ropa ancha y colores neutros para pasar desapercibidos." 
        },
        { 
            name = "Tiendas Ponsonbys (Global)", 
            coords = vector3(-710.02, -153.07, 37.41), 
            icon = "mdi:tie", 
            img = "img/Ubicaciones/cfx-fm-ponsonbys.png", 
            description = "Boutiques de alta costura. Ubicadas en las zonas más exclusivas como Rockford Hills. El epítome del lujo y la distinción en Los Santos. Trajes a medida, telas importadas y atención personalizada. La seguridad privada en la puerta es discreta pero efectiva, filtrando a la clientela indeseada." 
        },
        { 
            name = "Gasolineras LTD (Global)", 
            coords = vector3(-724.56, -935.91, 19.21), 
            icon = "mdi:gas-station", 
            img = "img/Ubicaciones/cfx-fm-ltd-gasoline.png", 
            description = "Estaciones de servicio urbanas. Puntos neurálgicos de abastecimiento de combustible y snacks rápidos. Abiertas 24/7, suelen ser escenario de robos nocturnos debido a su alta rotación de efectivo y baja seguridad. El olor a gasolina y café quemado es su sello de identidad." 
        },
        { 
            name = "Licorerías (Global)", 
            coords = vector3(1135.81, -982.28, 46.41), 
            icon = "mdi:glass-wine", 
            img = "img/Ubicaciones/cfx-mxc-liquorstore.png", 
            description = "Tiendas de licores y tabaco. Pequeños comercios de barrio abarrotados de estanterías con botellas. Lugares de reunión habitual para locales al caer la noche. Aunque el botín es escaso, su ubicación en esquinas concurridas las hace vulnerables a atracos rápidos." 
        },
        { 
            name = "Nightclub (Interior)", 
            coords = vector3(-1604.66, -3012.58, -78.00), 
            icon = "mdi:music-note", 
            img = "img/Ubicaciones/AfterHoursNightclubs.png", 
            description = "Club nocturno subterráneo. El centro de la vida nocturna de Los Santos. Pista de baile con sistema de iluminación láser, barras VIP y oficinas de gestión. Detrás de la fiesta y la música techno, el local sirve como tapadera perfecta para lavar dinero y gestionar mercancía ilegal en el almacén anexo." 
        },
        { 
            name = "Cerrajero (Locksmith)", 
            coords = vector3(170.34, -1799.23, 29.32), 
            icon = "mdi:key-variant", 
            img = "img/Ubicaciones/blockz_locksmith.png", 
            description = "Taller especializado en seguridad. Local pequeño pero esencial donde se duplican llaves de vehículos y viviendas. El interior está lleno de maquinaria de corte y matrices metálicas. Un negocio neutral respetado tanto por civiles como por criminales que necesitan acceso rápido a sus propiedades." 
        },
        { 
            name = "Diamond Casino", 
            coords = vector3(924.63, 46.83, 81.11), 
            icon = "mdi:cards-playing", 
            img = "img/Ubicaciones/casinomlofixed.png", 
            description = "The Diamond Casino & Resort. El complejo de entretenimiento más opulento del estado. Vestíbulo de mármol, máquinas tragaperras ruidosas y mesas de apuestas de límites altos. La seguridad es de nivel bancario, con cientos de cámaras CCTV y guardias armados protegiendo la bóveda subterránea." 
        },
        { 
            name = "Bolera (Bowling)", 
            coords = vector3(759.97, -777.99, 26.45), 
            icon = "mdi:bowling", 
            img = "img/Ubicaciones/cfx-gabz-bowling.png", 
            description = "Centro de ocio familiar Bobcat. Un espacio recreativo clásico con pistas de bolos pulidas, zona de bar y billares. El ambiente es relajado y social, ideal para quedadas civiles lejos del crimen. El sonido de los bolos cayendo y música retro llenan el ambiente." 
        },
        { 
            name = "Cat Café / UwU V2", 
            coords = vector3(-580.90, -1072.34, 22.33), 
            icon = "mdi:coffee", 
            img = "img/Ubicaciones/cfx-gabz-catcafe.png", 
            description = "Cafetería temática UwU Cafe. Un refugio de estética kawaii en medio de la ciudad. Decoración en tonos pastel, gatos paseando libremente y menú de postres artesanales. Punto de encuentro popular para civiles y roleplay social pacífico. La cocina está equipada para alta repostería." 
        },
        { 
            name = "Restaurante Hookies", 
            coords = vector3(-2196.59, 4296.13, 48.52), 
            icon = "mdi:silverware-fork-knife", 
            img = "img/Ubicaciones/dip_hookies.png", 
            description = "Marisquería histórica en la North Chumash. Parada obligatoria en la Great Ocean Highway. Conocido por su comida casera y ambiente rústico. A pesar de su apariencia familiar, suele ser frecuentado por moteros y camioneros que recorren la ruta costera." 
        },
        { 
            name = "Cabaña de Caza", 
            coords = vector3(-679.62, 5833.60, 17.33), 
            icon = "mdi:target", 
            img = "img/Ubicaciones/hunt.png", 
            description = "Puesto de suministros cinegéticos en Paleto Forest. Una cabaña de madera rústica especializada en equipamiento para cazadores: rifles de cerrojo, cebos y ropa de camuflaje. El punto de partida ideal para expediciones al Monte Chiliad." 
        },
        { 
            name = "Sala Recreativos", 
            coords = vector3(-1270.21, -305.32, 36.99), 
            icon = "mdi:gamepad-variant", 
            img = "img/Ubicaciones/int_arcade.png", 
            description = "Salón Arcade Pixel Pete's. Un viaje a la nostalgia de los 8-bits. Lleno de máquinas recreativas retro, simuladores de conducción y luces de neón. Aunque funciona como negocio legítimo, el ruido y la oscuridad lo hacen perfecto para reuniones discretas entre el caos electrónico." 
        },
        { 
            name = "Oficinas Dynasty 8", 
            coords = vector3(-693.22, 273.33, 82.15), 
            icon = "mdi:domain", 
            img = "img/Ubicaciones/gigz_dynasty_8_v2.png", 
            description = "Sede corporativa inmobiliaria. Oficinas modernas de cristal y acero desde donde se gestiona el mercado de la vivienda de Los Santos. Espacios de trabajo diáfanos, salas de reuniones con vistas a la ciudad y un ambiente de negocios agresivo." 
        },
        { 
            name = "Gimnasio LKS", 
            coords = vector3(-1261.44, -348.06, 36.83), 
            icon = "mdi:dumbbell", 
            img = "img/Ubicaciones/lks_gym.png", 
            description = "Centro de fitness a pie de playa. Inspirado en el culto al cuerpo de Vespucci Beach. Equipado con pesas libres, máquinas de cardio y ring de boxeo. El aire huele a sudor y magnesio. Lugar habitual para entrenar estadísticas físicas o peleas organizadas." 
        },
        { 
            name = "Gasolineras RON (Global)", 
            coords = vector3(1181.38, -330.84, 69.31),
            icon = "mdi:gas-station-outline", 
            img = "img/Ubicaciones/map4all-ron.png", 
            description = "Red de estaciones de servicio RON. Competencia directa de LTD, predominantes en las zonas industriales y rurales del condado de Blaine. Famosas por su combustible de alto octanaje y comida de dudosa calidad. Puntos de repostaje críticos para rutas largas." 
        },
        { 
            name = "Casa de Empeños Sandy", 
            coords = vector3(911.18, 3643.31, 32.68), 
            icon = "mdi:cash-usd", 
            img = "img/Ubicaciones/marlonstudio_sandypawn.png", 
            description = "Pawn Shop en el desierto. Negocio de compra-venta de artículos de segunda mano. Desde joyas antiguas hasta herramientas eléctricas de origen incierto. El lugar perfecto para deshacerse de objetos valiosos rápidamente sin hacer preguntas." 
        },
        { 
            name = "Mirror Park Tavern", 
            coords = vector3(-1332.00, -1091.88, 6.98), 
            icon = "mdi:glass-mug", 
            img = "img/Ubicaciones/mirror_park_rest.png", 
            description = "Pub local con encanto en Mirror Park. Un establecimiento acogedor con terraza al lago, ideal para la clase media hipster de la zona. Sirven cervezas artesanales y comida orgánica. Un oasis de tranquilidad social lejos del bullicio del centro." 
        },
        { 
            name = "Tienda de Mascotas", 
            coords = vector3(230.24, -24.82, 74.99), 
            icon = "mdi:paw", 
            img = "img/Ubicaciones/moreo_petshop.png", 
            description = "Centro de cuidado animal. Establecimiento dedicado a la venta de accesorios, comida premium y adopción de mascotas. El interior es limpio y amigable. Punto de interés para roles civiles relacionados con animales de compañía (K9 fuera de servicio)." 
        },
        { 
            name = "Burgershot Moderno", 
            coords = vector3(-1178.65, -884.45, 13.86), 
            icon = "mdi:hamburger", 
            img = "img/Ubicaciones/mz3d_modern_burgershot.png", 
            description = "Restaurante de comida rápida renovado. La franquicia clásica de 'Bleeder Burgers' actualizada al siglo XXI. Cocinas abiertas, quioscos de auto-pedido y decoración vibrante. El lugar huele a grasa frita y éxito corporativo. Popular para trabajos de repartidor." 
        },
        { 
            name = "Concesionario PDM", 
            coords = vector3(-63.02, -1092.67, 26.55), 
            icon = "mdi:car-multiple", 
            img = "img/Ubicaciones/MZ3D_PDM_Remaster_v1.png", 
            description = "Premium Deluxe Motorsport. El concesionario de Simeon Yetarian, totalmente remasterizado. Showroom amplio con iluminación de estudio para destacar los vehículos de gama media-alta. Oficinas de ventas acristaladas y zona de taller trasero. El corazón del comercio automovilístico legal." 
        },
        { 
            name = "Tiendas Suburban", 
            coords = vector3(125.75, -223.82, 54.55), 
            icon = "mdi:tshirt-v", 
            img = "img/Ubicaciones/nx_ipl_arcade.png", 
            description = "Cadena de ropa casual y deportiva. Dirigida a un público joven y activo. Ofrece marcas de skate y surf. Los interiores son espaciosos y bien iluminados, con probadores accesibles. El punto medio entre la ropa barata de Binco y el lujo de Ponsonbys." 
        },
        { 
            name = "Pacific Bluffs Resort", 
            coords = vector3(-3017.72, 88.32, 11.61), 
            icon = "mdi:beach", 
            img = "img/Ubicaciones/PacificBluffs.png", 
            description = "Complejo hotelero de lujo en la costa oeste. Un resort exclusivo con acceso privado a la playa, piscinas infinity y suites presidenciales. El lugar de vacaciones preferido por celebridades y políticos corruptos. Seguridad alta y privacidad garantizada." 
        },
        { 
            name = "Tiendas Paleto (Pack 3)", 
            coords = vector3(-26.17, 6496.38, 31.54), 
            icon = "mdi:store", 
            img = "img/Ubicaciones/paleto-3shops.png", 
            description = "Distrito comercial de Paleto Bay. Conjunto de pequeños negocios locales que dan vida al pueblo: peluquería, tienda de ropa y tatuajes. Mantienen la estética rural y acogedora del norte, sirviendo como centro neurálgico para la comunidad local." 
        },
        { 
            name = "Granja de Cultivos", 
            coords = vector3(2512.20, 4653.43, 33.67), 
            icon = "mdi:sprout", 
            img = "img/Ubicaciones/plt_farmer-streams.png", 
            description = "Explotación agrícola masiva en Grapeseed. Campos de cultivo extensivos con sistemas de riego y maquinaria pesada. El motor económico legítimo del condado de Blaine. Durante el día es un lugar de trabajo duro; por la noche, sus campos de maíz son perfectos para ocultar actividades ilícitas." 
        },
        { 
            name = "Sea Dome Plaza", 
            coords = vector3(-2185.02, -383.98, 13.05), 
            icon = "mdi:water", 
            img = "img/Ubicaciones/SeaDome_MLO.png", 
            description = "Acuario y centro comercial costero. Una atracción turística moderna con tanques de vida marina y tiendas de souvenirs. La arquitectura de cristal y agua crea un entorno visualmente único para eventos sociales o reuniones públicas de alto nivel." 
        },
        { 
            name = "Pearls Resort & Seafood", 
            coords = vector3(-1736.64, -1109.66, 13.03), 
            icon = "mdi:fish", 
            img = "img/Ubicaciones/tstudio_pearls_resort.png", 
            description = "Restaurante de 5 estrellas sobre el mar. Ubicado en el muelle, ofrece la mejor experiencia gastronómica de mariscos en la ciudad. Salones elegantes con vistas al océano, cocina de chef y servicio de valet parking. El lugar para cerrar tratos importantes con el estómago lleno." 
        },
        { 
            name = "Pier 76 Car Club (Puerto)", 
            coords = vector3(526.84, -3044.10, 6.07), 
            icon = "mdi:car-convertible", 
            img = "img/Ubicaciones/tstudio_pier76_carclub.png", 
            description = "Sede social para entusiastas del motor en Elysian Island. Un espacio industrial rehabilitado con estilo loft neoyorquino. Barra de bar, zonas de relax y exposición de vehículos. Punto de encuentro nocturno para organizar carreras callejeras lejos de la policía." 
        },
        { 
            name = "Pier 76 Car Club (Ciudad)", 
            coords = vector3(857.42, -900.86, 25.44), 
            icon = "mdi:car-convertible", 
            img = "img/Ubicaciones/tstudio_pier76_carclub.png", 
            description = "Sucursal urbana del club automovilístico. Situada más cerca del centro para mayor accesibilidad. Mantiene la estética industrial-chic, sirviendo como escaparate legal para los negocios del club y captación de nuevos miembros." 
        },
        { 
            name = "Vanilla Unicorn (Bella)", 
            coords = vector3(123.76, -1312.87, 29.08), 
            icon = "mdi:glass-cocktail", 
            img = "img/Ubicaciones/zxbella_vanilla.png", 
            description = "Club de caballeros Vanilla Unicorn. Remodelación integral del icónico local de striptease. Interiores de terciopelo rojo, iluminación tenue y zonas privadas de lujo. Un negocio de entretenimiento para adultos que mueve grandes cantidades de efectivo y secretos de almohada." 
        },
    },
    ["Oficinas"] = {
        { 
            name = "Arcadius Business Centre", 
            coords = vector3(-141.19, -620.91, 168.82), 
            icon = "mdi:office-building", 
            img = "img/Ubicaciones/ImportCEOGarage1.png", 
            description = "Sede corporativa en el corazón de Pillbox Hill. Edificio icónico de arquitectura posmoderna que ofrece un entorno empresarial dinámico. Las oficinas ejecutivas cuentan con vistas panorámicas al centro financiero y acceso directo a un helipuerto privado. Símbolo de estatus para organizaciones criminales que buscan legitimidad pública." 
        },
        { 
            name = "Maze Bank Building", 
            coords = vector3(-75.84, -826.98, 243.38), 
            icon = "mdi:office-building", 
            img = "img/Ubicaciones/ImportCEOGarage2.png", 
            description = "La cima del mundo financiero de San Andreas. Ubicada en el rascacielos más alto de la ciudad, esta oficina representa el poder absoluto. Desde aquí se controlan imperios comerciales globales. Interiores de mármol negro, seguridad de nivel estatal y la sensación constante de estar por encima de la ley (y de las nubes)." 
        },
        { 
            name = "Lom Bank Office", 
            coords = vector3(-1579.75, -565.06, 108.52), 
            icon = "mdi:office-building", 
            img = "img/Ubicaciones/ImportCEOGarage3.png", 
            description = "Oficinas premium en Del Perro. Situadas en el nexo entre la vida urbana y la costa. Ofrecen un equilibrio perfecto entre accesibilidad a la autopista y discreción corporativa. El edificio Lom Bank es conocido por albergar empresas fantasma y operaciones de lavado de dinero de perfil medio-alto." 
        },
        { 
            name = "Maze Bank West", 
            coords = vector3(-1392.66, -480.47, 72.04), 
            icon = "mdi:office-building", 
            img = "img/Ubicaciones/ImportCEOGarage4.png", 
            description = "Sucursal ejecutiva en la costa oeste. Una alternativa estratégica para CEOs que prefieren operar lejos del caos del centro. Sus oficinas ofrecen vistas despejadas al océano y una ruta de escape rápida hacia el norte por la Great Ocean Highway. Ideal para startups criminales en expansión." 
        },
        { 
            name = "Agencia Franklin 1", 
            coords = vector3(-1030.53, -432.99, 63.86), 
            icon = "mdi:account-tie", 
            img = "img/Ubicaciones/MpSecurityOffice1.png", 
            description = "Sede principal de F. Clinton & Partner. Ubicada en Rockford Hills, esta agencia de 'Soluciones para Celebridades' combina el lujo corporativo con la funcionalidad operativa. Incluye armería privada, garaje con tecnología Imani y acceso a contratos VIP. El centro neurálgico para resolver los problemas de la élite de Vinewood." 
        },
        { 
            name = "Agencia Franklin 2", 
            coords = vector3(374.04, -57.26, 103.36), 
            icon = "mdi:account-tie", 
            img = "img/Ubicaciones/MpSecurityOffice2.png", 
            description = "Sucursal Hawick. Situada en una zona comercial de lujo, esta ubicación ofrece un perfil más discreto pero igualmente exclusivo. El diseño interior es minimalista y moderno, enfocado en la eficiencia. Perfecta para operaciones que requieren mezclarse con la alta sociedad y el mundo de la moda." 
        },
        { 
            name = "Agencia Franklin 3", 
            coords = vector3(-1003.09, -770.97, 61.89), 
            icon = "mdi:account-tie", 
            img = "img/Ubicaciones/MpSecurityOffice3.png", 
            description = "Oficina en Little Seoul. Enclavada en el barrio coreano, esta sede ofrece una ventaja táctica única: acceso rápido a zonas de bandas y callejones densos. A pesar de estar en un edificio de oficinas moderno, el entorno urbano exterior es más áspero, ideal para agencias con un enfoque más 'callejero'." 
        },
        { 
            name = "Agencia Franklin 4", 
            coords = vector3(-578.22, -715.76, 113.01), 
            icon = "mdi:account-tie", 
            img = "img/Ubicaciones/MpSecurityOffice4.png", 
            description = "Sede Vespucci Canals. La opción más pintoresca, con vistas directas a los canales. Aunque el acceso en vehículo puede ser congestionado por el turismo, ofrece rutas de escape acuáticas inmediatas. El ambiente relajado de la zona camufla perfectamente las operaciones de seguridad de alto riesgo." 
        },
        { 
            name = "Estudio de Grabación", 
            coords = vector3(-1000.72, -70.55, -98.10), 
            icon = "mdi:microphone-variant", 
            img = "img/Ubicaciones/MpSecurityStudio.png", 
            description = "Record A Studios. Instalación de producción musical de clase mundial frecuentada por leyendas como Dr. Dre. Detrás de las mesas de mezclas y las cabinas insonorizadas, el lugar sirve como punto de encuentro seguro para negocios de alto nivel. Cuenta con sala de relax llena de humo y acceso restringido." 
        },
        { 
            name = "Oficina de Fianzas (Bail)", 
            coords = vector3(565.88, -2688.76, -50.0), 
            icon = "mdi:gavel", 
            img = "img/Ubicaciones/SummerOffice.png", 
            description = "Oficina de ejecución de fianzas 'Bottom Dollar Bounties'. Sede operativa para cazarrecompensas modernos. El espacio combina una zona administrativa con celdas de detención temporal y una sala de interrogatorios. El negocio perfecto para operar al margen de la ley con una placa en el pecho." 
        },
        { 
            name = "Oficina Lavado Dinero", 
            coords = vector3(-1160.49, -1538.93, -50.0), 
            icon = "mdi:washing-machine", 
            img = "img/Ubicaciones/MoneyOffice.png", 
            description = "Consultora financiera 'off-shore'. Una oficina genérica y sin personalidad diseñada para ser abandonada en minutos. Equipada con contadoras de billetes industriales y trituradoras de papel. Aquí es donde el dinero sucio se transforma en activos digitales limpios lejos de la mirada del fisco." 
        },
        { 
            name = "Oficina IAA / Agentes", 
            coords = vector3(2149.71, 4787.76, -47.0), 
            icon = "mdi:shield-account", 
            img = "img/Ubicaciones/AgentsOffice.png", 
            description = "Instalación Clasificada. Base operativa remota de la Agencia de Asuntos Internacionales (IAA). Oculta bajo una estructura civil anodina. Alberga analistas de inteligencia, servidores de vigilancia global y salas de crisis. Entrar aquí requiere autorización de seguridad Top Secret." 
        },
        { 
            name = "Ayuntamiento (Townhall)", 
            coords = vector3(-412.01, 1172.87, 325.79), 
            icon = "mdi:town-hall", 
            img = "img/Ubicaciones/molo_townhall.png", 
            description = "Centro Cívico y Administrativo. Sede del gobierno local. Un edificio solemne donde se gestionan licencias, juicios civiles y la burocracia de la ciudad. Sus pasillos de mármol y oficinas de madera noble son el escenario de la política (y la corrupción) de Los Santos." 
        },
    },
    ["Viviendas / Apartamentos"] = {
        { 
            name = "Casino Penthouse", 
            coords = vector3(976.63, 70.29, 115.16), 
            icon = "mdi:star-face", 
            img = "img/Ubicaciones/DiamondPenthouse.png", 
            description = "La cúspide del lujo en Los Santos. Este ático personalizable ofrece lo último en opulencia: sala de cine privada, spa, servicio de habitaciones 24h y vistas panorámicas al hipódromo. Vivir aquí es una declaración de poder absoluto y hedonismo sin límites." 
        },
        { 
            name = "Casa de Michael", 
            coords = vector3(-802.31, 175.05, 72.84), 
            icon = "mdi:home-account", 
            img = "img/Ubicaciones/Michael.png", 
            description = "Residencia De Santa en Rockford Hills. Una mansión de estilo español con pista de tenis y piscina. Aunque por fuera proyecta el sueño americano, sus muros han sido testigos de terapias familiares fallidas y planificaciones criminales. El epítome de la crisis de la mediana edad rica." 
        },
        { 
            name = "Casa de Franklin (Vinewood)", 
            coords = vector3(7.80, 548.10, 175.50), 
            icon = "mdi:home-modern", 
            img = "img/Ubicaciones/Franklin.png", 
            description = "3671 Whispymound Drive. Una maravilla de la arquitectura moderna colgada sobre las colinas de Vinewood. Diseño minimalista, espacios abiertos y una piscina infinity que mira a la ciudad. El trofeo definitivo para el gángster que logró salir del barrio y llegar a la cima." 
        },
        { 
            name = "Casa Tía de Franklin", 
            coords = vector3(-9.96, -1438.54, 31.10), 
            icon = "mdi:home-heart", 
            img = "img/Ubicaciones/FranklinAunt.png", 
            description = "El hogar de la infancia en Strawberry. Una casa unifamiliar modesta con jardín delantero descuidado. Representa las raíces en Forum Drive, rodeada de la tensión de las bandas y el ruido de la ciudad. Un refugio seguro en territorio hostil." 
        },
        { 
            name = "Caravana de Trevor", 
            coords = vector3(1972.17, 3817.37, 33.43), 
            icon = "mdi:home-variant", 
            img = "img/Ubicaciones/TrevorsTrailer.png", 
            description = "Remolque en ruinas en Sandy Shores. Rodeado de basura, laboratorios de metanfetamina y vecinos impredecibles. El interior es un caos de suciedad y violencia contenida. Solo apto para psicópatas o fugitivos que no quieren ser encontrados por la civilización." 
        },
        { 
            name = "Apartamento de Floyd", 
            coords = vector3(-1150.70, -1520.71, 10.63), 
            icon = "mdi:home-floor-1", 
            img = "img/Ubicaciones/deFloydfault.png", 
            description = "Apartamento en planta baja en Vespucci Beach. Decoración anticuada y ambiente opresivo. Situado cerca de los canales, ofrece un escondite discreto a pie de calle, aunque la convivencia con 'ciertos invitados' puede ser letal." 
        },
        { 
            name = "4 Integrity Way, Apt 30", 
            coords = vector3(-35.31, -580.41, 88.71), 
            icon = "mdi:apartment", 
            img = "img/Ubicaciones/GTAOApartmentHi1.png", 
            description = "Apartamento High-End en el centro. Ubicación privilegiada frente al ayuntamiento. Interiores modernos con acabados en mármol y madera noble. Ideal para profesionales que trabajan en el distrito financiero y buscan un oasis de calma en el caos urbano." 
        },
        { 
            name = "Dell Perro Heights, Apt 7", 
            coords = vector3(-1477.14, -538.74, 55.52), 
            icon = "mdi:apartment", 
            img = "img/Ubicaciones/GTAOApartmentHi2.png", 
            description = "Residencia de lujo cerca de la costa. A pocos minutos del muelle y la playa. Este apartamento combina la vida urbana con la brisa marina. Perfecto para quienes disfrutan del estilo de vida relajado de la costa oeste sin renunciar a las comodidades premium." 
        },
        { 
            name = "Dell Perro Heights, Apt 4", 
            coords = vector3(-1468.14, -541.81, 73.44), 
            icon = "mdi:apartment", 
            img = "img/Ubicaciones/HLApartment1.png", 
            description = "Apartamento exclusivo con vistas al océano. Situado en una planta alta de Dell Perro, ofrece privacidad y seguridad. El diseño interior es contemporáneo, con amplios ventanales que permiten disfrutar de los atardeceres sobre el Pacífico." 
        },
        { 
            name = "Richard Majestic, Apt 2", 
            coords = vector3(-915.81, -379.43, 113.67), 
            icon = "mdi:apartment", 
            img = "img/Ubicaciones/HLApartment2.png", 
            description = "Vivienda en el distrito del cine. Frente a los estudios de Richards Majestic. Un apartamento con carácter, rodeado de la historia de Hollywood y el glamour decadente de la industria cinematográfica. Excelente ubicación central." 
        },
        { 
            name = "Tinsel Towers, Apt 42", 
            coords = vector3(-614.86, 40.67, 97.60), 
            icon = "mdi:apartment", 
            img = "img/Ubicaciones/HLApartment3.png", 
            description = "Torre residencial icónica en West Vinewood. Recientemente renovada, ofrece apartamentos espaciosos con fácil acceso a la vida nocturna del Boulevard. Una dirección prestigiosa para jóvenes profesionales y aspirantes a estrellas." 
        },
        { 
            name = "Eclipse Towers, Apt 3", 
            coords = vector3(-773.40, 341.76, 211.39), 
            icon = "mdi:apartment", 
            img = "img/Ubicaciones/HLApartment4.png", 
            description = "El edificio residencial más codiciado de Los Santos. Vivir en Eclipse Towers es sinónimo de éxito. Este apartamento ofrece vistas inigualables de la ciudad y las colinas. Vecinos de alto perfil y seguridad de primer nivel." 
        },
        { 
            name = "4 Integrity Way, Apt 28", 
            coords = vector3(-18.07, -583.67, 79.46), 
            icon = "mdi:apartment", 
            img = "img/Ubicaciones/HLApartment5.png", 
            description = "Alternativa residencial en Integrity Way. Un piso ligeramente más compacto pero con las mismas calidades de lujo. Su posición estratégica cerca de Arcadius y Maze Bank lo hace perfecto para ejecutivos con poco tiempo que perder." 
        },
        { 
            name = "Apartamento High End (Custom)", 
            coords = vector3(-609.56, 51.28, -183.98), 
            icon = "mdi:home-plus", 
            img = "img/Ubicaciones/HLApartment6.png", 
            description = "Interior residencial personalizado. Un espacio único que rompe con el diseño estándar de los promotores inmobiliarios. Muebles de diseño, distribución abierta y acabados exclusivos para quien busca diferenciarse del resto de millonarios." 
        },
        { 
            name = "3655 Wild Oats Drive", 
            coords = vector3(-169.28, 486.49, 137.44), 
            icon = "mdi:home-city", 
            img = "img/Ubicaciones/GTAOHouseHi1.png", 
            description = "Casa sobre pilotes (Stilt House) en Vinewood Hills. Arquitectura audaz suspendida sobre el cañón. Ofrece privacidad total y contacto con la naturaleza sin salir de la ciudad. El diseño vertical y las terrazas escalonadas son su sello distintivo." 
        },
        { 
            name = "2044 North Conker Avenue", 
            coords = vector3(340.94, 437.17, 149.39), 
            icon = "mdi:home-city", 
            img = "img/Ubicaciones/GTAOHouseHi2.png", 
            description = "Residencia moderna en North Conker. Estilo mid-century modern actualizado. Grandes ventanales de suelo a techo y estructura ligera. Una joya arquitectónica para los amantes del diseño y las fiestas privadas en las colinas." 
        },
        { 
            name = "2045 North Conker Avenue", 
            coords = vector3(373.02, 416.10, 145.70), 
            icon = "mdi:home-city", 
            img = "img/Ubicaciones/GTAOHouseHi3.png", 
            description = "Propiedad vecina en North Conker. Ofrece una distribución alternativa con acabados más cálidos. La ubicación elevada garantiza aire puro y silencio, lejos del smog del centro. Garaje integrado y acceso discreto." 
        },
        { 
            name = "2862 Hillcrest Avenue", 
            coords = vector3(-676.12, 588.61, 145.16), 
            icon = "mdi:home-city", 
            img = "img/Ubicaciones/GTAOHouseHi4.png", 
            description = "Casa de diseño en Hillcrest. Destaca por su salón de doble altura y decoración vanguardista. La terraza trasera es el punto perfecto para observar las luces de la ciudad con una copa de vino. Símbolo de estatus en el vecindario." 
        },
        { 
            name = "2868 Hillcrest Avenue", 
            coords = vector3(-763.10, 615.90, 144.14), 
            icon = "mdi:home-city", 
            img = "img/Ubicaciones/GTAOHouseHi5.png", 
            description = "Residencia de lujo contigua. Mantiene el estilo arquitectónico de la zona pero con un enfoque más minimalista. Espacios diáfanos ideales para exponer arte moderno. Una inversión segura en la zona más revalorizada de Vinewood." 
        },
        { 
            name = "2874 Hillcrest Avenue", 
            coords = vector3(-857.79, 682.56, 152.65), 
            icon = "mdi:home-city", 
            img = "img/Ubicaciones/GTAOHouseHi6.png", 
            description = "La joya de Hillcrest Avenue. Situada en el punto más alto de la calle, ofrece las mejores panorámicas. Su interior lujoso y cocina de chef la convierten en el lugar ideal para recepciones sociales de alto nivel." 
        },
        { 
            name = "2677 Whispymound Drive", 
            coords = vector3(120.50, 549.95, 184.09), 
            icon = "mdi:home-city", 
            img = "img/Ubicaciones/GTAOHouseHi7.png", 
            description = "Propiedad exclusiva cerca de la mansión de Franklin. Una de las direcciones más caras del código postal. Seguridad privada en la zona y acabados de importación. El refugio perfecto para celebridades que buscan anonimato." 
        },
        { 
            name = "2133 Mad Wayne Thunder", 
            coords = vector3(-1288.00, 440.74, 97.69), 
            icon = "mdi:home-city", 
            img = "img/Ubicaciones/GTAOHouseHi8.png", 
            description = "Casa temática en honor a la estrella de cine. Ubicada en una calle tranquila, esta propiedad sobre pilotes combina historia de Hollywood con comodidades modernas. Un hogar con personalidad propia en las colinas." 
        },
        { 
            name = "Casa Gama Media", 
            coords = vector3(347.26, -999.29, -99.19), 
            icon = "mdi:home", 
            img = "img/Ubicaciones/GTAOHouseMid1.png", 
            description = "Vivienda unifamiliar estándar. El hogar promedio de la clase media de Los Santos. Interiores funcionales, cocina equipada y decoración acogedora. Sin lujos excesivos, pero cómoda y segura. Ideal para familias o roleplay civil tranquilo." 
        },
        { 
            name = "Casa Gama Baja", 
            coords = vector3(261.45, -998.81, -99.00), 
            icon = "mdi:home-outline", 
            img = "img/Ubicaciones/GTAOHouseLow1.png", 
            description = "Vivienda económica básica. Espacio reducido y acabados sencillos. Situada habitualmente en barrios obreros o zonas industriales. El punto de partida perfecto para quien acaba de llegar a la ciudad con los bolsillos vacíos." 
        },
        { 
            name = "Eclipse Penthouse Suite 1", 
            coords = vector3(-787.78, 334.92, 215.83), 
            icon = "mdi:star-four-points", 
            img = "img/Ubicaciones/ExecApartment1.png", 
            description = "Penthouse 'Monochrome'. Diseño interior en blanco y negro de alto contraste. Frialdad elegante para mentes calculadoras. Incluye bar privado y sala de cine. La máxima expresión de sofisticación moderna en Eclipse Towers." 
        },
        { 
            name = "Eclipse Penthouse Suite 2", 
            coords = vector3(-773.22, 322.82, 194.88), 
            icon = "mdi:star-four-points", 
            img = "img/Ubicaciones/ExecApartment2.png", 
            description = "Penthouse 'Vibrant'. Decoración atrevida con colores vivos y arte pop. Un espacio lleno de energía diseñado para fiestas y entretenimiento. Rompe con la monotonía del lujo tradicional. Perfecto para personalidades extrovertidas." 
        },
        { 
            name = "Eclipse Penthouse Suite 3", 
            coords = vector3(-787.78, 334.92, 186.11), 
            icon = "mdi:star-four-points", 
            img = "img/Ubicaciones/ExecApartment3.png", 
            description = "Penthouse 'Sharp'. Estilo industrial refinado con toques de madera oscura y metal. Ambiente serio y masculino, ideal para reuniones de negocios de alto nivel en la privacidad del hogar. Elegancia atemporal." 
        },
        { 
            name = "Mansion Hills 1", 
            coords = vector3(543.85, 712.75, 201.00), 
            icon = "mdi:home-variant", 
            img = "img/Ubicaciones/Mansion1.png", 
            description = "Finca privada en Lake Vinewood. Una mansión masiva rodeada de jardines y muros altos. Ofrece aislamiento total del mundo exterior. Piscina olímpica, garaje para colección de coches y casa de invitados. Lujo clásico." 
        },
        { 
            name = "Mansion Hills 2", 
            coords = vector3(-1630.43, 470.85, 128.00), 
            icon = "mdi:home-variant", 
            img = "img/Ubicaciones/Mansion2.png", 
            description = "Residencia moderna en Tongva Hills. Arquitectura integrada en la ladera de la montaña. Destaca por sus terrazas multinivel y cascadas artificiales. Un refugio zen de millones de dólares lejos de las miradas indiscretas." 
        },
        { 
            name = "Mansion Hills 3", 
            coords = vector3(-2601.71, 1874.82, 166.00), 
            icon = "mdi:home-variant", 
            img = "img/Ubicaciones/Mansion3.png", 
            description = "Mansión costera en Banham Canyon. Situada sobre los acantilados, domina la vista del océano. Acceso directo a playas privadas y helipuerto propio. La propiedad definitiva para magnates que valoran el sonido del mar y la exclusividad." 
        },
        { 
            name = "Mansión Americano", 
            coords = vector3(-1569.46, 27.49, 59.55), 
            icon = "mdi:home-variant", 
            img = "img/Ubicaciones/americano.png", 
            description = "Palacio neoclásico. Una reconstrucción moderna de las grandes mansiones de la costa este. Columnas blancas, entrada circular para limusinas y salones de baile. Un símbolo de dinero viejo y poder tradicional en el corazón de Richman." 
        },
        { 
            name = "Mansión Richman", 
            coords = vector3(-2004.69, 367.59, 94.48), 
            icon = "mdi:home-variant", 
            img = "img/Ubicaciones/brnx_richmanhouse1.png", 
            description = "Finca histórica restaurada. Una de las propiedades originales de Los Santos. Jardines laberínticos, pistas de tenis y una arquitectura que evoca la época dorada. Mantenimiento impecable para un estilo de vida aristocrático." 
        },
        { 
            name = "Mansión Elite", 
            coords = vector3(-718.84, 451.05, 106.91), 
            icon = "mdi:home-variant", 
            img = "img/Ubicaciones/energy_elitehouse.png", 
            description = "Vanguardia arquitectónica. Una estructura de hormigón y cristal que desafía la gravedad. Tecnología domótica de punta, seguridad biométrica y diseño interior de revista. La casa del futuro para el billonario tecnológico de hoy." 
        },
        { 
            name = "Mansión Sunrise", 
            coords = vector3(-1066.02, 728.80, 165.47), 
            icon = "mdi:home-variant", 
            img = "img/Ubicaciones/lks_sunrise.png", 
            description = "El mejor amanecer de la ciudad. Diseñada específicamente para capturar la luz del sol de la mañana sobre Vinewood. Espacios cálidos, materiales naturales y una piscina infinita que se funde con el horizonte. Un hogar que inspira." 
        },
        { 
            name = "Mansión del Faro", 
            coords = vector3(3268.05, 5147.27, 19.57), 
            icon = "mdi:lighthouse", 
            img = "img/Ubicaciones/lodlighthouse.png", 
            description = "Residencia única en El Gordo Lighthouse. Vivir en un faro reconvertido es una experiencia inigualable. Aislada en la costa este, ofrece el sonido constante de las olas y privacidad absoluta. Interiores rústicos pero lujosos. Solo para excéntricos." 
        },
        { 
            name = "Mansión Mystic", 
            coords = vector3(-1269.99, 496.50, 97.16), 
            icon = "mdi:home-variant", 
            img = "img/Ubicaciones/mystc_house.png", 
            description = "Propiedad de diseño conceptual. Líneas limpias y espacios diáfanos definen esta mansión. Cuenta con galería de arte privada y bodega subterránea. Un espacio pensado para impresionar a las visitas y cerrar negocios en un entorno relajado." 
        },
        { 
            name = "Casa del Árbol", 
            coords = vector3(-891.61, 6023.50, 39.50), 
            icon = "mdi:pine-tree", 
            img = "img/Ubicaciones/rjz_treehouse.png", 
            description = "Refugio secreto en Paleto Forest. Una estructura elaborada construida entre secuoyas gigantes. Lejos de ser un juego de niños, es una vivienda totalmente equipada y camuflada. El escondite perfecto para cazadores o supervivencialistas." 
        },
        { 
            name = "Villa", 
            coords = vector3(-1901.30, 636.70, 130.00), 
            icon = "mdi:home-variant", 
            img = "img/Ubicaciones/Villa14.png", 
            description = "Villa mediterránea en las colinas. Tejados de terracota y patios interiores con fuentes. Trae el encanto de la Toscana a Los Santos. Ideal para grandes familias o eventos al aire libre en sus extensos jardines." 
        },
        { 
            name = "Hotel Wiwang", 
            coords = vector3(-828.14, -700.33, 28.06), 
            icon = "mdi:office-building", 
            img = "img/Ubicaciones/map_wiwang_hotel.png", 
            description = "Alojamiento corporativo en el centro. Habitaciones ejecutivas para estancias largas. Ofrece gimnasio, lavandería y cercanía a las oficinas principales. La opción práctica para empresarios que pasan poco tiempo en casa." 
        },
    },

    -- 4. SERVICIOS DE EMERGENCIA
    ["Policía"] = {
        { 
            name = "Comisaría Mission Row", 
            coords = vector3(453.8, -995.65, 31.03), 
            icon = "mdi:police-badge", 
            img = "img/Ubicaciones/artex_mrpd.png", 
            description = "Cuartel General de la LSPD [Artex]. El centro neurálgico de la ley y el orden en la metrópolis. Esta comisaría central gestiona la mayor densidad de llamadas de servicio de la ciudad. Sus instalaciones renovadas incluyen celdas de detención temporal, salas de interrogatorio forense, vestuarios tácticos y un garaje subterráneo seguro. Es el bastión principal contra el crimen organizado en el centro de Los Santos." 
        },
        { 
            name = "Comisaría Paleto Bay", 
            coords = vector3(-450.37, 6001.11, 32.29), 
            icon = "mdi:police-badge-outline", 
            img = "img/Ubicaciones/cfx-gabz-paletopd.png", 
            description = "Destacamento de la Blaine County Sheriff's Office (BCSO) [Gabz]. Situada en la frontera norte, esta estación opera como una fuerza de seguridad autónoma para la región rural. Especializada en intervenciones en carretera y rescates de montaña. Aunque más pequeña que las comisarías de ciudad, cuenta con todo lo necesario para procesar criminales lejos de la civilización." 
        },
        { 
            name = "Academia de Policía", 
            coords = vector3(2527.22, -383.82, 92.99), 
            icon = "mdi:target-account", 
            img = "img/Ubicaciones/ibonoja_sa_training_center.png", 
            description = "Centro de Formación de Seguridad Pública [Ibonoja]. Instalación de excelencia académica y física donde se forjan los futuros oficiales de San Andreas. El campus incluye aulas teóricas, pistas de obstáculos, galerías de tiro avanzadas y circuitos de conducción evasiva. Aquí es donde los civiles se transforman en la delgada línea azul que protege el estado." 
        },
    },
    ["Hospital"] = {
        { 
            name = "Pillbox Medical Center", 
            coords = vector3(332.13, -587.49, 43.19), 
            icon = "mdi:hospital-building", 
            img = "img/Ubicaciones/tstudio_pillbox_md.png", 
            description = "Centro Médico Universitario Pillbox [TStudio]. La institución sanitaria de referencia y Trauma Center de Nivel 1 de Los Santos. Equipado con la última tecnología en diagnóstico por imagen, quirófanos de urgencia y una Unidad de Cuidados Intensivos (UCI) de vanguardia. El personal de EMS opera 24/7 desde esta base para responder a cualquier emergencia médica en el área metropolitana." 
        },
    },
    ["Mecánicos"] = {
        { 
            name = "East Customs", 
            coords = vector3(868.38, -2088.20, 30.20), 
            icon = "mdi:car-wrench", 
            img = "img/Ubicaciones/mechanic_garage.png", 
            description = "Taller de reparaciones generales en la zona industrial. 'East Customs' es conocido por su fiabilidad y trabajo duro. Especializados en chapa, pintura y mantenimiento preventivo para vehículos civiles y flotas comerciales. El entorno es grasiento y ruidoso, pero es el lugar de confianza para devolver la vida a cualquier motor averiado." 
        },
        { 
            name = "Taller Tuner", 
            coords = vector3(168.87, -3030.21, 6.06), 
            icon = "mdi:car-wrench", 
            img = "img/Ubicaciones/np-tuners.png", 
            description = "Centro de Alto Rendimiento Automotriz [NP Style]. Más que un taller, es un laboratorio de velocidad. Especialistas en importaciones JDM, reprogramación de ECUs, instalación de óxido nitroso y kits de carrocería aerodinámicos. El santuario para los entusiastas del drift y las carreras callejeras que buscan exprimir hasta el último caballo de fuerza de sus máquinas." 
        },
        { 
            name = "Hayes Autos", 
            coords = vector3(168.87, -3030.21, 6.06), 
            icon = "mdi:car-wrench", 
            img = "img/Ubicaciones/hayes.png", 
            description = "Taller mecánico de la vieja escuela [Hayes]. Un establecimiento con solera y olor a grasa, especializado en la reparación de motores V8 y mantenimiento general. A diferencia de los talleres de tuning modernos, aquí prima la mecánica pura, el trato cercano y la fiabilidad. El lugar predilecto para restaurar clásicos o poner a punto vehículos de trabajo pesado." 
        },
    },

    -- 5. VARIOS
    ["Otros / Mapeados Generales"] = {
        { 
            name = "Puertas Base Zancudo", 
            coords = vector3(-1601.75, 2808.60, 17.28), 
            icon = "mdi:gate", 
            img = "img/Ubicaciones/ZancudoGates.png", 
            description = "Puesto de control perimetral de Fort Zancudo. Infraestructura fortificada que restringe el acceso civil a la base aérea militar. Equipado con barreras anti-vehículo, torres de vigilancia y zonas de inspección. Cruzar este umbral sin autorización de Nivel 4 se considera una intrusión federal y autoriza el uso de fuerza letal inmediata." 
        },
        { 
            name = "Plaza Garaje Central", 
            coords = vector3(158.17, -908.36, 30.09), 
            icon = "mdi:parking", 
            img = "img/Ubicaciones/fhstrawberrylegionv2.png", 
            description = "Reurbanización de Legion Square y Strawberry Avenue. Este proyecto de infraestructura integra un aparcamiento subterráneo masivo bajo la plaza central de la ciudad. Diseñado para descongestionar el tráfico del distrito financiero, sirve como punto de encuentro neurálgico. Su estructura abierta y moderna conecta las zonas comerciales con el parque público." 
        },
        { 
            name = "Canales de Agua (Rio)", 
            coords = vector3(678.87, -1681.14, 76.44),
            icon = "mdi:water-pump", 
            img = "img/Ubicaciones/cfx-nteam-river.png", 
            description = "Proyecto de revitalización hidráulica del Río de Los Santos. Este mapeado restaura el caudal de agua en los canales de hormigón que atraviesan la metrópolis. Lo que antes era un desagüe pluvial seco, ahora presenta un nivel de agua navegable, cambiando radicalmente la estética y las rutas de escape acuáticas a través del sistema de alcantarillado a cielo abierto." 
        },
        { 
            name = "Puente 1 (Vinewood)", 
            coords = vector3(386.47, 1039.39, 237.66), 
            icon = "mdi:bridge", 
            img = "img/Ubicaciones/puente1.png", 
            description = "Infraestructura de conexión en Vinewood Hills. Este puente elevado salva la orografía accidentada de las colinas, permitiendo un tránsito fluido entre las residencias de lujo y el observatorio. Un punto estratégico para la observación y el control de tráfico en la zona alta." 
        },
        { 
            name = "Puente 2 (Cañón)", 
            coords = vector3(-1343.45, 730.05, 185.76), 
            icon = "mdi:bridge", 
            img = "img/Ubicaciones/puente2.png", 
            description = "Viaducto sobre el cañón de Richman. Una obra de ingeniería civil que conecta las carreteras sinuosas del oeste. Su altura considerable lo convierte en un punto de riesgo para persecuciones a alta velocidad, pero esencial para acortar tiempos de respuesta entre el campo de golf y las colinas." 
        },
        { 
            name = "Puente 3 (Costa)", 
            coords = vector3(-1738.75, -573.92, 37.45), 
            icon = "mdi:bridge", 
            img = "img/Ubicaciones/puente3.png", 
            description = "Pasarela de acceso en Pacific Bluffs. Mejora la conectividad peatonal y vehicular cerca de la autopista costera. Facilita el acceso a las zonas de playa y clubes de tenis, integrándose con la estética moderna de la costa oeste." 
        },
        { 
            name = "Puente 4 (Chiliad A)", 
            coords = vector3(472.21, 5536.04, 785.23), 
            icon = "mdi:bridge", 
            img = "img/Ubicaciones/puente4.png", 
            description = "Estructura de alta montaña en Monte Chiliad. Ubicado a casi 800 metros de altura, este puente desafía el vértigo para conectar senderos que antes eran intransitables. Fundamental para operaciones de rescate en montaña o rutas de senderismo extremo." 
        },
        { 
            name = "Puente 5 (Chiliad B)", 
            coords = vector3(499.51, 5515.50, 778.05), 
            icon = "mdi:bridge", 
            img = "img/Ubicaciones/puente5.png", 
            description = "Conexión secundaria en la cumbre. Parte del complejo de senderos del Monte Chiliad. Permite el paso de vehículos todoterreno (off-road) entre los picos escarpados. La falta de barandillas de seguridad lo convierte en un peligro mortal para conductores inexpertos." 
        },
        { 
            name = "Mina Abandonada", 
            coords = vector3(2929.02, 2795.60, 40.79), 
            icon = "mdi:pickaxe", 
            img = "img/Ubicaciones/mlo_amkzw_mines.png", 
            description = "Complejo minero clausurado en Great Chaparral. Una red de túneles excavados en la roca que datan de la fiebre del oro. Aunque oficialmente condenada por riesgo de derrumbe, la mina ha sido reabierta. Sus galerías oscuras y húmedas son el escondite perfecto para fugitivos o para almacenar contrabando bajo tierra." 
        },
        { 
            name = "Iglesia Rockford Hills", 
            coords = vector3(-761.10, -33.08, 37.83), 
            icon = "mdi:church", 
            img = "img/Ubicaciones/tstudio_rockford_church.png", 
            description = "Parroquia de Rockford Hills [TStudio]. Un santuario de paz en medio de la opulencia. Arquitectura gótica tradicional con un interior detallado que incluye bancos de madera, altar mayor y confesionarios. Espacio solemne utilizado para bodas de la alta sociedad, funerales de mafiosos y búsqueda de redención espiritual." 
        },
    }
}

-- =========================================
--      TEXTOS Y TRADUCCIONES (IDIOMA)
-- =========================================
Config.Lang = {
    TitleAdmin = "ADMINISTRADOR",
    TitleReport = "ENVIAR REPORTE",
    Players = "JUGADORES",
    SearchPlaceholder = "Buscar por Nombre o ID...",
    NoPlayers = "No se encontraron jugadores.",
    ErrorNoWeapon = "No tienes arma",
    ErrorNoTarget = "No hay objetivo",
    SuccessGodmodeOn = "MODO DIOS: ON",
    SuccessGodmodeOff = "MODO DIOS: OFF",
    WhitelistKick = "⛔ EL SERVIDOR HA ACTIVADO LA WHITELIST. Acceso restringido a personal autorizado.",
    WhitelistEnterDeny = "⛔ WHITELIST ACTIVA: No tienes permisos para entrar en este momento.",
    WhitelistAnnounce = "⚠️ MANTENIMIENTO: La Whitelist se activará en %s segundos. Jugadores no autorizados serán expulsados.",
    WhitelistEnabled = "🔒 Whitelist ACTIVADA globalmente.",
    WhitelistDisabled = "🔓 Whitelist DESACTIVADA globalmente."
}
