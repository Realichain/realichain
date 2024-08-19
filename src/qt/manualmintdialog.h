#ifndef REALI_QT_MANUALMINTDIALOG_H
#define REALI_QT_MANUALMINTDIALOG_H

#include <QDialog>

#include "platformstyle.h"

namespace Ui {
    class ManualMintDialog;
}

class ManualMintDialog : public QDialog
{
    Q_OBJECT

public:
    explicit ManualMintDialog(const PlatformStyle *platformStyle, QWidget *parent = 0);
    ~ManualMintDialog();

private:
    Ui::ManualMintDialog *ui;
    const PlatformStyle *platformStyle;
};

#endif // REALI_QT_MANUALMINTDIALOG_H
