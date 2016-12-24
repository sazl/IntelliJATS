package com.atslangplugin

import com.intellij.lexer.FlexAdapter

import java.io.Reader
import kotlin.properties.Delegates

/**
 * Created by Brandon Elam Barker on 12/20/2014.
 */
class ATSLexerAdapter : FlexAdapter(ATSLexer(null as Reader?)) {

    private var myFlex: ATSLexer? = null

    fun getYyline(): Int {
        return myFlex!!.getYyline()
    }

    fun getYycolumn(): Int {
        return myFlex!!.getYycolumn()
    }

    init {
        this.myFlex = this.flex as ATSLexer
    }
}
