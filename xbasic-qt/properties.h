#ifndef PROPERTIES_H
#define PROPERTIES_H

#define publisherKey        "MicroCSource"
#define publisherComKey     "MicroCSource.com"
#define xBasicGuiKey        "xBasic QtGUI"
#define compilerKey         "Compiler"
#define includesKey         "Includes"
#define separatorKey        "PathSeparator"
#define configFileKey       "ConfigFile"
#define lastFileNameKey     "LastFileName"
#define lastBoardNameKey    "LastBoardName"
#define lastPortNameKey     "LastPortName"
#define lastTermXposKey     "LastTermXposition"
#define lastTermYposKey     "LastTermYposition"
#define lastDirectoryKey    "LastDirectory"

#include <QtGui>

class Properties : public QDialog
{
    Q_OBJECT
public:
    explicit Properties(QWidget *parent = 0);

signals:

public slots:
    void browseCompiler();
    void browseIncludes();
    void accept();
    void reject();
    void showProperties();

private:
    QLineEdit   *leditCompiler;
    QLineEdit   *leditIncludes;
    QString     compilerstr;
    QString     includesstr;
};

#endif // PROPERTIES_H
