import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.taskmanager as TaskManager

// Barra do NullyzOS no KDE: o nome do app em foco, em negrito, antes do menu global
// (Arquivo, Editar…). Sem janela em foco: "Área de trabalho".
PlasmoidItem {
    id: root
    preferredRepresentation: fullRepresentation
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    TaskManager.TasksModel {
        id: tasks
        groupMode: TaskManager.TasksModel.GroupDisabled
    }
    readonly property string appName: {
        const i = tasks.activeTask;
        if (!i || !i.valid) return "";
        return tasks.data(i, TaskManager.AbstractTasksModel.AppName) || "";
    }

    fullRepresentation: PlasmaComponents.Label {
        Layout.minimumWidth: implicitWidth
        Layout.preferredWidth: implicitWidth
        Layout.maximumWidth: implicitWidth
        Layout.fillHeight: true
        verticalAlignment: Text.AlignVCenter
        leftPadding: 6
        rightPadding: 2
        text: root.appName || "Área de trabalho"
        font.weight: Font.Bold
        textFormat: Text.PlainText
    }
}
