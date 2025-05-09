#include "mainwindow.h"
#include "ui_mainwindow.h"

#include <QQuickItem>
#include <QListView>
#include <QStandardItemModel>
#include <QStandardItem>

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    // show map
    ui->map->setSource(QUrl(QStringLiteral("qrc:/map.qml")));
    ui->map->show();

    // connect to QML
    auto obj = ui->map->rootObject();
    connect(this, SIGNAL(addMarker(QVariant,QVariant)), obj,
            SLOT(addMarker(QVariant,QVariant)));

    // to add a marker emit this signal enywhere in C++ code
    emit addMarker(40.71, -74.01);
    emit addMarker(40.72, -74.01);
    emit addMarker(40.72, -74.01);
    emit addMarker(40.73, -74.01);
}

MainWindow::~MainWindow()
{
    delete ui;
}
