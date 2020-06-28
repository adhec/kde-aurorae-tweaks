/********************************************************************
Copyright (C) 2012 Martin Gräßlin <mgraesslin@kde.org>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*********************************************************************/
import QtQuick 2.0
import org.kde.kquickcontrolsaddons 2.0 as KQuickControlsAddons
import org.kde.kwin.decoration 0.1

DecorationButton {
    property bool closeOnDoubleClick: decorationSettings.closeOnDoubleClickOnMenu
    id: menuButton
    buttonType: DecorationOptions.DecorationButtonMenu
    KQuickControlsAddons.QIconItem {
        icon: decoration.client.icon
        anchors.fill: parent
    }
    DecorationOptions {
        id: options
        deco: decoration
    }
    Timer {
        id: timer
        interval: options.mousePressAndHoldInterval
        repeat: false
        onTriggered: decoration.requestShowWindowMenu()
    }
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onPressed: {
            parent.pressed = true;
            // we need a timer to figure out whether there is a double click in progress or not
            // if we have a "normal" click we want to open the context menu. This would eat our
            // second click of the double click. To properly get the double click we have to wait
            // the double click delay to ensure that it was only a single click.
            if (timer.running) {
                timer.stop();
            } else if (menuButton.closeOnDoubleClick) {
                timer.start();
            }
        }
        onReleased: {
            parent.pressed = false;
            timer.stop();
        }
        onExited: {
            if (!parent.pressed) {
                return;
            }
            if (timer.running) {
                timer.stop();
            }
            parent.pressed = false;
        }
        onClicked: {
            // for right clicks we show the menu instantly
            // and if the option is disabled we always show menu directly
            if (!menuButton.closeOnDoubleClick || mouse.button == Qt.RightButton) {
                decoration.requestShowWindowMenu();
                timer.stop();
            }
        }
        onDoubleClicked: {
            if (menuButton.closeOnDoubleClick) {
                decoration.requestClose();
            }
        }
    }
}
