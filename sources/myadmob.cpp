#include "myadmob.h"

#include <QDebug>

MyAdmob::MyAdmob(QObject *parent) : QObject(parent)
{
    //m_jni = new QAndroidJniObject("org/qtproject/example/admobqt/AdMobQtActivity");
}

MyAdmob::~MyAdmob()
{
}

void MyAdmob::showAd()
{
#ifdef Q_OS_ANDROID
    QAndroidJniObject jni = QtAndroid::androidActivity();
    jni.callMethod<void>("showAd");
    m_isAdVisible = true;
    emit isAdVisibleChanged(m_isAdVisible);
    //m_jni->callMethod<void>("showAd");
#endif
}

void MyAdmob::hideAd()
{
#ifdef Q_OS_ANDROID
    QAndroidJniObject jni = QtAndroid::androidActivity();
    jni.callMethod<void>("hideAd");
    m_isAdVisible = false;
    emit isAdVisibleChanged(m_isAdVisible);
    //m_jni->callMethod<void>("hideAd");
#endif
}

void MyAdmob::showInterstitial()
{
#ifdef Q_OS_ANDROID
    QAndroidJniObject jni = QtAndroid::androidActivity();
    jni.callMethod<void>("displayInterstitial");
#endif
}

