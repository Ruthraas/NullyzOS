// Tela de login do NullyzOS (SDDM, Qt6) — #7. Serve para Hyprland e KDE.
// Visual de docs/IDENTIDADE.md: fundo em manchas, relógio grande, cartão de vidro com o N pixelado.
// Sem desfoque de verdade (o SDDM pode estar sem GPU); o vidro é a tinta + borda de luz.
import QtQuick

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#0b0b10"

    readonly property color accent: config.stringValue("accent") || "#9d8cff"
    readonly property color text: "#ededf2"
    readonly property color muted: "#a3a3b3"
    readonly property string font: "Geist"
    readonly property var ptBR: Qt.locale("pt_BR")

    property int userIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
    property int sessionIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
    property string userName: userModel.data(userModel.index(userIndex, 0), Qt.UserRole + 1) || userModel.lastUser
    property string realName: userModel.data(userModel.index(userIndex, 0), Qt.UserRole + 2) || userName
    property string sessionName: sessionModel.data(sessionModel.index(sessionIndex, 0), Qt.UserRole + 4) || "Sessão"
    property bool busy: false

    Image {
        anchors.fill: parent
        source: "fundo.png"
        fillMode: Image.PreserveAspectCrop
        smooth: true
    }

    // ---- relógio -------------------------------------------------------------------
    Column {
        id: clock
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * 0.16
        spacing: 4
        property date now: new Date()
        Timer { interval: 1000; running: true; repeat: true; onTriggered: clock.now = new Date() }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatTime(clock.now, "HH:mm")
            color: root.text
            font { family: root.font; pixelSize: 112; weight: Font.Light; letterSpacing: -3 }
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: clock.now.toLocaleDateString(root.ptBR, "dddd, d 'de' MMMM")
            color: Qt.rgba(0.93, 0.93, 0.95, 0.86)
            font { family: root.font; pixelSize: 24; weight: Font.Medium }
        }
    }

    // ---- cartão de login ----------------------------------------------------------
    Rectangle {
        id: card
        width: 380
        height: 268
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * 0.52
        radius: 28
        color: Qt.rgba(24 / 255, 24 / 255, 34 / 255, 0.6)
        border { width: 1; color: Qt.rgba(1, 1, 1, 0.18) }
        // brilho no topo (luz vindo de cima)
        Rectangle {
            x: 24; y: 1; width: parent.width - 48; height: 1
            color: Qt.rgba(1, 1, 1, 0.35)
        }
        // entrada: sobe um pouco com overshoot
        opacity: 0
        transform: Translate { id: cardMove; y: 18 }
        Component.onCompleted: { enter.start(); password.forceActiveFocus(); }
        ParallelAnimation {
            id: enter
            NumberAnimation { target: card; property: "opacity"; to: 1; duration: 260 }
            NumberAnimation { target: cardMove; property: "y"; to: 0; duration: 420; easing.type: Easing.OutBack }
        }

        Column {
            anchors.centerIn: parent
            spacing: 14
            width: parent.width - 56

            // N pixelado 7x7 (mesmo desenho do símbolo)
            Grid {
                anchors.horizontalCenter: parent.horizontalCenter
                columns: 7; spacing: 2
                Repeater {
                    model: "##...#####..######.####.######..#####...####...##".split("")
                    Rectangle { width: 7; height: 7; radius: 1; color: modelData === "#" ? root.accent : "transparent" }
                }
            }

            Text {
                id: nameLabel
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.realName
                color: root.text
                font { family: root.font; pixelSize: 20; weight: Font.DemiBold }
                MouseArea {
                    anchors.fill: parent
                    enabled: userModel.count > 1
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: root.userIndex = (root.userIndex + 1) % userModel.count
                }
            }

            Rectangle {
                id: field
                width: parent.width
                height: 48
                radius: 14
                color: Qt.rgba(1, 1, 1, 0.07)
                border { width: password.activeFocus ? 2 : 1; color: password.activeFocus ? root.accent : Qt.rgba(1, 1, 1, 0.14) }
                transform: Translate { id: shake }

                TextInput {
                    id: password
                    anchors { fill: parent; leftMargin: 16; rightMargin: 52 }
                    verticalAlignment: TextInput.AlignVCenter
                    echoMode: TextInput.Password
                    passwordCharacter: "●"
                    color: root.text
                    selectionColor: root.accent
                    font { family: root.font; pixelSize: 16 }
                    clip: true
                    enabled: !root.busy
                    Keys.onReturnPressed: root.tryLogin()
                    Keys.onEnterPressed: root.tryLogin()
                    Accessible.name: "Senha"
                }
                Text {
                    anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
                    visible: password.text.length === 0
                    text: root.busy ? "Entrando…" : "Senha"
                    color: root.muted
                    font { family: root.font; pixelSize: 16 }
                }
                Rectangle {
                    width: 36; height: 36; radius: 10
                    anchors { right: parent.right; rightMargin: 6; verticalCenter: parent.verticalCenter }
                    color: root.accent
                    opacity: password.text.length > 0 ? 1 : 0.4
                    Text { anchors.centerIn: parent; text: "→"; color: "#0e0e13"; font { pixelSize: 20; bold: true } }
                    MouseArea { anchors.fill: parent; onClicked: root.tryLogin(); Accessible.name: "Entrar" }
                }
            }

            Text {
                id: error
                anchors.horizontalCenter: parent.horizontalCenter
                text: ""
                color: "#f06a6a"
                font { family: root.font; pixelSize: 14 }
                height: 18
            }
        }
    }

    // tremida curta quando a senha está errada (antecipação + follow-through)
    SequentialAnimation {
        id: shakeAnim
        NumberAnimation { target: shake; property: "x"; to: -12; duration: 50 }
        NumberAnimation { target: shake; property: "x"; to: 10; duration: 70 }
        NumberAnimation { target: shake; property: "x"; to: -6; duration: 60 }
        NumberAnimation { target: shake; property: "x"; to: 0; duration: 90; easing.type: Easing.OutCubic }
    }

    function tryLogin() {
        if (busy || password.text.length === 0) return;
        busy = true;
        error.text = "";
        sddm.login(userName, password.text, sessionIndex);
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            root.busy = false;
            password.text = "";
            error.text = "Senha incorreta";
            shakeAnim.start();
            password.forceActiveFocus();
        }
    }

    // ---- sessão (canto inferior esquerdo) -------------------------------------------
    Rectangle {
        anchors { left: parent.left; bottom: parent.bottom; margins: 28 }
        height: 40; radius: 14
        width: sessionText.implicitWidth + 32
        color: Qt.rgba(24 / 255, 24 / 255, 34 / 255, 0.55)
        border { width: 1; color: Qt.rgba(1, 1, 1, 0.16) }
        Text {
            id: sessionText
            anchors.centerIn: parent
            text: "Sessão: " + root.sessionName + (sessionModel.rowCount() > 1 ? "  ▸" : "")
            color: root.text
            font { family: root.font; pixelSize: 14; weight: Font.Medium }
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.sessionIndex = (root.sessionIndex + 1) % sessionModel.rowCount()
            Accessible.name: "Trocar sessão"
        }
    }

    // ---- energia (canto inferior direito) -------------------------------------------
    Row {
        anchors { right: parent.right; bottom: parent.bottom; margins: 28 }
        spacing: 10
        Repeater {
            model: [
                { label: "Suspender", show: sddm.canSuspend, act: function () { sddm.suspend(); } },
                { label: "Reiniciar", show: sddm.canReboot, act: function () { sddm.reboot(); } },
                { label: "Desligar", show: sddm.canPowerOff, act: function () { sddm.powerOff(); } }
            ]
            Rectangle {
                visible: modelData.show
                height: 40; radius: 14
                width: label.implicitWidth + 32
                color: hover.containsMouse ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(24 / 255, 24 / 255, 34 / 255, 0.55)
                border { width: 1; color: Qt.rgba(1, 1, 1, 0.16) }
                Behavior on color { ColorAnimation { duration: 160 } }
                Text { id: label; anchors.centerIn: parent; text: modelData.label; color: root.text; font { family: root.font; pixelSize: 14; weight: Font.Medium } }
                MouseArea { id: hover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: modelData.act(); Accessible.name: modelData.label }
            }
        }
    }
}
