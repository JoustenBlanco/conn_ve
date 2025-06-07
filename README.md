# 🚗🔋 Connected Vehicles

**Connected Vehicles** es una aplicación móvil desarrollada en Flutter con Supabase como backend, diseñada para propietarios de vehículos eléctricos (VE). Su objetivo es mejorar la experiencia de conducción con herramientas inteligentes para la planificación de rutas, estaciones de carga interactivas, comunidad social y conciencia ambiental.

![App Icon](lib/shared/images/logoCV.png)

---

## 🏫 Proyecto Académico

- **Universidad Nacional**
- **Sede Regional Brunca – Campus Pérez Zeledón**
- **Curso:** Diseño y Programación de Plataformas Móviles
- **Proyecto**

---

## 📱 Características Principales

### 🗺️ Planificación de Rutas Inteligentes

- Planificación de viajes indicando origen y destino.
- Rutas optimizadas según la autonomía del VE.
- Estaciones de carga mostradas a lo largo del trayecto.
- Filtros por tipo de cargador (rápido, estándar) y marcas compatibles.

### 📍 Mapa Interactivo de Cargadores

- Estaciones de carga en tiempo real en un mapa.
- Información detallada: disponibilidad, tarifas, tipo de enchufe, potencia, horarios.
- Filtros avanzados (gratuito, cargador rápido, ocupado, etc.).

### 🧑‍🤝‍🧑 Red Social para Conductores de VE

- Foro para compartir consejos y experiencias.
- Calificaciones y reseñas de estaciones.
- Grupos locales para actividades o encuentros.

### 💸 Calculadora de Costos y Emisiones

- Comparación de costos entre VE y vehículos a gasolina.
- Visualización de emisiones de CO₂ ahorradas.

### 🔔 Alertas y Notificaciones

- Recordatorios para carga antes de viajes largos.
- Nuevas estaciones en la región.
- Ofertas y promociones disponibles.

---

## 🛠️ Tecnologías Utilizadas

| Tecnología      | Descripción                                                        |
| --------------- | ------------------------------------------------------------------ |
| **Flutter**     | Framework para la interfaz de usuario móvil.                       |
| **Supabase**    | Backend como servicio (autenticación, PostgreSQL, almacenamiento). |
| **Google Maps** | API de mapas y geolocalización.                                    |
| **Dart**        | Lenguaje de programación para Flutter.                             |

---

## 🗂️ Estructura del Proyecto

lib/
├── pages/ # Pantallas principales (mapa, comunidad, rutas, etc.)
├── services/ # Lógica de conexión con Supabase, mapas, notificaciones
├── shared/
│ ├── images/ # Recursos gráficos e íconos (incluye el ícono de la app)
│ └── styles/ # Temas, colores, y estilos compartidos
└── widgets/ # Componentes reutilizables de UI

## 🚀 Instalación y Ejecución

```bash
# 1. Clona el repositorio
git clone https://github.com/JoustenBlanco/conn_ve.git
cd connected-vehicles

# 2. Instala las dependencias del proyecto
flutter pub get
```

# Corre la aplicación en un emulador o dispositivo conectado

flutter run
