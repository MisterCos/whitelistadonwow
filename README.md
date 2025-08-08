# MyFirstAddon - Player Rating System for WoW

A World of Warcraft addon that allows you to rate and track player performance in dungeons.

## 🎯 Features

- **Rating interface** at the end of dungeons
- **Class icons** with official WoW colors
- **Role icons** (Tank, Healer, DPS) with official icons
- **Rating system** from 1 to 10
- **Persistent storage** of ratings
- **Slash commands** for whitelist management
- **Modular architecture** organized in folders

## 📦 Installation

1. Download the addon from [GitHub](https://github.com/MisterCos/whitelistadonwow)
2. Extract the `MyFirstAddon` folder to your addons directory:
   ```
   World of Warcraft/_retail_/Interface/AddOns/MyFirstAddon/
   ```
3. Restart WoW or run `/reload`

## 🚀 Usage

### Rating Interface
- **Test button**: "Simulate Dungeon End" (temporary for testing)
- **Rating modal**: Shows the list of group players
- **Rating**: Dropdown from 1 to 10 for each player
- **Save**: Button to save the ratings

### Slash Commands

| Command | Description | Example |
|---------|-------------|---------|
| `/adduser` | Add player to whitelist | `/adduser PlayerName 8 tank` |
| `/showstats` | Show player statistics | `/showstats PlayerName tank` |
| `/printwhitelist` | Show entire whitelist | `/printwhitelist` |
| `/removewhitelist` | Remove entire whitelist | `/removewhitelist` |

## 🏗️ Architecture

```
MyFirstAddon/
├── MyFirstAddon.toc          # Addon configuration
├── core/                     # Main logic
│   ├── Main.lua             # Entry point
│   ├── Commands.lua         # Slash commands
│   ├── Whitelist.lua        # Data management
│   └── ClassColors.lua      # Colors and icons
├── data/                    # Data handling
│   └── GroupData.lua        # Group data
└── ui/                      # User interface
    └── UI.lua               # Rating interface
```

## 🎨 Visual Features

### Class Icons
- **Official WoW colors** for each class
- **Class icons** in the player list
- **Colored names** according to class

### Role Icons
- **Tank**: Official WoW shield
- **Healer**: Official medical cross
- **DPS**: Official sword
- **High resolution** using official textures

## 💾 Data Storage

The addon uses `SavedVariables` to store:
- Ratings per player
- Specific role (tank/healer/dps)
- Date and time of each encounter
- Averages and statistics

## 🔧 Configuration

### Supported Versions
- **WoW Retail**: 11.2 (TWW) and above
- **Interface**: 110107, 110200, 110205

### Saved Variables
```lua
WhiteListDB = {
    ["PlayerName"] = {
        tank = {{date = "08/08/2024 17:30:00", note = "8"}},
        healer = {{date = "08/08/2024 17:30:00", note = "7"}},
        dps = {{date = "08/08/2024 17:30:00", note = "9"}}
    }
}
```

## 🐛 Troubleshooting

### The addon doesn't appear
- Verify it's in the correct folder
- Run `/reload` in WoW
- Check for errors in chat

### Icons don't show
- Make sure you're on WoW 11.2+
- Icons use official WoW textures

### Ratings don't save
- Verify you have write permissions
- Check that `SavedVariables` is enabled

## 🔮 Upcoming Features

- [ ] Automatic dungeon end detection
- [ ] Advanced statistics and graphs
- [ ] Filters and search in whitelist
- [ ] Export/import data
- [ ] Notifications for known players
- [ ] Configuration interface

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a branch for your feature
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📄 License

This project is under the MIT License. See the `LICENSE` file for more details.

## 👨‍💻 Author

**MisterCos** - [GitHub](https://github.com/MisterCos)

## 🙏 Acknowledgments

- Blizzard Entertainment for the WoW API
- WoW addon developer community
- Everyone who has tested and provided feedback for the addon

---

**Enjoy tracking your dungeon companions' performance!** 🎮⚔️
