#ifndef MYADMOB_H
#define MYADMOB_H

#include <QObject>
#ifdef Q_OS_ANDROID
#include <QtAndroid>
#include <QAndroidJniObject>
#endif

class MyAdmob : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isAdVisible READ isAdVisible NOTIFY isAdVisibleChanged)
public:
    explicit MyAdmob(QObject *parent = 0);
    ~MyAdmob();

    Q_INVOKABLE void showAd();
    Q_INVOKABLE void hideAd();
    Q_INVOKABLE void showInterstitial();

    bool isAdVisible() const { return m_isAdVisible; }

signals:

    void isAdVisibleChanged(bool arg);

public slots:

private:
    //QAndroidJniObject *m_jni;
    bool m_isAdVisible;
};

#endif // MYADMOB_H
