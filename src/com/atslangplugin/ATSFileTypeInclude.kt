package com.atslangplugin

import com.intellij.openapi.fileTypes.LanguageFileType

import javax.swing.*

/**
 * Created by brandon on 12/16/14.
 */
class ATSFileTypeInclude private constructor() : LanguageFileType(ATSLanguage.INSTANCE) {

    override fun getName(): String {
        return "hats file"
    }

    override fun getDescription(): String {
        return "Included (\"header\") Applied Type System (ATS) language file"
    }

    override fun getDefaultExtension(): String {
        return "hats"
    }

    override fun getIcon(): Icon? {
        return ATSIcons.FILE
    }

    companion object {
        val INSTANCE: ATSFileTypeInclude = ATSFileTypeInclude()
    }
}
