# OHTUIE - Interface Frontend

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Status](https://img.shields.io/badge/Status-Development-green?style=for-the-badge)

**OHTUIE** (Optimal Health Tracking & User Information Ecosystem) es una solución integral de vanguardia diseñada para el seguimiento y análisis del ciclo menstrual, el bienestar emocional y la gestión administrativa de datos de salud. Este repositorio contiene el desarrollo del **Frontend**, construido con Flutter para ofrecer una experiencia de usuario fluida, segura y visualmente impactante.

## 🚀 Características Principales

### 📊 Análisis y Predicción de Ciclos
- Algoritmos avanzados para la predicción de ciclos menstruales.
- Visualización interactiva de fases y tendencias mediante gráficos dinámicos.
- Historial detallado de ciclos pasados para un seguimiento a largo plazo.

### 🧠 Bienestar Emocional
- Registro diario de estados de ánimo y síntomas.
- Correlación de datos entre síntomas físicos y estados emocionales.
- Notificaciones personalizadas y recordatorios.

### 🛡️ Módulo Administrativo (Admin Dashboard)
- **Análisis de Datos**: Dashboards avanzados para la visualización de métricas globales.
- **Gestión de Usuarios**: Control total sobre la lista de usuarios y perfiles.
- **Reportes Globales**: Generación y Reportes de todas las respuestas de la app visualizando lo del backend sencillo 
- **Estadísticas de Seguridad**: Monitoreo de actividad y estadísticas de acceso.

### 📈 Visualización y Reportes
- Implementación de `fl_chart` para métricas visuales premium.
- Exportación de datos para análisis externo (PDF, y Impresión).

---

## 🏗️ Estructura del Proyecto

El proyecto sigue una arquitectura modular basada en **Features**, permitiendo una escalabilidad limpia y mantenibilidad a largo plazo.

```text
lib/
├── core/                   # Núcleo de la aplicación
│   ├── network/            # Gestión de APIs y peticiones HTTP
│   ├── services/           # Servicios globales (Notificaciones, Cache, etc.)
│   ├── theme/              # Sistema de diseño, colores y tipografía
│   ├── utils/              # Funciones de ayuda y constantes
│   └── widgets/            # Componentes UI reutilizables
│
└── features/               # Módulos funcionales
    ├── admin/              # Panel de administración y estadísticas de seguridad
    ├── auth/               # Flujos de inicio de sesión y registro
    ├── cycle_analysis/     # Lógica de predicción y visualización analítica
    ├── cycle_setup/        # Configuración inicial del perfil de ciclo
    ├── cycles_history/     # Gestión histórica de registros
    ├── emotions/           # Seguimiento y análisis emocional
    ├── home/               # Vista central del usuario
    ├── profile/            # Gestión de información personal
    └── splash/             # Pantalla de carga y validación inicial
```

---

## 🛠️ Tecnologías y Librerías

- **Framework**: [Flutter](https://flutter.dev/) (SDK ^3.9.0)
- **Gestión de Estado**: Providers / Clean Architecture patterns.
- **Visualización**: `fl_chart` (Gráficos interactivos).
- **Reportes**: `pdf`, `printing`.
- **Almacenamiento Local**: `shared_preferences`.
- **Notificaciones**: `flutter_local_notifications` & `timezone`.

---

## 👥 Equipo de Desarrollo

Este proyecto ha sido diseñado e implementado con los más altos estándares de calidad por:

| Integrante | Rol |
| :--- | :--- |
| **Sara Sofia Romero Hoyos** | Líder de Desarrollo y UI/UX |
| **Luisa Fernanda Gomez Ospino** | Arquitecta de Datos y Seguridad |

---

## ⚙️ Instalación y Configuración

1. **Requisitos previos**:
   - Flutter SDK instalado.
   - Un IDE compatible (VS Code o Android Studio).

2. **Clonar el repositorio**:
   ```bash
   git clone (https://github.com/SararRomero/OHTUIE_FRONT.git)
   ```

3. **Instalar dependencias**:
   ```bash
   flutter pub get
   ```

4. **Ejecutar la aplicación**:
   ```bash
   flutter run
   ```

---

## 📜 Licencia y Autoría

© 2026 **Sara Sofia Romero Hoyos** y **Luisa Fernanda Gomez Ospino**.

Todos los derechos reservados. El diseño de interfaz, la arquitectura de seguridad y el código fuente contenido en este repositorio son propiedad intelectual de sus autoras. No se permite su reproducción total o parcial sin autorización expresa.
