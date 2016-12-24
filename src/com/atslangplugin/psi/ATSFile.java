package com.atslangplugin.psi;

import com.atslangplugin.ATSFileTypeDynamic;
import com.atslangplugin.ATSFileTypeInclude;
import com.atslangplugin.ATSFileTypeStatic;
import com.atslangplugin.ATSLanguage;
import com.intellij.extapi.psi.PsiFileBase;
import com.intellij.openapi.fileTypes.FileType;
import com.intellij.openapi.fileTypes.LanguageFileType;
import com.intellij.openapi.vfs.InvalidVirtualFileAccessException;
import com.intellij.psi.FileViewProvider;
import org.jetbrains.annotations.NotNull;

import javax.swing.*;
import javax.swing.text.StringContent;

/**
 * Created by Brandon Elam Barker on 12/20/2014.
 */

public class ATSFile extends PsiFileBase {

    public ATSFile(@NotNull FileViewProvider viewProvider) {
        super(viewProvider, ATSLanguage.Companion.getINSTANCE());

        String extension = "";
        int i = this.getName().lastIndexOf('.');
        if (i > 0) {
            extension = this.getName().substring(i + 1);
        }
        if (extension.equals("dats")) {
            myFileTypeInstance = ATSFileTypeDynamic.Companion.getINSTANCE();
        } else if (extension.equals("sats")) {
            myFileTypeInstance = ATSFileTypeStatic.Companion.getINSTANCE();
        } else if (extension.equals("hats")) {
            myFileTypeInstance = ATSFileTypeInclude.Companion.getINSTANCE();
        } else {
            // This is probably not exactly what we need:
            throw new InvalidVirtualFileAccessException(this.getName());
        }
    }

    private LanguageFileType myFileTypeInstance;

    @NotNull
    @Override
    public FileType getFileType() {
        return myFileTypeInstance;
    }

    @Override
    public String toString() {
        return myFileTypeInstance.getName();
    }

    @Override
    public Icon getIcon(int flags) {
        return super.getIcon(flags);
    }





}
