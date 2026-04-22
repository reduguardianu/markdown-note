import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    property bool isEditing: false

    // Sync configuration to Plasmoid properties
    hideOnWindowDeactivate: !Plasmoid.configuration.isPinned

    function saveToFile(content) {
        if (!Plasmoid.configuration.syncToFile || !Plasmoid.configuration.targetFilePath) {
            return;
        }

        var path = Plasmoid.configuration.targetFilePath.toString();
        // Ensure path is a valid URL if it's just a local path
        if (path.indexOf("/") === 0) {
            path = "file://" + path;
        }

        var xhr = new XMLHttpRequest();
        xhr.open("PUT", path);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status !== 200 && xhr.status !== 0) {
                    console.error("Failed to save to file: " + xhr.status);
                }
            }
        };
        xhr.send(content);
    }

    compactRepresentation: PlasmaComponents.ToolButton {
        icon.name: "edit-paste"
        onClicked: root.expanded = !root.expanded
    }

    fullRepresentation: Rectangle {
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
                    onClicked: {
                        if (root.isEditing) {
                            root.saveToFile(textArea.text);
                        }
                        root.isEditing = !root.isEditing;
                    }
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
        onTriggered: root.saveToFile(textArea.text)
    }
}
