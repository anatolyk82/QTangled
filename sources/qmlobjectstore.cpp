#include "qmlobjectstore.h"
#include <QDebug>

QMLObjectStore::QMLObjectStore(QObject *parent) : QObject(parent)
{
}

void QMLObjectStore::setQMLObject(QString key, QObject *object)
{
    if( m_qmlstore.value( key, NULL) == NULL )
    {
        m_qmlstore[ key ] = object;
        m_qmllist.append( object );
    }
    else
    {
        QObject *old_object = m_qmlstore[ key ];
        m_qmlstore[ key ] = object;
        int indx = m_qmllist.indexOf( old_object );
        m_qmllist.replace( indx, object );
    }
    //qDebug() << Q_FUNC_INFO << m_qmlstore.keys();
}

QObject *QMLObjectStore::getQMLObject(QString key)
{
    //qDebug() << Q_FUNC_INFO << index << ": " << m_qmlstore[ index ];
    return m_qmlstore[ key ];
}

QObject *QMLObjectStore::getQMLObjectIndx(int index)
{
    return m_qmllist.at( index );
}

QString QMLObjectStore::getKeyByIndex(int index)
{
    QObject *object = m_qmllist.at( index );
    QString key = m_qmlstore.key( object, NULL );
    return key;
}

int QMLObjectStore::length() const
{
    return m_qmllist.length();
}

void QMLObjectStore::clear()
{
    m_qmlstore.clear();
    m_qmllist.clear();
}
