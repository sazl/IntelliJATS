package com.atslangplugin;

import com.intellij.lexer.FlexLexer;
import com.intellij.psi.tree.IElementType;
import com.atslangplugin.ATSTokenTypes;
import com.intellij.psi.TokenType;

%%

%class ATSLexer
%public
%implements FlexLexer
%unicode
%function advance
%type IElementType
%line
%column
%eof{ return;
%eof}

%{
  // Not sure if needed:
  StringBuffer string = new StringBuffer();

  // Placeholders for line and column information:
  private int yyline;
  private int yycolumn;

  public int getYyline() { return yyline; }
  public int getYycolumn() { return yycolumn; }

%}



// Old patterns:
IDENTIFIER= ([:letter:]|_) ([:letter:]|{DIGIT}|_ )*

ESCAPE_SEQUENCE=\\[^\r\n]
CRLF=(\n | \r | \r\n)

DIGIT=[0-9]
OCTAL_DIGIT=[0-7]
HEX_DIGIT=[0-9A-Fa-f]

EXTCODE = "%{"|"%{#"|"%{^"|"%{$"|"%}"

INTEGER_LITERAL={DECIMAL_INTEGER_LITERAL}|{OCTAL_INTEGER_LITERAL}|{HEX_INTEGER_LITERAL}
DECIMAL_INTEGER_LITERAL=(0|([1-9]({DIGIT})*))
HEX_INTEGER_LITERAL=0[Xx]({HEX_DIGIT})*
OCTAL_INTEGER_LITERAL=0({OCTAL_DIGIT})*

// for DEFINE:
SIMPLE_SPACE_CHAR=[\ \t\f]
SIMPLE_PRE_KEYWORD=(include|ifdef|endif|undef|ifndef|error|defined)

WHITE_SPACE=[\ \n\r\t\f]

/* comments */
END_OF_LINE_COMMENT="/""/"([^\r\n]|(\\\r?\n))*
COMMENT_TAIL=([^"*"]*("*"+[^"*"")"])?)*("*"+")")?
TRADITIONAL_COMMENT=("(*"[^"*"]{COMMENT_TAIL})|"*)"
END_OF_FILE_COMMENT = "////" (.* {CRLF}?)* // CHECK_ME
DOCUMENTATION_COMMENT="(*""*"+("("|([^"(""*"]{COMMENT_TAIL}))?
//DOCUMENTATION_COMMENT = "(*" (\*+\ +{CRLF}?)* {COMMENT_CONTENT} (\*+\ +{CRLF}?)* "*)"
//COMMENT_CONTENT = ( [^*] | \*+ [^)*] ) // should we delimit the ')' ?
COMMENT = {TRADITIONAL_COMMENT} | {END_OF_LINE_COMMENT} | {END_OF_FILE_COMMENT} | {DOCUMENTATION_COMMENT}

FLOAT_LITERAL=({FLOATING_POINT_LITERAL1})|({FLOATING_POINT_LITERAL2})|({FLOATING_POINT_LITERAL3})|({FLOATING_POINT_LITERAL4})
FLOATING_POINT_LITERAL1=({DIGIT})+"."({DIGIT})*({EXPONENT_PART})?
FLOATING_POINT_LITERAL2="."({DIGIT})+({EXPONENT_PART})?
FLOATING_POINT_LITERAL3=({DIGIT})+({EXPONENT_PART})
FLOATING_POINT_LITERAL4=({DIGIT})+
EXPONENT_PART=[Ee]["+""-"]?({DIGIT})*

CHAR_SINGLEQ_BASE=[^\\\'\r\n]|{ESCAPE_SEQUENCE}
CHAR_DOUBLEQ_BASE=[^\\\"\r\n]|{ESCAPE_SEQUENCE}
QUOTED_LITERAL="'"({CHAR_SINGLEQ_BASE})*("'"|\\)?
DOUBLE_QUOTED_LITERAL=\"({CHAR_DOUBLEQ_BASE})*(\"|\\)?
CHAR_LITERAL="'"({CHAR_SINGLEQ_BASE})("'"|\\)? | \"({CHAR_DOUBLEQ_BASE})*(\"|\\)?

%state STRING
%state PRE
%state PRAGMA
%state DEFINE
%state DEFINE_CONTINUATION
%state CONTINUATION

%%

/* for more information, see the following */
/* in the ATS-Postiats source repository:  */
/* src/pats_lexing.sats                    */
/* src/pats_lexing_token.dats              */

/*  *** *** keywords and symbols  *** ***  */

<YYINITIAL> {
"'("                        { return ATSTokenTypes.Companion.getQUOTELPAREN(); }
"["                         { return ATSTokenTypes.Companion.getLBRACKET(); }
"{"                         { return ATSTokenTypes.Companion.getLBRACE(); }
"'["                        { return ATSTokenTypes.Companion.getQUOTELBRACKET(); }
"'{"                        { return ATSTokenTypes.Companion.getQUOTELBRACE(); }
//
"@"                         { return ATSTokenTypes.Companion.getAT(); }
//
"\\"                        { return ATSTokenTypes.Companion.getBACKSLASH(); }
"!"                         { return ATSTokenTypes.Companion.getBANG(); }
"|"                         { return ATSTokenTypes.Companion.getBAR(); }
"`"                         { return ATSTokenTypes.Companion.getBQUOTE(); }
//
":"                         { return ATSTokenTypes.Companion.getCOLON(); }
":<"                        { return ATSTokenTypes.Companion.getCOLONLT(); }
/*
  | T_COLONLTGT of () // :<> // HX: impossible
*/
//
"$"                         { return ATSTokenTypes.Companion.getDOLLAR(); }
//
"."                         { return ATSTokenTypes.Companion.getDOT(); }
".."                        { return ATSTokenTypes.Companion.getDOTDOT(); }
"..."                       { return ATSTokenTypes.Companion.getDOTDOTDOT(); }
//
"."({DIGIT}+)               { return ATSTokenTypes.Companion.getDOTINT(); }
//
"="                         { return ATSTokenTypes.Companion.getEQ(); }
"=>"                        { return ATSTokenTypes.Companion.getEQGT(); }
"=<"                        { return ATSTokenTypes.Companion.getEQLT(); }
"=<>"                       { return ATSTokenTypes.Companion.getEQLTGT(); }
"=/=>"                      { return ATSTokenTypes.Companion.getEQSLASHEQGT(); }
"=>>"                       { return ATSTokenTypes.Companion.getEQGTGT(); }
"=/=>>"                     { return ATSTokenTypes.Companion.getEQSLASHEQGTGT(); }
//
"#"                         { return ATSTokenTypes.Companion.getHASH(); }
//
"<"                         { return ATSTokenTypes.Companion.getLT(); } // for opening a tmparg
">"                         { return ATSTokenTypes.Companion.getGT(); } // for closing a tmparg
//
"<>"                        { return ATSTokenTypes.Companion.getGTLT(); }
".<"                        { return ATSTokenTypes.Companion.getDOTLT(); } // opening termetric
">."                        { return ATSTokenTypes.Companion.getGTDOT(); } // closing termetric
".<>."                      { return ATSTokenTypes.Companion.getDOTLTGTDOT(); } // empty termetric
//
"->"                        { return ATSTokenTypes.Companion.getMINUSGT(); }
"-<"                        { return ATSTokenTypes.Companion.getMINUSLT(); }
"-<>"                       { return ATSTokenTypes.Companion.getMINUSLTGT(); }
//
"~"                         { return ATSTokenTypes.Companion.getTILDE(); }
//
"abstype"|"abst0ype"|"absprop"|"absview"| "absviewtype"|
"absvtype"|"absviewt@ype"|"absvt0ype"|"absviewt0ype"
                            { return ATSTokenTypes.Companion.getABSTYPE(); }
//
"and"                       { return ATSTokenTypes.Companion.getAND(); }
"as"                        { return ATSTokenTypes.Companion.getAS(); }
"assume"                    { return ATSTokenTypes.Companion.getASSUME(); }
"begin"                     { return ATSTokenTypes.Companion.getBEGIN(); }
"case"|"case-"|"case+"|"prcase"
                            { return ATSTokenTypes.Companion.getCASE(); }
"classdec"                  { return ATSTokenTypes.Companion.getCLASSDEC(); } // CHECK_ME
"datasort"                  { return ATSTokenTypes.Companion.getDATASORT(); }
// BB: surprising to me these all generate the same token:
// (but maybe not exactly, see ./src/pats_lexing_token.dats)
"datatype"|"dataprop"|"dataview"|"dataviewtype"|"datavtype"
                            { return ATSTokenTypes.Companion.getDATATYPE(); }
"do"                        { return ATSTokenTypes.Companion.getDO(); }
"dynload"                   { return ATSTokenTypes.Companion.getDYNLOAD(); }
"else"                      { return ATSTokenTypes.Companion.getELSE(); }
"end"                       { return ATSTokenTypes.Companion.getEND(); }
"exception"                 { return ATSTokenTypes.Companion.getEXCEPTION(); }
//
"extern"                    { return ATSTokenTypes.Companion.getEXTERN(); }
"extype"                    { return ATSTokenTypes.Companion.getEXTYPE(); }
"extvar"                    { return ATSTokenTypes.Companion.getEXTVAR(); }
//
"fix"|"fix@"                { return ATSTokenTypes.Companion.getFIX(); }
"infix"|"infixl"|"infixr"|"prefix"|"postfix"
                            { return ATSTokenTypes.Companion.getFIXITY(); }
"for*"                      { return ATSTokenTypes.Companion.getFORSTAR(); }
"fn"|"fnx"|"fun"|"prfn"|"prfun"|"praxi"|"castfn"
                            { return ATSTokenTypes.Companion.getFUN(); }
"if"                        { return ATSTokenTypes.Companion.getIF(); } // dynamic
"implement"|"primplement"   { return ATSTokenTypes.Companion.getIMPLEMENT(); }
"import"                    { return ATSTokenTypes.Companion.getIMPORT(); }
"in"                        { return ATSTokenTypes.Companion.getIN(); }
"lam"|"llam"|"lam@"         { return ATSTokenTypes.Companion.getLAM(); }
"let"                       { return ATSTokenTypes.Companion.getLET(); }
"local"                     { return ATSTokenTypes.Companion.getLOCAL(); }
"macdef"|"macrodef"         { return ATSTokenTypes.Companion.getMACDEF(); }
"nonfix"                    { return ATSTokenTypes.Companion.getNONFIX(); }
"overload"                  { return ATSTokenTypes.Companion.getOVERLOAD(); }
"of"                        { return ATSTokenTypes.Companion.getOF(); }
"op"                        { return ATSTokenTypes.Companion.getOP(); }
"rec"                       { return ATSTokenTypes.Companion.getREC(); }
"ref@"                      { return ATSTokenTypes.Companion.getREFAT(); }
"require"                   { return ATSTokenTypes.Companion.getREQUIRE(); }
"scase"                     { return ATSTokenTypes.Companion.getSCASE(); }
"sif"                       { return ATSTokenTypes.Companion.getSIF(); } // static
"sortdef"                   { return ATSTokenTypes.Companion.getSORTDEF(); }
"stacst"                    { return ATSTokenTypes.Companion.getSTACST(); }
"stadef"                    { return ATSTokenTypes.Companion.getSTADEF(); }
"staload"                   { return ATSTokenTypes.Companion.getSTALOAD(); }
"static"                    { return ATSTokenTypes.Companion.getSTATIC(); }
/*
  | T_STAVAR of () // stavar // HX: a suspended hack
*/
"symelim"                   { return ATSTokenTypes.Companion.getSYMELIM(); }
"symintr"                   { return ATSTokenTypes.Companion.getSYMINTR(); }
"then"                      { return ATSTokenTypes.Companion.getTHEN(); }
"tkindef"                   { return ATSTokenTypes.Companion.getTKINDEF(); }
"try"                       { return ATSTokenTypes.Companion.getTRY(); }
"type"|"type+"|"type-"      { return ATSTokenTypes.Companion.getTYPE(); }
"typedef"|"propdef"|"viewdef"|"viewtypedef" // CHECK_ME: aliases?
                            { return ATSTokenTypes.Companion.getTYPEDEF(); }
"val"|"val+"|"val-"|"prval" { return ATSTokenTypes.Companion.getVAL(); }
"var"|"prvar"               { return ATSTokenTypes.Companion.getVAR(); }
"when"                      { return ATSTokenTypes.Companion.getWHEN(); }
"where"                     { return ATSTokenTypes.Companion.getWHERE(); }
"while"                     { return ATSTokenTypes.Companion.getWHILE(); }
"while*"                    { return ATSTokenTypes.Companion.getWHILESTAR(); }
"with"                      { return ATSTokenTypes.Companion.getWITH(); }
"withtype"|"withprop"|"withview"|"withviewtype"
                            { return ATSTokenTypes.Companion.getWITHTYPE(); }
//
"addr@"                     { return ATSTokenTypes.Companion.getADDRAT(); }
"fold@"                     { return ATSTokenTypes.Companion.getFOLDAT(); }
"free@"                     { return ATSTokenTypes.Companion.getFREEAT(); }
"view@"                     { return ATSTokenTypes.Companion.getVIEWAT(); }
//
"$arrpsz"|"$arrptrsize"     { return ATSTokenTypes.Companion.getDLRARRPSZ(); }
//
"$delay"|"$ldelay"          { return ATSTokenTypes.Companion.getDLRDELAY(); }
//
"$effmask"                  { return ATSTokenTypes.Companion.getDLREFFMASK(); }
"ntm"|"exn"|"ref"|"wrt"|"all"
                            { return ATSTokenTypes.Companion.getDLREFFMASK_ARG(); }
"$extern"                   { return ATSTokenTypes.Companion.getDLREXTERN(); }
"$extkind"                  { return ATSTokenTypes.Companion.getDLREXTKIND(); }
"$extype"                   { return ATSTokenTypes.Companion.getDLREXTYPE(); }
"$extype_struct"            { return ATSTokenTypes.Companion.getDLREXTYPE_STRUCT(); }
//
"$extval"                   { return ATSTokenTypes.Companion.getDLREXTVAL(); }
"$extfcall"                 { return ATSTokenTypes.Companion.getDLREXTFCALL(); }
"$extmcall"                 { return ATSTokenTypes.Companion.getDLREXTMCALL(); }
//
"$break"                    { return ATSTokenTypes.Companion.getDLRBREAK(); }
"$continue"                 { return ATSTokenTypes.Companion.getDLRCONTINUE(); }
"$raise"                    { return ATSTokenTypes.Companion.getDLRRAISE(); }
//
"$lst"|"$list"|"$lst_t"|"$list_t"|"$lst_vt"|"$list_vt"
                            { return ATSTokenTypes.Companion.getDLRLST(); }
"$rec"|"$record"|"$rec_t"|"$record_t"|"$rec_vt"|"$record_vt"
                            { return ATSTokenTypes.Companion.getDLRREC(); }
"$tup"|"$tup_t"|"$tup_vt"|"$tuple"|"$tuple_t"|"$tuple_vt"
                            { return ATSTokenTypes.Companion.getDLRTUP(); }
//
"$myfilename"               { return ATSTokenTypes.Companion.getDLRMYFILENAME(); }
"$mylocation"               { return ATSTokenTypes.Companion.getDLRMYLOCATION(); }
"$myfunction"               { return ATSTokenTypes.Companion.getDLRMYFUNCTION(); }
//
"$showtype"                 { return ATSTokenTypes.Companion.getDLRSHOWTYPE(); }
//
"$vcopyenv_v"|"$vcopyenv_vt(vt)"
                            { return ATSTokenTypes.Companion.getDLRVCOPYENV(); }
"$tempenver"                { return ATSTokenTypes.Companion.getDLRTEMPENVER(); }
//
"#assert"                   { return ATSTokenTypes.Companion.getSRPASSERT(); }
"#define"                   { return ATSTokenTypes.Companion.getSRPDEFINE(); }
"#elif"                     { return ATSTokenTypes.Companion.getSRPELIF(); }
"#elifdef"                  { return ATSTokenTypes.Companion.getSRPELIFDEF(); }
"#elifndef"                 { return ATSTokenTypes.Companion.getSRPELIFNDEF(); }
"#else"                     { return ATSTokenTypes.Companion.getSRPELSE(); }
"#endif"                    { return ATSTokenTypes.Companion.getSRPENDIF(); }
"#error"                    { return ATSTokenTypes.Companion.getSRPERROR(); }
"#if"                       { return ATSTokenTypes.Companion.getSRPIF(); }
"#ifdef"                    { return ATSTokenTypes.Companion.getSRPIFDEF(); }
"#ifndef"                   { return ATSTokenTypes.Companion.getSRPIFNDEF(); }
"#include"                  { return ATSTokenTypes.Companion.getSRPINCLUDE(); }
"#print"                    { return ATSTokenTypes.Companion.getSRPPRINT(); }
"#then"                     { return ATSTokenTypes.Companion.getSRPTHEN(); }
"#undef"                    { return ATSTokenTypes.Companion.getSRPUNDEF(); }
//
// The internal lexing of views + types seems to be a bit complicated
// For now I try to simplify it a bit; currently not handled: (FIX_ME)
// T_IDENT_alp
//
{INTEGER_LITERAL}           { return ATSTokenTypes.Companion.getINT(); }  // CHECK_ME
{CHAR_LITERAL}              { return ATSTokenTypes.Companion.getCHAR(); }  // CHECK_ME
{FLOAT_LITERAL}             { return ATSTokenTypes.Companion.getFLOAT(); }
//?                         { return ATSTokenTypes.Companion.getCDATA; }  // Unused(); for binary data
{QUOTED_LITERAL}|{DOUBLE_QUOTED_LITERAL}
                            { return ATSTokenTypes.Companion.getSTRING(); }  // CHECK_ME
//
/*
  | T_LABEL of (int(*knd*), string) // HX-2013-01: should it be supported?
*/
//
","                         { return ATSTokenTypes.Companion.getCOMMA(); }
";"                         { return ATSTokenTypes.Companion.getSEMICOLON(); }
//
"("                         { return ATSTokenTypes.Companion.getLPAREN(); }
")"                         { return ATSTokenTypes.Companion.getRPAREN(); }
"]"                         { return ATSTokenTypes.Companion.getRBRACKET(); }
"}"                         { return ATSTokenTypes.Companion.getRBRACE(); }
//
"@("                        { return ATSTokenTypes.Companion.getATLPAREN(); }
"@["                        { return ATSTokenTypes.Companion.getATLBRACKET(); }
"#["                        { return ATSTokenTypes.Companion.getHASHLBRACKETOLON(); }
"@{"                        { return ATSTokenTypes.Companion.getATLBRACE(); }
//
// For macros:
//
"`("                        { return ATSTokenTypes.Companion.getBQUOTELPAREN(); }
",("                        { return ATSTokenTypes.Companion.getCOMMALPAREN(); }
"%("                        { return ATSTokenTypes.Companion.getPERCENTLPAREN(); }
//
{EXTCODE}                   { return ATSTokenTypes.Companion.getEXTCODE(); }
//
{END_OF_LINE_COMMENT}       { return ATSTokenTypes.Companion.getCOMMENT_LINE(); }
{TRADITIONAL_COMMENT}       { return ATSTokenTypes.Companion.getCOMMENT_BLOCK(); }
{END_OF_FILE_COMMENT}       { return ATSTokenTypes.Companion.getCOMMENT_REST(); }
{COMMENT}                   { return ATSTokenTypes.Companion.getCOMMENT(); }
//
"%"                         { return ATSTokenTypes.Companion.getPERCENT(); }
"?"                         { return ATSTokenTypes.Companion.getQMARK(); }

//Not ATS tokens, precisely:
{WHITE_SPACE}               { return ATSTokenTypes.Companion.getWHITE_SPACE(); }
{CRLF}                      { return ATSTokenTypes.Companion.getCRLF(); }
{IDENTIFIER}                { return ATSTokenTypes.Companion.getIDENTIFIER(); }
"!"{IDENTIFIER}             { return ATSTokenTypes.Companion.getVAL_IDENTIFIER(); }
"&"{IDENTIFIER}             { return ATSTokenTypes.Companion.getREF_IDENTIFIER(); }

} // End of <YYINITIAL>

/* Not using for now
<STRING> {
\" { yybegin(YYINITIAL); return symbol(sym.STRING_LITERAL, string.toString()); }
[^\n\r\"\\]+ { string.append( yytext() ); }
\\t { string.append('\t'); }
\\n { string.append('\n'); }
\\r { string.append('\r'); }
\\\" { string.append('\"'); }
\\ { string.append('\\'); }
} // End of <STRING>
*/
// This seems to cause a bug (OOME) in IntelliJ:
//<<EOF>>                     { return ATSTokenTypes.Companion.getEOF(); }
//
// Match anything not picked up and throw an error:
//
[^]         { return ATSTokenTypes.Companion.getBAD_CHARACTER(); }
//




























