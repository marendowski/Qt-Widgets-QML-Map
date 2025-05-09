import QtQuick
import QtLocation
import QtPositioning

Rectangle {
    id: window
    visible: true
    property Component comMarker: marker

    Plugin {
        id: mapPlugin
        name: "osm"
    }

    Map {
        id: map
        anchors.fill: parent
        plugin: mapPlugin
        center: QtPositioning.coordinate(40.71, -74.01)
        zoomLevel: 14
        // Component.onCompleted:addMarker(40.71, -74.01)

        MapItemView {
            model: routeModel
            delegate: MapRoute {
                route: routeData
                line.color: "blue"
                line.width: 5
                smooth: true
            }
        }

        WheelHandler {
            id: wheel
            // workaround for QTBUG-87646 / QTBUG-112394 / QTBUG-112432:
            // Magic Mouse pretends to be a trackpad but doesn't work with PinchHandler
            // and we don't yet distinguish mice and trackpads on Wayland either
            acceptedDevices: Qt.platform.pluginName === "cocoa" || Qt.platform.pluginName === "wayland"
                             ? PointerDevice.Mouse | PointerDevice.TouchPad
                             : PointerDevice.Mouse
            rotationScale: 1/120
            property: "zoomLevel"
        }
        DragHandler {
            id: drag
            target: null
            onTranslationChanged: (delta) => map.pan(-delta.x, -delta.y)
        }
        Shortcut {
            enabled: map.zoomLevel < map.maximumZoomLevel
            sequence: StandardKey.ZoomIn
            onActivated: map.zoomLevel = Math.round(map.zoomLevel + 1)
        }
        Shortcut {
            enabled: map.zoomLevel > map.minimumZoomLevel
            sequence: StandardKey.ZoomOut
            onActivated: map.zoomLevel = Math.round(map.zoomLevel - 1)
        }
    }

    // wrap marker in a Component
    Component {
        id: marker
        MapQuickItem{
            id: markerImg
            width: 20
            height: 20
            anchorPoint.x: width / 2
            anchorPoint.y: height
            // coordinate: QtPositioning.coordinate(0, 0)

            sourceItem: Image{
                id: icon
                source: "marker.png"
                fillMode: Image.PreserveAspectCrop
                sourceSize.width: 40
                sourceSize.height: 40
            }

            Component.onCompleted: {
                console.log("Marker created at:", coordinate.latitude,
                            coordinate.longitude);
            }
        }
    }

    // Adds a marker on given position
    function addMarker(latitude, longitude)
    {
        var newMarker = comMarker.createObject(window, {
            coordinate: QtPositioning.coordinate(latitude, longitude)
        })
        map.addMapItem(newMarker)
    }

    // Adds a route waypoint
    function addRouteWaypoint(latitude, longitude)
    {
        routeModel.query.addWaypoint(QtPositioning.coordinate(latitude, longitude));
        routeModel.update();
    }

    RouteModel {
        id: routeModel
        plugin: mapPlugin
        query: RouteQuery {}

        Component.onCompleted: {
            // calling QML function inside QML
            addRouteWaypoint(40.71, -74.01);
            addRouteWaypoint(40.72, -74.01);
            addRouteWaypoint(40.73, -74.01);
        }

        onStatusChanged: console.debug("current route model status", status, count, errorString)
    }
}
