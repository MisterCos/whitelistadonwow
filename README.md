# MyFirstAddon - Sistema de Calificación de Jugadores para WoW

Un addon para World of Warcraft que permite calificar y hacer seguimiento del rendimiento de jugadores en dungeons.

## 🎯 Características

- **Interfaz de calificación** al final de dungeons
- **Iconos de clase** con colores oficiales de WoW
- **Iconos de rol** (Tank, Healer, DPS) con iconos oficiales
- **Sistema de calificación** del 1 al 10
- **Almacenamiento persistente** de calificaciones
- **Comandos slash** para gestión de la whitelist
- **Arquitectura modular** organizada en carpetas

## 📦 Instalación

1. Descarga el addon desde [GitHub](https://github.com/MisterCos/whitelistadonwow)
2. Extrae la carpeta `MyFirstAddon` en tu directorio de addons:
   ```
   World of Warcraft/_retail_/Interface/AddOns/MyFirstAddon/
   ```
3. Reinicia WoW o ejecuta `/reload`

## 🚀 Uso

### Interfaz de Calificación
- **Botón de prueba**: "Simular Fin Dungeon" (temporal para testing)
- **Modal de calificación**: Aparece con la lista de jugadores del grupo
- **Calificación**: Dropdown del 1 al 10 para cada jugador
- **Guardar**: Botón para guardar las calificaciones

### Comandos Slash

| Comando | Descripción | Ejemplo |
|---------|-------------|---------|
| `/adduser` | Añadir jugador a la whitelist | `/adduser NombreJugador 8 tank` |
| `/showstats` | Mostrar estadísticas de un jugador | `/showstats NombreJugador tank` |
| `/printwhitelist` | Mostrar toda la whitelist | `/printwhitelist` |
| `/removewhitelist` | Eliminar toda la whitelist | `/removewhitelist` |

## 🏗️ Arquitectura

```
MyFirstAddon/
├── MyFirstAddon.toc          # Configuración del addon
├── core/                     # Lógica principal
│   ├── Main.lua             # Punto de entrada
│   ├── Commands.lua         # Comandos slash
│   ├── Whitelist.lua        # Gestión de datos
│   └── ClassColors.lua      # Colores e iconos
├── data/                    # Manejo de datos
│   └── GroupData.lua        # Datos del grupo
└── ui/                      # Interfaz de usuario
    └── UI.lua               # Interfaz de calificación
```

## 🎨 Características Visuales

### Iconos de Clase
- **Colores oficiales** de WoW para cada clase
- **Iconos de clase** en la lista de jugadores
- **Nombres coloreados** según la clase

### Iconos de Rol
- **Tank**: Escudo oficial de WoW
- **Healer**: Cruz médica oficial
- **DPS**: Espada oficial
- **Alta resolución** usando texturas oficiales

## 💾 Almacenamiento de Datos

El addon utiliza `SavedVariables` para guardar:
- Calificaciones por jugador
- Rol específico (tank/healer/dps)
- Fecha y hora de cada encuentro
- Promedios y estadísticas

## 🔧 Configuración

### Versiones Soportadas
- **WoW Retail**: 11.2 (TWW) y superiores
- **Interface**: 110107, 110200, 110205

### Variables Guardadas
```lua
WhiteListDB = {
    ["NombreJugador"] = {
        tank = {{date = "08/08/2024 17:30:00", note = "8"}},
        healer = {{date = "08/08/2024 17:30:00", note = "7"}},
        dps = {{date = "08/08/2024 17:30:00", note = "9"}}
    }
}
```

## 🐛 Solución de Problemas

### El addon no aparece
- Verifica que esté en la carpeta correcta
- Ejecuta `/reload` en WoW
- Comprueba que no haya errores en el chat

### Los iconos no se ven
- Asegúrate de estar en WoW 11.2+
- Los iconos usan texturas oficiales de WoW

### No se guardan las calificaciones
- Verifica que tengas permisos de escritura
- Comprueba que `SavedVariables` esté habilitado

## 🔮 Próximas Características

- [ ] Detección automática del fin de dungeon
- [ ] Estadísticas avanzadas y gráficos
- [ ] Filtros y búsqueda en la whitelist
- [ ] Exportar/importar datos
- [ ] Notificaciones de jugadores conocidos
- [ ] Interfaz de configuración

## 🤝 Contribuciones

¡Las contribuciones son bienvenidas! Por favor:

1. Fork el repositorio
2. Crea una rama para tu feature
3. Commit tus cambios
4. Push a la rama
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 👨‍💻 Autor

**MisterCos** - [GitHub](https://github.com/MisterCos)

## 🙏 Agradecimientos

- Blizzard Entertainment por la API de WoW
- Comunidad de desarrolladores de addons de WoW
- Todos los que han probado y dado feedback del addon

---

**¡Disfruta trackeando el rendimiento de tus compañeros de dungeon!** 🎮⚔️
