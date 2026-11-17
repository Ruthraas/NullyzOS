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

    // ---- sessão (topo): todas as opções lado a lado, a ativa em destaque ---------------
    Rectangle {
        id: sessionBar
        anchors { left: parent.left; top: parent.top; margins: 28 }
        height: 44; radius: 16
        width: sessionRow.implicitWidth + 8
        color: Qt.rgba(24 / 255, 24 / 255, 34 / 255, 0.55)
        border { width: 1; color: Qt.rgba(1, 1, 1, 0.16) }
        Row {
            id: sessionRow
            anchors.centerIn: parent
            spacing: 4
            Repeater {
                model: sessionModel
                Rectangle {
                    required property int index
                    required property string name
                    readonly property bool active: index === root.sessionIndex
                    height: 36; radius: 12
                    width: sessLabel.implicitWidth + 28
                    color: active ? root.accent : (sessHover.containsMouse ? Qt.rgba(1, 1, 1, 0.10) : "transparent")
                    Behavior on color { ColorAnimation { duration: 160 } }
                    Text {
                        id: sessLabel
                        anchors.centerIn: parent
                        text: name
                        color: parent.active ? "#0e0e13" : root.text
                        font { family: root.font; pixelSize: 14; weight: parent.active ? Font.DemiBold : Font.Medium }
                    }
                    MouseArea {
                        id: sessHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.sessionIndex = index
                        Accessible.name: "Sessão " + name
                    }
                }
            }
        }
    }

    // ---- energia (canto inferior direito): ícones, um embaixo do outro ---------------
    // Ícones desenhados em traço (Canvas), sem depender de fonte de ícones instalada.
    component PowerIcon: Canvas {
        property string kind: "power"
        property color tint: root.text
        width: 20; height: 20
        onTintChanged: requestPaint()
        onPaint: {
            const c = getContext("2d");
            c.reset();
            c.strokeStyle = tint; c.fillStyle = tint;
            c.lineWidth = 2; c.lineCap = "round"; c.lineJoin = "round";
            const m = width / 2;
            if (kind === "power") {
                c.beginPath(); c.arc(m, m + 1, 7, -Math.PI * 0.3, Math.PI * 1.3); c.stroke();
                c.beginPath(); c.moveTo(m, 2); c.lineTo(m, m); c.stroke();
            } else if (kind === "restart") {
                c.beginPath(); c.arc(m, m, 7, -Math.PI * 0.15, Math.PI * 1.6); c.stroke();
                c.beginPath(); c.moveTo(m + 7, 2.5); c.lineTo(m + 7, m - 1.5); c.lineTo(m + 2.5, m - 1.5); c.stroke();
            } else {             // suspender: lua crescente
                c.fillRule = Qt.OddEvenFill;
                c.beginPath(); c.arc(m, m, 7.5, 0, Math.PI * 2);
                c.moveTo(m + 10.5, m - 3.5); c.arc(m + 4.5, m - 3.5, 6, 0, Math.PI * 2); c.fill();
            }
        }
    }

    Column {
        anchors { right: parent.right; bottom: parent.bottom; margins: 28 }
        spacing: 10
        Repeater {
            model: [
                { label: "Suspender", kind: "sleep", show: sddm.canSuspend, act: function () { sddm.suspend(); } },
                { label: "Reiniciar", kind: "restart", show: sddm.canReboot, act: function () { sddm.reboot(); } },
                { label: "Desligar", kind: "power", show: sddm.canPowerOff, act: function () { sddm.powerOff(); } }
            ]
            Rectangle {
                id: btn
                visible: modelData.show
                width: 48; height: 48; radius: 24
                color: hover.containsMouse ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(24 / 255, 24 / 255, 34 / 255, 0.55)
                border { width: 1; color: Qt.rgba(1, 1, 1, 0.16) }
                scale: hover.pressed ? 0.92 : (hover.containsMouse ? 1.06 : 1)
                Behavior on color { ColorAnimation { duration: 160 } }
                Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutBack } }
                PowerIcon {
                    anchors.centerIn: parent
                    kind: modelData.kind
                    tint: modelData.kind === "power" && hover.containsMouse ? "#f06a6a" : root.text
                }
                // nome ao lado, aparece no hover
                Rectangle {
                    anchors { right: parent.left; rightMargin: 10; verticalCenter: parent.verticalCenter }
                    height: 30; radius: 10
                    width: tip.implicitWidth + 20
                    color: Qt.rgba(14 / 255, 14 / 255, 19 / 255, 0.85)
                    opacity: hover.containsMouse ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 140 } }
                    Text { id: tip; anchors.centerIn: parent; text: modelData.label; color: root.text; font { family: root.font; pixelSize: 13 } }
                }
                MouseArea { id: hover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: modelData.act(); Accessible.name: modelData.label }
            }
        }
    }
}
