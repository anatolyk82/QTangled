#ifndef QMLOBJECTSTORE_H
#define QMLOBJECTSTORE_H

#include <QObject>
#include <QList>
#include <QMap>

class QMLObjectStore : public QObject
{
    Q_OBJECT

public:
    explicit QMLObjectStore(QObject *parent = 0);

    Q_INVOKABLE void setQMLObject( QString key, QObject* object );
    Q_INVOKABLE QObject* getQMLObject( QString key );
    Q_INVOKABLE QObject* getQMLObjectIndx( int index );
    Q_INVOKABLE QString getKeyByIndex( int index );

    Q_INVOKABLE int length() const;

    Q_INVOKABLE void clear();

private:

    QMap<QString, QObject*> m_qmlstore;
    QList<QObject*> m_qmllist;

};

#endif // QMLOBJECTSTORE_H
