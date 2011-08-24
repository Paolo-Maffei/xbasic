#include "terminal.h"

Terminal::Terminal(QWidget *parent) : QDialog(parent)
{
    QVBoxLayout *termLayout = new QVBoxLayout(this);
    termEditor = new Console(parent);
    termEditor->setReadOnly(false);
    //connect(this, SIGNAL(accepted()), this, SLOT(keyPressEvent(QKeyEvent *)));
    termLayout->addWidget(termEditor);
    QDialogButtonBox *buttonBox = new QDialogButtonBox(QDialogButtonBox::Ok);
    connect(buttonBox, SIGNAL(accepted()), this, SLOT(accept()));
    connect(buttonBox, SIGNAL(rejected()), this, SLOT(reject()));
    termLayout->addWidget(buttonBox);
    setLayout(termLayout);
    this->setWindowFlags(Qt::Tool);
    resize(700,500);
}

Console *Terminal::getEditor()
{
    return termEditor;
}

void Terminal::setPosition(int x, int y)
{
    int width = this->width();
    int height = this->height();
    this->setGeometry(x,y,width,height);
}

void Terminal::accept()
{
    done(QDialog::Accepted);
}

void Terminal::reject()
{
    done(QDialog::Rejected);
}

