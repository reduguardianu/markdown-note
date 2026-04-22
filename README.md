# Markdown Note Plasma Widget

A sticky note widget for KDE Plasma with Markdown support and customizable colors.

## Features
- **Markdown Rendering**: Toggle between editing source and viewing rendered Markdown.
- **Customizable Colors**: Change background and text colors via the configuration dialog.
- **Sticky Note**: Stays in your panel or on your desktop as a slide-out panel.

## Installation

### Manual Installation
You can install the widget using `kpackagetool6`:

```bash
kpackagetool6 -t Plasma/Applet -i .
```

To update an existing installation:
```bash
kpackagetool6 -t Plasma/Applet -u .
```

### Build with CMake
```bash
mkdir build
cd build
cmake ..
make
sudo make install
```

## Usage
1. Add the "Markdown Note" widget to your panel or desktop.
2. Click the icon to open the note.
3. Use the edit icon in the top right to toggle between Markdown preview and text editor.
4. Right-click the widget and select "Configure Markdown Note..." to change colors.
