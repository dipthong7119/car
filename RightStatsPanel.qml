import QtQuick 2.15

Item {
    id: root
    width: 246
    height: 400

    property int themeIndex: 0
    property color primary: "#00e5cc"
    property color accent: "#00ff88"
    property color speedColor: "#00d4ff"
    property color rpmColor: "#9966ff"
    property color tempColor: "#ffaa00"
    property color dangerColor: "#ff4444"
    property color warningColor: "#ffcc00"
    property color displayTempColor: tempColor
    property color primaryBorder: Qt.rgba(0, 0.9, 0.8, 0.15)
    property color rpmBorder: Qt.rgba(0.6, 0.4, 1, 0.2)
    property color tempBorder: Qt.rgba(1, 0.67, 0, 0.2)
    property color accentBorder: Qt.rgba(0, 1, 0.5, 0.2)
    property color warningBorder: Qt.rgba(1, 0.8, 0, 0.2)
    property real displaySpeedKmh: 0
    property real displayRpm: 0
    property real temperature: 0
    property real batteryLevel: 10.0
    property bool batteryCriticalVisible: true

    // GPS & Navigation properties
    property real remainingDistKm: 3.8
    property int remainingMinutes: 8
    property string etaTime: "17:45"
    property string nextTurnText: "250m Rẽ Phải"
    property string nextStreetName: "Đường Nguyễn Trãi"
    property int speedLimit: 60
    property string headingText: "NW 315°"
    property real radarPhase: 0.0
    property real routeDashOffset: 0.0

    onThemeIndexChanged: repaint()
    onPrimaryChanged: repaint()
    onAccentChanged: repaint()
    onDisplaySpeedKmhChanged: {
        // Dynamic heading adjustment when turning/speeding
        if (root.displaySpeedKmh > 40) {
            root.headingText = "NNW 330°"
        } else if (root.displaySpeedKmh > 10) {
            root.headingText = "NW 315°"
        } else {
            root.headingText = "N 360°"
        }
    }

    function repaint() {
        turnIconCanvas.requestPaint()
        mapCanvas.requestPaint()
    }

    // Animation loop for route glow pulse and radar scan
    Timer {
        interval: 40
        running: root.visible
        repeat: true
        onTriggered: {
            var speedFactor = Math.max(root.displaySpeedKmh / 20.0, 1.0)
            root.routeDashOffset = (root.routeDashOffset + 0.8 * speedFactor) % 24
            root.radarPhase = (root.radarPhase + 0.02) % 1.0
            mapCanvas.requestPaint()
        }
    }

    Column {
        x: 14
        y: 4
        spacing: 10
        width: 218

        // ==========================================
        // 1. Turn-by-turn guidance header card
        // ==========================================
        Rectangle {
            width: 218
            height: 68
            radius: 12
            color: Qt.rgba(1, 1, 1, 0.04)
            border.color: root.primaryBorder
            border.width: 1

            Row {
                x: 14
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                Rectangle {
                    width: 38
                    height: 38
                    radius: 8
                    anchors.verticalCenter: parent.verticalCenter
                    color: Qt.rgba(root.primary.r, root.primary.g, root.primary.b, 0.12)
                    border.color: Qt.rgba(root.primary.r, root.primary.g, root.primary.b, 0.35)
                    border.width: 1

                    Canvas {
                        id: turnIconCanvas
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)
                            ctx.strokeStyle = root.primary
                            ctx.lineWidth = 2.8
                            ctx.lineCap = "round"
                            ctx.lineJoin = "round"

                            // Upward and right turning arrow path
                            ctx.beginPath()
                            ctx.moveTo(12, 28)
                            ctx.lineTo(12, 17)
                            ctx.arcTo(12, 10, 19, 10, 7)
                            ctx.lineTo(26, 10)
                            ctx.stroke()

                            // Arrowhead
                            ctx.beginPath()
                            ctx.moveTo(21, 5)
                            ctx.lineTo(26, 10)
                            ctx.lineTo(21, 15)
                            ctx.stroke()
                        }
                    }
                }

                Column {
                    spacing: 3
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: root.nextTurnText
                        color: root.primary
                        font.pixelSize: 14
                        font.bold: true
                        font.family: "Courier New"
                    }

                    Text {
                        text: root.nextStreetName
                        color: Qt.rgba(1, 1, 1, 0.5)
                        font.pixelSize: 10
                        font.family: "Courier New"
                    }
                }
            }
        }

        // ==========================================
        // 2. Cyberpunk Vector Map HUD
        // ==========================================
        Rectangle {
            width: 218
            height: 220
            radius: 12
            color: Qt.rgba(0, 0, 0, 0.45)
            border.color: root.primaryBorder
            border.width: 1
            clip: true

            Canvas {
                id: mapCanvas
                anchors.fill: parent

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)

                    // 1. Cyberpunk Grid Mesh
                    ctx.strokeStyle = Qt.rgba(root.primary.r, root.primary.g, root.primary.b, 0.07)
                    ctx.lineWidth = 0.5
                    var step = 20
                    for (var x = step; x < width; x += step) {
                        ctx.beginPath()
                        ctx.moveTo(x, 0)
                        ctx.lineTo(x, height)
                        ctx.stroke()
                    }
                    for (var y = step; y < height; y += step) {
                        ctx.beginPath()
                        ctx.moveTo(0, y)
                        ctx.lineTo(width, y)
                        ctx.stroke()
                    }

                    // 2. Road Network Layout
                    ctx.strokeStyle = "rgba(255, 255, 255, 0.08)"
                    ctx.lineWidth = 8
                    ctx.lineCap = "round"
                    ctx.lineJoin = "round"

                    // Street A (horizontal)
                    ctx.beginPath(); ctx.moveTo(0, 75); ctx.lineTo(width, 75); ctx.stroke()
                    // Street B (horizontal)
                    ctx.beginPath(); ctx.moveTo(0, 150); ctx.lineTo(width, 150); ctx.stroke()
                    // Street C (vertical)
                    ctx.beginPath(); ctx.moveTo(60, 0); ctx.lineTo(60, height); ctx.stroke()
                    // Street D (vertical)
                    ctx.beginPath(); ctx.moveTo(160, 0); ctx.lineTo(160, height); ctx.stroke()

                    // Main route road underlying path
                    ctx.strokeStyle = "rgba(255, 255, 255, 0.15)"
                    ctx.lineWidth = 14
                    ctx.beginPath()
                    ctx.moveTo(25, 200)
                    ctx.quadraticCurveTo(75, 120, 120, 100)
                    ctx.quadraticCurveTo(165, 80, 195, 35)
                    ctx.stroke()

                    // 3. Glowing Active Route
                    ctx.strokeStyle = Qt.rgba(root.primary.r, root.primary.g, root.primary.b, 0.3)
                    ctx.lineWidth = 8
                    ctx.beginPath()
                    ctx.moveTo(25, 200)
                    ctx.quadraticCurveTo(75, 120, 120, 100)
                    ctx.quadraticCurveTo(165, 80, 195, 35)
                    ctx.stroke()

                    // Animated dashed guidance line
                    ctx.strokeStyle = root.primary
                    ctx.lineWidth = 3
                    ctx.setLineDash([7, 5])
                    ctx.lineDashOffset = -root.routeDashOffset
                    ctx.beginPath()
                    ctx.moveTo(25, 200)
                    ctx.quadraticCurveTo(75, 120, 120, 100)
                    ctx.quadraticCurveTo(165, 80, 195, 35)
                    ctx.stroke()
                    ctx.setLineDash([])

                    // 4. Destination Pin
                    ctx.fillStyle = Qt.rgba(root.dangerColor.r, root.dangerColor.g, root.dangerColor.b, 0.3)
                    ctx.beginPath()
                    ctx.arc(195, 35, 8, 0, Math.PI * 2)
                    ctx.fill()
                    ctx.fillStyle = root.dangerColor
                    ctx.beginPath()
                    ctx.arc(195, 35, 4, 0, Math.PI * 2)
                    ctx.fill()

                    // 5. Vehicle Radar Pulse & Position Marker
                    var carX = 98
                    var carY = 110

                    var pingRadius = 4 + root.radarPhase * 20
                    var pingAlpha = 0.8 * (1.0 - root.radarPhase)
                    ctx.strokeStyle = Qt.rgba(root.accent.r, root.accent.g, root.accent.b, pingAlpha)
                    ctx.lineWidth = 1.5
                    ctx.beginPath()
                    ctx.arc(carX, carY, pingRadius, 0, Math.PI * 2)
                    ctx.stroke()

                    // Car chevron indicator
                    ctx.save()
                    ctx.translate(carX, carY)
                    ctx.rotate(-0.65) // Direction angled along the route

                    ctx.fillStyle = root.accent
                    ctx.beginPath()
                    ctx.moveTo(0, -9)
                    ctx.lineTo(6, 6)
                    ctx.lineTo(0, 3)
                    ctx.lineTo(-6, 6)
                    ctx.closePath()
                    ctx.fill()

                    ctx.strokeStyle = "#ffffff"
                    ctx.lineWidth = 1
                    ctx.stroke()
                    ctx.restore()
                }
            }

            // Top Status Bar Inside Map
            Row {
                x: 10
                y: 8
                spacing: 6
                Rectangle {
                    width: 6
                    height: 6
                    radius: 3
                    color: root.accent
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: "GPS NAV"
                    color: root.primary
                    font.pixelSize: 10
                    font.bold: true
                    font.family: "Courier New"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Speed Limit Sign (Standard Circular Badge)
            Rectangle {
                x: 8
                y: 30
                width: 22
                height: 22
                radius: 11
                color: "#ffffff"
                border.color: root.dangerColor
                border.width: 2

                Text {
                    anchors.centerIn: parent
                    text: root.speedLimit.toString()
                    color: "#000000"
                    font.pixelSize: 9
                    font.bold: true
                    font.family: "Courier New"
                }
            }

            // Compass Indicator (Top Right)
            Rectangle {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: 8
                anchors.rightMargin: 8
                height: 18
                width: 66
                radius: 4
                color: Qt.rgba(0, 0, 0, 0.7)
                border.color: root.primaryBorder
                border.width: 1

                Row {
                    anchors.centerIn: parent
                    spacing: 4
                    Text {
                        text: "▲"
                        color: root.accent
                        font.pixelSize: 8
                    }
                    Text {
                        text: root.headingText
                        color: root.primary
                        font.pixelSize: 9
                        font.bold: true
                        font.family: "Courier New"
                    }
                }
            }

            // Location Bar at the Bottom
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 20
                color: Qt.rgba(4, 8, 14, 0.85)
                border.color: Qt.rgba(255, 255, 255, 0.05)
                border.width: 1

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    x: 8
                    spacing: 6

                    Rectangle {
                        width: 5
                        height: 5
                        radius: 2.5
                        color: root.accent
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "GPS 3D Lock • Q. Thanh Xuân"
                        color: Qt.rgba(1, 1, 1, 0.55)
                        font.pixelSize: 8
                        font.family: "Courier New"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }

        // ==========================================
        // 3. Trip Distance / Time / ETA Card
        // ==========================================
        Rectangle {
            width: 218
            height: 72
            radius: 12
            color: Qt.rgba(1, 1, 1, 0.04)
            border.color: root.primaryBorder
            border.width: 1

            Column {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8

                Row {
                    width: parent.width
                    anchors.horizontalCenter: parent.horizontalCenter

                    // Distance
                    Column {
                        width: (parent.width - 2) / 3
                        spacing: 1
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.remainingDistKm.toFixed(1)
                            color: root.primary
                            font.pixelSize: 18
                            font.bold: true
                            font.family: "Courier New"
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "km Còn Lại"
                            color: Qt.rgba(1, 1, 1, 0.35)
                            font.pixelSize: 8
                            font.family: "Courier New"
                        }
                    }

                    Rectangle {
                        width: 1
                        height: 28
                        color: Qt.rgba(1, 1, 1, 0.08)
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // Time
                    Column {
                        width: (parent.width - 2) / 3
                        spacing: 1
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.remainingMinutes.toString()
                            color: "#ffffff"
                            font.pixelSize: 18
                            font.bold: true
                            font.family: "Courier New"
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "phút T.Gian"
                            color: Qt.rgba(1, 1, 1, 0.35)
                            font.pixelSize: 8
                            font.family: "Courier New"
                        }
                    }

                    Rectangle {
                        width: 1
                        height: 28
                        color: Qt.rgba(1, 1, 1, 0.08)
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // ETA
                    Column {
                        width: (parent.width - 2) / 3
                        spacing: 1
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.etaTime
                            color: root.accent
                            font.pixelSize: 18
                            font.bold: true
                            font.family: "Courier New"
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Đến Nơi"
                            color: Qt.rgba(1, 1, 1, 0.35)
                            font.pixelSize: 8
                            font.family: "Courier New"
                        }
                    }
                }

                // Route progress bar
                Rectangle {
                    width: parent.width
                    height: 3
                    radius: 1.5
                    color: Qt.rgba(1, 1, 1, 0.08)

                    Rectangle {
                        width: parent.width * 0.72
                        height: 3
                        radius: 1.5
                        color: root.accent
                    }
                }
            }
        }
    }
}
