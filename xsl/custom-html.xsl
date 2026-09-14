<?xml version='1.0'?>
<!DOCTYPE xsl:stylesheet [
    <!ENTITY % entities SYSTEM "./core/entities.ent">
    %entities;
]>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:pi="http://pretextbook.org/2020/pretext/internal"
    xmlns:exsl="http://exslt.org/common"
    extension-element-prefixes="exsl"
    exclude-result-prefixes="pi">

<xsl:import href="./core/pretext-html.xsl"/>

<!-- (1) Division: copy the core template (assembly.xsl:4396-4461) verbatim,
     adding one line to "next-blocks": -->


    <xsl:template match="book|article|part|chapter|appendix|frontmatter|backmatter|preface|section|subsection|subsubsection|exercises|worksheet|handout|reading-questions|references|glossary|solutions" mode="serial-stamp">
    <xsl:param name="eq-nodes"/>
    <xsl:param name="fn-nodes"/>
    <xsl:param name="blocks-nodes"/>
    <xsl:param name="figure-nodes"/>
    <xsl:param name="project-nodes"/>
    <xsl:param name="exercise-nodes"/>
    <xsl:param name="openproblem-nodes"/>
    <!-- Terminal: this division's items pool into one flat scope  -->
    <!-- here.  For a traditional division the authority is the    -->
    <!-- two-model test "is-structured-division": an unstructured  -->
    <!-- division (content, plus at most one of each specialized   -->
    <!-- division) is terminal, its specialized divisions pooling  -->
    <!-- into its scope; a structured division (traditional        -->
    <!-- subdivisions, or only worksheets) recurses, and each      -->
    <!-- worksheet then opens a scope apiece.  The test does not   -->
    <!-- apply to "frontmatter", "backmatter", a "preface", or the -->
    <!-- specialized divisions themselves, which keep the plain    -->
    <!-- child-division inspection.                                -->
    <xsl:variable name="terminal">
        <xsl:choose>
            <xsl:when test="self::book or self::article or self::part or self::chapter or self::appendix or self::section or self::subsection or self::subsubsection">
                <xsl:variable name="is-structured">
                    <xsl:apply-templates select="." mode="is-structured-division"/>
                </xsl:variable>
                <xsl:value-of select="$is-structured = 'false'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="not(part|chapter|appendix|section|subsection|subsubsection|preface|exercises|worksheet|handout|reading-questions|references|glossary|solutions)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="b-terminal" select="$terminal = 'true'"/>
    <xsl:variable name="b-open-eq"          select="not($eq-nodes)          and ($b-terminal or (@pi:level &gt;= $numbering-equations))"/>
    <xsl:variable name="b-open-fn"          select="not($fn-nodes)          and ($b-terminal or (@pi:level &gt;= $numbering-footnotes))"/>
    <xsl:variable name="b-open-blocks"      select="not($blocks-nodes)      and ($b-terminal or (@pi:level &gt;= $numbering-blocks))"/>
    <xsl:variable name="b-open-figure"      select="$b-number-figure-distinct      and not($figure-nodes)      and ($b-terminal or (@pi:level &gt;= $numbering-figures))"/>
    <xsl:variable name="b-open-project"     select="$b-number-project-distinct     and not($project-nodes)     and ($b-terminal or (@pi:level &gt;= $numbering-projects))"/>
    <xsl:variable name="b-open-exercise"    select="$b-number-exercise-distinct    and not($exercise-nodes)    and ($b-terminal or (@pi:level &gt;= $numbering-exercises))"/>
    <xsl:variable name="b-open-openproblem" select="$b-number-openproblem-distinct and not($openproblem-nodes) and ($b-terminal or (@pi:level &gt;= $numbering-openproblems))"/>
    <xsl:variable name="next-eq" select="$eq-nodes | self::*[$b-open-eq]//mrow[@pi:numbered = 'yes']"/>
    <xsl:variable name="next-fn" select="$fn-nodes | self::*[$b-open-fn]//fn"/>
    <!-- The shared "blocks" pool also gathers figure-likes, projects,  -->
    <!-- inline exercises, and open problems that are not run distinct. -->
    <xsl:variable name="next-blocks" select="$blocks-nodes
        | self::*[$b-open-blocks]//*[&FUNDAMENTAL-BLOCK-FILTER;]
        | self::*[$b-open-blocks]//mrow[@pi:numbered = 'yes']
        | self::*[$b-open-blocks and not($b-number-figure-distinct)]//*[&TOP-FIGURE-FILTER;]
        | self::*[$b-open-blocks and not($b-number-project-distinct)]//*[&PROJECT-FILTER;]
        | self::*[$b-open-blocks and not($b-number-exercise-distinct)]//exercise[&INLINE-EXERCISE-FILTER;]
        | self::*[$b-open-blocks and not($b-number-openproblem-distinct)]//*[&OPENPROBLEM-FILTER;]"/>
    <xsl:variable name="next-figure"      select="$figure-nodes      | self::*[$b-open-figure]//*[&TOP-FIGURE-FILTER;]"/>
    <xsl:variable name="next-project"     select="$project-nodes     | self::*[$b-open-project]//*[&PROJECT-FILTER;]"/>
    <xsl:variable name="next-exercise"    select="$exercise-nodes    | self::*[$b-open-exercise]//exercise[&INLINE-EXERCISE-FILTER;]"/>
    <xsl:variable name="next-openproblem" select="$openproblem-nodes | self::*[$b-open-openproblem]//*[&OPENPROBLEM-FILTER;]"/>
    <xsl:copy>
        <xsl:apply-templates select="@*|node()" mode="serial-stamp">
            <xsl:with-param name="eq-nodes" select="$next-eq"/>
            <xsl:with-param name="fn-nodes" select="$next-fn"/>
            <xsl:with-param name="blocks-nodes" select="$next-blocks"/>
            <xsl:with-param name="figure-nodes" select="$next-figure"/>
            <xsl:with-param name="project-nodes" select="$next-project"/>
            <xsl:with-param name="exercise-nodes" select="$next-exercise"/>
            <xsl:with-param name="openproblem-nodes" select="$next-openproblem"/>
        </xsl:apply-templates>
    </xsl:copy>
</xsl:template>

<!-- (2) Intro/conclusion: copy assembly.xsl:4470-4501, adding to "next-blocks": -->
        <!--| (../introduction | ../conclusion)[not($blocks-nodes)]//mrow[@pi:numbered = 'yes']-->
<xsl:template match="article/introduction | chapter/introduction | section/introduction | subsection/introduction | appendix/introduction | article/conclusion | chapter/conclusion | section/conclusion | subsection/conclusion | appendix/conclusion" mode="serial-stamp">
    <xsl:param name="eq-nodes"/>
    <xsl:param name="fn-nodes"/>
    <xsl:param name="blocks-nodes"/>
    <xsl:param name="figure-nodes"/>
    <xsl:param name="project-nodes"/>
    <xsl:param name="exercise-nodes"/>
    <xsl:param name="openproblem-nodes"/>
    <xsl:variable name="next-eq" select="$eq-nodes | (../introduction | ../conclusion)[not($eq-nodes)]//mrow[@pi:numbered = 'yes']"/>
    <xsl:variable name="next-fn" select="$fn-nodes | (../introduction | ../conclusion)[not($fn-nodes)]//fn"/>
    <xsl:variable name="next-blocks" select="$blocks-nodes
        | (../introduction | ../conclusion)[not($blocks-nodes)]//*[&FUNDAMENTAL-BLOCK-FILTER;]
        | (../introduction | ../conclusion)[not($blocks-nodes)]//mrow[@pi:numbered = 'yes']
        | (../introduction | ../conclusion)[not($blocks-nodes) and not($b-number-figure-distinct)]//*[&TOP-FIGURE-FILTER;]
        | (../introduction | ../conclusion)[not($blocks-nodes) and not($b-number-project-distinct)]//*[&PROJECT-FILTER;]
        | (../introduction | ../conclusion)[not($blocks-nodes) and not($b-number-exercise-distinct)]//exercise[&INLINE-EXERCISE-FILTER;]
        | (../introduction | ../conclusion)[not($blocks-nodes) and not($b-number-openproblem-distinct)]//*[&OPENPROBLEM-FILTER;]"/>
    <xsl:variable name="next-figure"      select="$figure-nodes      | (../introduction | ../conclusion)[not($figure-nodes)      and $b-number-figure-distinct]//*[&TOP-FIGURE-FILTER;]"/>
    <xsl:variable name="next-project"     select="$project-nodes     | (../introduction | ../conclusion)[not($project-nodes)     and $b-number-project-distinct]//*[&PROJECT-FILTER;]"/>
    <xsl:variable name="next-exercise"    select="$exercise-nodes    | (../introduction | ../conclusion)[not($exercise-nodes)    and $b-number-exercise-distinct]//exercise[&INLINE-EXERCISE-FILTER;]"/>
    <xsl:variable name="next-openproblem" select="$openproblem-nodes | (../introduction | ../conclusion)[not($openproblem-nodes) and $b-number-openproblem-distinct]//*[&OPENPROBLEM-FILTER;]"/>
    <xsl:copy>
        <xsl:apply-templates select="@*|node()" mode="serial-stamp">
            <xsl:with-param name="eq-nodes" select="$next-eq"/>
            <xsl:with-param name="fn-nodes" select="$next-fn"/>
            <xsl:with-param name="blocks-nodes" select="$next-blocks"/>
            <xsl:with-param name="figure-nodes" select="$next-figure"/>
            <xsl:with-param name="project-nodes" select="$next-project"/>
            <xsl:with-param name="exercise-nodes" select="$next-exercise"/>
            <xsl:with-param name="openproblem-nodes" select="$next-openproblem"/>
        </xsl:apply-templates>
    </xsl:copy>
</xsl:template>


<!-- (3) Numbered mrow: count on the blocks counter -->
<xsl:template match="mrow[@pi:numbered = 'yes']" mode="serial-stamp">
    <xsl:param name="eq-nodes"/>
    <xsl:param name="fn-nodes"/>
    <xsl:param name="blocks-nodes"/>
    <xsl:param name="figure-nodes"/>
    <xsl:param name="project-nodes"/>
    <xsl:param name="exercise-nodes"/>
    <xsl:param name="openproblem-nodes"/>
    <xsl:copy>
        <xsl:attribute name="pi:serial">
            <xsl:apply-templates select="." mode="position-in-node-set">
                <xsl:with-param name="nodes" select="$blocks-nodes"/>
            </xsl:apply-templates>
        </xsl:attribute>
        <xsl:apply-templates select="@*|node()" mode="serial-stamp">
            <xsl:with-param name="eq-nodes" select="$eq-nodes"/>
            <xsl:with-param name="fn-nodes" select="$fn-nodes"/>
            <xsl:with-param name="blocks-nodes" select="$blocks-nodes"/>
            <xsl:with-param name="figure-nodes" select="$figure-nodes"/>
            <xsl:with-param name="project-nodes" select="$project-nodes"/>
            <xsl:with-param name="exercise-nodes" select="$exercise-nodes"/>
            <xsl:with-param name="openproblem-nodes" select="$openproblem-nodes"/>
        </xsl:apply-templates>
    </xsl:copy>
</xsl:template>

<!-- (4) Prefix number at the blocks level -->
<xsl:template match="mrow|md[@pi:authored-one-line]" mode="structure-number">
    <xsl:call-template name="block-structure-number">
        <xsl:with-param name="levels" select="$numbering-blocks"/>
    </xsl:call-template>
</xsl:template>

</xsl:stylesheet>
