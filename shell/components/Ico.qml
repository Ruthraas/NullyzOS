import QtQuick
import QtQuick.Shapes
import qs.theme

// Ícone em traço a partir de um caminho SVG de 24×24 (mesmos desenhos das pranchas).
// Sem fonte de ícones: nada para faltar no sistema.
Item {
    id: root
    property string d: ""
    property real size: 18
    property color color: Tok.text
    property real stroke: 1.8
    implicitWidth: size
    implicitHeight: size

    Shape {
        anchors.fill: parent
        // CurveRenderer é mais liso, mas no desenho por software (VM) ignora o recorte das listas
        // que rolam (ícone vazava para fora do cartão): lá fica o renderizador padrão.
        preferredRendererType: Tok.vm ? Shape.UnknownRenderer : Shape.CurveRenderer
        transform: Scale { xScale: root.size / 24; yScale: root.size / 24 }
        ShapePath {
            strokeColor: root.color
            strokeWidth: root.stroke
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            PathSvg { path: root.d }
        }
    }
}
