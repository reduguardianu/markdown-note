import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as P5Support

PlasmoidItem {
    id: root

    property bool isEditing: false

    onIsEditingChanged: {
        console.log("isEditing changed to:", isEditing);
        if (!isEditing) {
            // Check if fullRepresentationItem exists and is loaded
            if (fullRepresentationItem) {
                var textToSave = fullRepresentationItem.noteText;
                Plasmoid.configuration.noteText = textToSave;
                saveToFile(textToSave);
            } else {
                console.log("fullRepresentationItem not loaded, using configuration text");
                saveToFile(Plasmoid.configuration.noteText);
            }
        }
    }

    onExpandedChanged: {
        console.log("expanded changed to:", root.expanded);
        if (!root.expanded && isEditing) {
            isEditing = false;
        }
    }

    // Sync configuration to Plasmoid properties
    hideOnWindowDeactivate: !Plasmoid.configuration.isPinned

    P5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            disconnectSource(sourceName);
        }
    }

    function saveToFile(content) {
        console.log("Attempting to save to file. syncToFile:", Plasmoid.configuration.syncToFile, "path:", Plasmoid.configuration.targetFilePath);
        if (!Plasmoid.configuration.syncToFile || !Plasmoid.configuration.targetFilePath) {
            return;
        }

        var path = Plasmoid.configuration.targetFilePath.toString();
        
        // Escape single quotes for shell command
        var escapedContent = content.replace(/'/g, "'\\''");
        var command = "cat << 'EOF' > '" + path + "'\n" + content + "\nEOF";
        // Actually, echo with heredoc is safer for multi-line
        // But since we are in QML, let's use a simpler approach if possible
        // For now, let's try a simple redirected echo for short notes, 
        // or a base64 approach for robustness
        var b64Content = Qt.btoa(content);
        var safeCommand = "echo '" + b64Content + "' | base64 -d > '" + path + "'";
        
        console.log("Executing shell command:", safeCommand);
        executable.connectSource(safeCommand);
    }

    compactRepresentation: PlasmaComponents.ToolButton {
        icon.name: "edit-paste"
        onClicked: root.expanded = !root.expanded
    }

    fullRepresentation: Rectangle {
        id: fullRepresentationItem
        property alias noteText: textArea.text
        implicitWidth: Kirigami.Units.gridUnit * 15
        implicitHeight: Kirigami.Units.gridUnit * 15
        color: Plasmoid.configuration.backgroundColor

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.smallSpacing
            spacing: Kirigami.Units.smallSpacing

            RowLayout {
                Layout.fillWidth: true
                PlasmaComponents.Label {
                    text: i18n("Markdown Note")
                    font.bold: true
                    Layout.fillWidth: true
                    color: Plasmoid.configuration.textColor
                }
                
                PlasmaComponents.ToolButton {
                    icon.name: Plasmoid.configuration.isPinned ? "window-pin-active" : "window-pin"
                    onClicked: Plasmoid.configuration.isPinned = !Plasmoid.configuration.isPinned
                    display: Controls.AbstractButton.IconOnly
                    Controls.ToolTip.visible: hovered
                    Controls.ToolTip.text: Plasmoid.configuration.isPinned ? i18n("Unpin") : i18n("Pin")
                }

                PlasmaComponents.ToolButton {
                    icon.name: root.isEditing ? "view-preview" : "edit-rename"
                    onClicked: root.isEditing = !root.isEditing;
                    display: Controls.AbstractButton.IconOnly
                    Controls.ToolTip.visible: hovered
                    Controls.ToolTip.text: root.isEditing ? i18n("View Rendered") : i18n("Edit Source")
                }
            }

            Controls.ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                PlasmaComponents.TextArea {
                    id: textArea
                    text: Plasmoid.configuration.noteText
                    color: Plasmoid.configuration.textColor
                    wrapMode: TextEdit.Wrap
                    textFormat: root.isEditing ? TextEdit.PlainText : TextEdit.MarkdownText
                    readOnly: !root.isEditing
                    placeholderText: i18n("Write something...")
                    
                    background: null

                    onTextChanged: {
                        if (root.isEditing && focus) {
                            Plasmoid.configuration.noteText = text
                            console.log("Text changed, restarting timer");
                            saveTimer.restart();
                        }
                    }
                }
            }
        }
    }

    Timer {
        id: saveTimer
        interval: 1000 // Batch saves every second during typing
        repeat: false
        onTriggered: {
            var textToSave = fullRepresentationItem ? fullRepresentationItem.noteText : "";
            if (textToSave !== "") {
                root.saveToFile(textToSave);
            }
        }
    }
}
