import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import "theme"
import "scripts/CalculatorEngine.js" as Engine // Moteur commun HTML / Qt.

Window {
    id: root
    title: "Nord Violet Calculator"
    visible: false
    color: "#101016"
    flags: Qt.Window | Qt.FramelessWindowHint
    width: scientific ? 880 : 430
    height: 720
    minimumWidth: scientific ? 790 : 390
    minimumHeight: 600
    property bool scientific: true
    property string angle: "rad"
    property real ans: 0
    property var variables: ({})
    property var history: []
    property string result: "0"
    property string status: "Entrée pour calculer · Échap efface l’expression"
    property bool error: false
    property var memoryEntries: {
        var entries = [{name:"ans", value:root.ans}]
        for (var key in root.variables) entries.push({name:key,value:root.variables[key]})
        return entries
    }
    readonly property var groups: [
        {label:"TRIGONOMÉTRIE", keys:["sin|sin(","cos|cos(","tan|tan(","atan2|atan2(","asin|asin(","acos|acos(","atan|atan(","π|pi"]},
        {label:"HYPERBOLIQUES", keys:["sinh|sinh(","cosh|cosh(","tanh|tanh(","asinh|asinh(","acosh|acosh(","atanh|atanh(","e|e","τ|tau"]},
        {label:"PUISSANCES / LOGARITHMES", keys:["√|sqrt(","∛|cbrt(","xʸ|^","exp|exp(","ln|ln(","log₁₀|log(","log₂|log2(","log1p|log1p(","expm1|expm1(","hypot|hypot(","φ|phi","ans|ans"]},
        {label:"FONCTIONS SPÉCIALES", keys:["W₀|W(","W₋₁|wm1(","Γ|gamma(","n!|!","nCr|ncr(","nPr|npr(","abs|abs(","mod|mod("],special:true},
        {label:"ARRONDIS / ENTIERS", keys:["floor|floor(","ceil|ceil(","round|round(","trunc|trunc(","min|min(","max|max(","PGCD|gcd(","PPCM|lcm(","→ rad|rad(","→ deg|deg(","(|(",")|)"]}
    ]
    function context() { return {angle:angle,ans:ans,variables:variables} }
    function preview(source) { return Engine.NordCalculator.evaluate(source,context()) }
    function evaluateExpression(source) { expression.text=source;calculate() }
    function format(value) { return String(Number(value.toPrecision(14))) }
    function open() {width=scientific?880:430;height=720;showNormal();raise();requestActivate();Qt.callLater(function(){expression.forceActiveFocus()})}
    onScientificChanged: Qt.callLater(function(){root.width=root.scientific?880:430})
    function clearExpression() {expression.text="";result="0";error=false;status="Expression effacée · mémoire conservée"}
    function insert(text) {
        var start=expression.selectionStart,end=expression.selectionEnd
        if(end>start)expression.remove(start,end)
        expression.insert(start,text);expression.cursorPosition=start+text.length
        expression.forceActiveFocus();error=false;status="Entrée pour calculer · "+angle.toUpperCase()
    }
    function calculate() {
        try {
            var source=expression.text.trim(),match=source.match(/^([a-z][a-z0-9_]*)\s*=\s*(.+)$/i),name=null
            if(match){name=match[1].toLowerCase();if(!/^(?:[abchnrtxyz]|x\d{1,2})$/.test(name))throw new Error("Variable : a,b,c,h,n,r,t,x,y,z ou x0…x99");source=match[2]}
            var value=preview(source)
            if(name){var copy=Object.assign({},variables);copy[name]=value;variables=copy}
            ans=value;result=format(value)
            history=[{expression:expression.text,value:value,angle:angle}].concat(history).slice(0,40)
            error=false;status=name?"Variable "+name+" enregistrée":"Calcul réel · "+angle.toUpperCase()+" · valeur interne conservée"
        }catch(e){error=true;status=String(e.message||e)}
        expression.forceActiveFocus()
    }
    onClosing: event => {event.accepted=false;root.hide()}

    component CalcButton: Button {
        property bool accent: false
        property bool special: false
        implicitHeight: 33
        Layout.fillWidth: true
        focusPolicy: Qt.NoFocus
        background: Rectangle {radius:2;color:parent.accent?Theme.accent:parent.down?"#362444":parent.hovered?"#2b2135":parent.special?"#231a2f":"#17151e";border.color:parent.accent?Theme.accent:parent.special?"#574068":"#302738"}
        contentItem: Text {text:parent.text;color:parent.accent?"#1c1125":parent.special?"#d4b5ee":Theme.textPrimary;font.family:"JetBrains Mono";font.pixelSize:11;horizontalAlignment:Text.AlignHCenter;verticalAlignment:Text.AlignVCenter;elide:Text.ElideRight}
    }
    component Caption: Text {color:Theme.textMuted;font.family:"JetBrains Mono";font.pixelSize:9;wrapMode:Text.WordWrap}
    component Divider: Rectangle {Layout.fillWidth:true;Layout.preferredHeight:1;color:"#302738"}

    ColumnLayout {
        anchors.fill:parent;spacing:0
        Rectangle {
            Layout.fillWidth:true;Layout.preferredHeight:48;color:"#17131e"
            RowLayout {
                anchors.fill:parent;anchors.leftMargin:20;anchors.rightMargin:20
                Caption {text:"NVCTL / CALC";color:Theme.accent;font.pixelSize:11}
                Item {Layout.fillWidth:true}
                Caption {text:"RÉELS · FLOAT64";visible:root.scientific}
                CalcButton {Layout.fillWidth:false;implicitWidth:158;text:root.scientific?"[ − SCIENTIFIQUE ]":"[ + SCIENTIFIQUE ]";special:true;onClicked:root.scientific=!root.scientific}
            }
        }
        Divider {}
        RowLayout {
            Layout.fillWidth:true;Layout.fillHeight:true;spacing:0
            ScrollView {
                id:primaryScroll
                Layout.fillWidth:true;Layout.fillHeight:true;Layout.minimumHeight:0;Layout.minimumWidth:0;clip:true
                contentWidth:availableWidth;ScrollBar.horizontal.policy:ScrollBar.AlwaysOff
                ColumnLayout {
                    width:primaryScroll.availableWidth;spacing:0
                    ColumnLayout {
                        Layout.fillWidth:true;Layout.margins:20;spacing:12
                        RowLayout {
                            Layout.fillWidth:true
                            Caption {text:"[ EXPRESSION ]";color:Theme.accent;font.pixelSize:10}
                            Item {Layout.fillWidth:true}
                            Repeater {
                                model:["rad","deg"]
                                delegate:CalcButton {required property string modelData;Layout.fillWidth:false;implicitWidth:43;implicitHeight:25;text:modelData.toUpperCase();special:root.angle===modelData;onClicked:{root.angle=modelData;root.status="Mode "+modelData.toUpperCase();root.error=false}}
                            }
                        }
                        Caption {text:"Saisie libre · W(1), x = 12…";font.pixelSize:10}
                        TextField {
                            id:expression
                            Layout.fillWidth:true;implicitHeight:44;placeholderText:"› expression";selectByMouse:true
                            color:"#d6c3e9";font.family:"JetBrains Mono";font.pixelSize:14
                            placeholderTextColor:Theme.textMuted
                            background:Rectangle {color:"#15121c";border.color:"#35293f";radius:2}
                            onAccepted:root.calculate()
                            Keys.onEscapePressed: event => {root.clearExpression();event.accepted=true}
                        }
                        Caption {Layout.fillWidth:true;text:root.result;color:Theme.textPrimary;font.pixelSize:33;wrapMode:Text.WrapAnywhere;Layout.minimumHeight:48}
                        Caption {Layout.fillWidth:true;text:root.status;color:root.error?Theme.danger:Theme.textMuted;font.pixelSize:10;Layout.minimumHeight:35}
                        GridLayout {
                            Layout.fillWidth:true;columns:4;rowSpacing:6;columnSpacing:6
                            Repeater {
                                model:["AC|clear","⌫|delete","%|%","÷|/","7|7","8|8","9|9","×|*","4|4","5|5","6|6","−|-","1|1","2|2","3|3","+|+",",|,","0|0",".|.","=|calculate"]
                                delegate:CalcButton {
                                    required property string modelData
                                    property string keyAction:modelData.split("|")[1]
                                    text:modelData.split("|")[0];implicitHeight:40;accent:keyAction==="calculate";special:["/","*","-","+"].indexOf(keyAction)>=0
                                    onClicked:{if(keyAction==="clear")root.clearExpression();else if(keyAction==="calculate")root.calculate();else if(keyAction==="delete"){var s=expression.selectionStart,e=expression.selectionEnd;expression.remove(s===e?Math.max(0,s-1):s,e);expression.forceActiveFocus()}else root.insert(keyAction)}
                                }
                            }
                        }
                    }
                    Divider {}
                    ColumnLayout {
                        Layout.fillWidth:true;Layout.margins:20;spacing:10
                        RowLayout {Layout.fillWidth:true;Caption {text:"[ MÉMOIRE / VARIABLES ]"} Item {Layout.fillWidth:true} CalcButton {Layout.fillWidth:false;implicitWidth:58;implicitHeight:24;text:"VIDER";onClicked:{root.variables={};root.ans=0}}}
                        Flow {
                            Layout.fillWidth:true;spacing:6
                            Repeater {model:root.memoryEntries;delegate:CalcButton {required property var modelData;text:modelData.name+" = "+root.format(modelData.value);implicitWidth:Math.min(330,Math.max(90,implicitContentWidth+18));implicitHeight:28;onClicked:root.insert(modelData.name)}}
                        }
                        Caption {Layout.fillWidth:true;text:"x = 12, puis x^2 + ans\nVariables : a,b,c,h,n,r,t,x,y,z et x0…x99"}
                    }
                    Divider {}
                    ColumnLayout {
                        Layout.fillWidth:true;Layout.margins:20;spacing:7
                        RowLayout {Layout.fillWidth:true;Caption {text:"[ JOURNAL ]"} Item {Layout.fillWidth:true} CalcButton {Layout.fillWidth:false;implicitWidth:58;implicitHeight:24;text:"VIDER";onClicked:root.history=[]}}
                        Caption {visible:root.history.length===0;text:"Votre prochain calcul inaugure le journal."}
                        Repeater {model:root.history.slice(0,6);delegate:CalcButton {required property var modelData;text:modelData.expression+" → "+root.format(modelData.value);implicitHeight:31;onClicked:{expression.text=String(modelData.value);expression.cursorPosition=expression.text.length;expression.forceActiveFocus()} ToolTip.visible:hovered;ToolTip.text:modelData.expression+" · "+modelData.angle.toUpperCase()}}
                    }
                }
            }
            Divider {visible:root.scientific;Layout.fillWidth:false;Layout.fillHeight:true;Layout.preferredWidth:1}
            ScrollView {
                id:scientificScroll
                visible:root.scientific;Layout.preferredWidth:410;Layout.minimumWidth:0;Layout.fillHeight:true;Layout.minimumHeight:0;clip:true
                contentWidth:availableWidth;ScrollBar.horizontal.policy:ScrollBar.AlwaysOff
                ColumnLayout {
                    width:scientificScroll.availableWidth;spacing:16
                    ColumnLayout {
                        Layout.fillWidth:true;Layout.margins:20;spacing:16
                        Caption {text:"[ OUTILS SCIENTIFIQUES ]";color:Theme.accent;font.pixelSize:10}
                        Repeater {
                            model:root.groups
                            delegate:ColumnLayout {
                                required property var modelData
                                Layout.fillWidth:true;spacing:10
                                Divider {}
                                Caption {text:modelData.label}
                                GridLayout {
                                    Layout.fillWidth:true;columns:4;rowSpacing:5;columnSpacing:5
                                    Repeater {model:modelData.keys;delegate:CalcButton {required property string modelData;text:modelData.split("|")[0];special:/^(W|Γ)/.test(text);onClicked:root.insert(modelData.split("|")[1])}}
                                }
                                Caption {visible:!!modelData.special;Layout.fillWidth:true;text:"W₀ : x ≥ −1/e · W₋₁ : −1/e ≤ x < 0\nGamma : pôles aux entiers ≤ 0 · n! : 0…170"}
                            }
                        }
                        Caption {Layout.fillWidth:true;text:"Arguments séparés par des virgules : ncr(10,3).\nRéels en double précision. Pas de calcul symbolique ou complexe."}
                    }
                }
            }
        }
        Divider {}
        Caption {Layout.fillWidth:true;Layout.margins:14;text:"Entrée calculer · Échap effacer · Super+Q fermer"}
    }
}
