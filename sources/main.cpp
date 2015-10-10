#include <QApplication>
#include <QQmlApplicationEngine>
#include <QTranslator>
#include <QDir>
#include <QtQml>

#include "myadmob.h"
#include "mydevice.h"
#include "qmlobjectstore.h"

#include <QDebug>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    //---------
    QTranslator qtTranslator;
    qtTranslator.load("qtangled_" + QLocale::system().name(), ":/");
    app.installTranslator(&qtTranslator);
    //---------

    qmlRegisterType<MyAdmob>("myadmob", 1, 0, "MyAdmob");
    qmlRegisterType<MyDevice>("mydevice", 1, 0, "MyDevice");
    qmlRegisterType<QMLObjectStore>("QMLObjectStore", 1, 0, "QMLObjectStore");

    QQmlApplicationEngine engine;

#ifdef Q_OS_ANDROID
    QString hash = QString("QTangled");
    QString dirStorageString = QString("/sdcard/Android/data/com.qtproject.qtangled/");
    QDir dir;
    if( dir.mkpath(dirStorageString) )
    {
        engine.setOfflineStoragePath( dirStorageString );
        engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));

        QString dbFileString = dirStorageString + hash + QString(".sqlite");
        QFile dbFile(dbFileString);
        if (dbFile.exists()) {
            QFile::setPermissions(dbFileString, QFile::WriteOwner | QFile::ReadOwner);
        }

        QFile iniFile( dir.path() + hash + QString(".ini") );
        iniFile.open( QIODevice::WriteOnly );
        iniFile.write( "[General]\nDescription=Catalog\nDriver=QSQLITE\nName=Catalog\nVersion=1.0" );
        iniFile.close();
    }
    else
    {
#endif
        engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));
#ifdef Q_OS_ANDROID
    }
#endif


    return app.exec();
}
