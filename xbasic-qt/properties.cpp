#include "properties.h"

Properties::Properties(QWidget *parent) : QDialog(parent)
{
    QVBoxLayout *layout = new QVBoxLayout(this);
    QGroupBox *gbCompiler = new QGroupBox(tr("Compiler"), this);
    QGroupBox *gbIncludes = new QGroupBox(tr("Include Path"), this);

    QPushButton *btnCompilerBrowse = new QPushButton(tr("Browse"), this);
    leditCompiler = new QLineEdit(this);
    QHBoxLayout *clayout = new QHBoxLayout(this);
    clayout->addWidget(leditCompiler);
    clayout->addWidget(btnCompilerBrowse);

    QPushButton *btnIncludesBrowse = new QPushButton(tr("Browse"), this);
    leditIncludes = new QLineEdit(this);
    QHBoxLayout *ilayout = new QHBoxLayout(this);
    ilayout->addWidget(leditIncludes);
    ilayout->addWidget(btnIncludesBrowse);

    QDialogButtonBox *buttonBox = new QDialogButtonBox(QDialogButtonBox::Ok | QDialogButtonBox::Cancel);

    connect(btnCompilerBrowse, SIGNAL(clicked()), this, SLOT(browseCompiler()));
    connect(btnIncludesBrowse, SIGNAL(clicked()), this, SLOT(browseIncludes()));
    connect(buttonBox, SIGNAL(accepted()), this, SLOT(accept()));
    connect(buttonBox, SIGNAL(rejected()), this, SLOT(reject()));

    gbCompiler->setLayout(clayout);
    gbIncludes->setLayout(ilayout);

    layout->addWidget(gbCompiler);
    layout->addWidget(gbIncludes);
    layout->addWidget(buttonBox);

    setLayout(layout);

    QSettings settings(publisherKey, xBasicGuiKey,this);
    QVariant compv = settings.value(compilerKey);
    QVariant incv = settings.value(includesKey);

    if(compv.canConvert(QVariant::String)) {
        QString s = compv.toString();
        s = QDir::fromNativeSeparators(s);
        leditCompiler->setText(s);
    }

    if(incv.canConvert(QVariant::String)) {
        QString s = incv.toString();
        s = QDir::fromNativeSeparators(s);
        leditIncludes->setText(s);
    }

    //parent->setWindowTitle(tr("xBasic IDE Compiler Properties"));
    resize(400,260);
}


void Properties::browseCompiler()
{
    QString fileName = QFileDialog::getOpenFileName(this,
            tr("Select xBasic Compiler"), "", "xBasic Compiler (xbcom-qt*)");
    QString s = QDir::fromNativeSeparators(fileName);
    compilerstr = leditCompiler->text();
    if(s.length() > 0)
        leditCompiler->setText(s);
    qDebug() << "browseCompiler" << s;
}

void Properties::browseIncludes()
{
    QString pathName = QFileDialog::getExistingDirectory(this,
            tr("Select xBasic Include Path"), "xBasic Includes (*))");
    QString s = QDir::fromNativeSeparators(pathName);
    if(s.length() == 0)
        return;
    if(s.indexOf('/') > -1) {
        if(s.mid(s.length()-1) != "/")
            s += "/";
    }
    else if(s.indexOf("\\") > -1) {
        if(s.mid(s.length()-1) != "\\")
            s += "\\";
    }
    leditIncludes->setText(s);
    qDebug() << "browseIncludes" << s;
}

void Properties::accept()
{
    QSettings settings(publisherKey, xBasicGuiKey,this);
    settings.setValue(compilerKey,leditCompiler->text());
    settings.setValue(includesKey,leditIncludes->text());
    settings.setValue(configFileKey,leditIncludes->text()+tr("xbasic.cfg"));
    done(QDialog::Accepted);
}

void Properties::reject()
{
    leditCompiler->setText(compilerstr);
    leditIncludes->setText(includesstr);
    done(QDialog::Rejected);
}

void Properties::showProperties()
{
    compilerstr = leditCompiler->text();
    includesstr = leditIncludes->text();
    this->setWindowTitle("xBasic IDE Compiler Properties");
    this->show();
}
