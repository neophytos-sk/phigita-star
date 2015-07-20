/*
 * =====================================================================================
 *
 *       Filename:  webkit-inspector.cpp
 *
 *    Description:  
 *
 *        Version:  1.0
 *        Created:  02/12/2014 09:28:23 AM
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  Neophytos Demetriou (), 
 *   Organization:  
 *
 * =====================================================================================
 */

#include <QtGui/QApplication>
#include <QtWebKit/QWebInspector>
#include <QtWebKit/QGraphicsWebView>
 
#include "html5applicationviewer.h"
 
int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
 
    Html5ApplicationViewer viewer;
    viewer.setOrientation(Html5ApplicationViewer::ScreenOrientationAuto);
    viewer.showExpanded();
 
    viewer.webView()->page()->settings()->setAttribute(QWebSettings::DeveloperExtrasEnabled, true);
 
    QWebInspector inspector;
    inspector.setPage(viewer.webView()->page());
    inspector.setVisible(true);
 
    viewer.loadFile(QLatin1String("html/index.html"));
 
 
    return app.exec();
} 
