#!/usr/bin/env bash
# Réappliquer uniquement les préférences visuelles Thunar A.
set -euo pipefail
xfconf-query -c thunar -p /default-view --create -t string -s 'ThunarDetailsView'
xfconf-query -c thunar -p /last-view --create -t string -s 'ThunarDetailsView'
xfconf-query -c thunar -p /last-details-view-zoom-level --create -t string -s 'THUNAR_ZOOM_LEVEL_38_PERCENT'
xfconf-query -c thunar -p /last-separator-position --create -t int -s '210'
xfconf-query -c thunar -p /last-location-bar --create -t string -s 'ThunarLocationButtons'
xfconf-query -c thunar -p /last-menubar-visible --create -t bool -s 'false'
xfconf-query -c thunar -p /last-details-view-visible-columns --create -t string -s 'THUNAR_COLUMN_NAME,THUNAR_COLUMN_TYPE,THUNAR_COLUMN_SIZE,THUNAR_COLUMN_DATE_MODIFIED'
xfconf-query -c thunar -p /last-details-view-column-order --create -t string -s 'THUNAR_COLUMN_NAME,THUNAR_COLUMN_TYPE,THUNAR_COLUMN_SIZE,THUNAR_COLUMN_DATE_MODIFIED'
xfconf-query -c thunar -p /last-details-view-fixed-columns --create -t bool -s 'true'
xfconf-query -c thunar -p /misc-small-toolbar-icons --create -t bool -s 'true'
xfconf-query -c thunar -p /shortcuts-icon-size --create -t int -s '16'
xfconf-query -c thunar -p /last-toolbar-items --create -t string -s 'back:1,forward:0,menu:1,open-parent:1,open-home:0,new-tab:0,new-window:0,toggle-split-view:0,undo:0,redo:0,zoom-out:0,zoom-in:0,zoom-reset:0,view-as-icons:0,view-as-detailed-list:0,view-as-compact-list:0,view-switcher:0,location-bar:1,reload:0,search:1,uca-action-1786266842031585-1:0'
xfconf-query -c thunar -p /last-details-view-column-widths --create -t string -s '50,50,140,50,50,100,50,50,270,50,50,90,50,130'
xfconf-query -c thunar -p /misc-date-style --create -t string -s 'THUNAR_DATE_STYLE_CUSTOM'
xfconf-query -c thunar -p /misc-date-custom-style --create -t string -s '%d/%m · %H:%M'
xfconf-query -c thunar -p /misc-symbolic-icons-in-sidepane --create -t bool -s 'false'
