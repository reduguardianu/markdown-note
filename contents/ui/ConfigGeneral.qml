import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.kquickcontrols as KQuickControls

Kirigami.FormLayout {
    id: page

    property alias cfg_backgroundColor: colorButton.color
    property alias cfg_textColor: textColorButton.color
    property alias cfg_syncToFile: syncCheckbox.checked
    property alias cfg_targetFilePath: fileField.text

    KQuickControls.ColorButton {
        id: colorButton
        Kirigami.FormData.label: i18n("Background Color:")
    }

    KQuickControls.ColorButton {
        id: textColorButton
        Kirigami.FormData.label: i18n("Text Color:")
    }

    CheckBox {
        id: syncCheckbox
        Kirigami.FormData.label: i18n("Sync to Disk:")
        text: i18n("Automatically save note to a .md file")
    }

    TextField {
        id: fileField
        Kirigami.FormData.label: i18n("Target File Path:")
        placeholderText: i18n("/path/to/note.md")
        enabled: syncCheckbox.checked
        Layout.fillWidth: true
    }
}
