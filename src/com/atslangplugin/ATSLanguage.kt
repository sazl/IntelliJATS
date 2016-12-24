package com.atslangplugin


import com.intellij.lang.Language


/**
 * Created by brandon on 12/16/14.
 */
class ATSLanguage private constructor() : Language("ATS") {
    companion object {
        val INSTANCE: ATSLanguage = ATSLanguage()
    }
}
