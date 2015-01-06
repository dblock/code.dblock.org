---
layout: post
title: "IBM Cognos BI: generic XSLT normalization for table data"
redirect_from: "/ibm-cognos-bi-generic-xslt-normalization-for-table-data/"
date: 2010-11-10 16:21:11
tags: [xslt, xml, cognos]
comments: true
dblog_post_id: 143
---
I was recently looking at a Cognos BI dataset output in the XML format. It’s a pretty generic approach for data sets that don’t know what type of data they are looking at upfront. It looks like this.

```xml
<?xml version="1.0" encoding="utf-8"?>
<dataset xmlns="http://developer.cognos.com/schemas/xmldata/1/"
  xmlns:xs="http://www.w3.org/2001/XMLSchema-instance">
  <metadata>
    <item name="IP Address" type="xs:string" length="102"/>
    <item name="Host" type="xs:string" length="512"/>
    <item name="Port" type="xs:int" precision="1"/>
    <item name="Instance" type="xs:string" length="512"/>
    <item name="Database Type" type="xs:string" length="512"/>
  </metadata>
  <data>
    <row>
      <value>172.16.0.26</value>
      <value>server1</value>
      <value>1433</value>
      <value>MSSQLSERVER</value>
      <value>Microsoft SQL Server 2008</value>
    </row>
    <row>
      <value>172.16.0.31</value>
      <value xs:nil="true" />
      <value>1434</value>
      <value></value>
      <value>Microsoft SQL Server Redirector</value>
    </row>
  </data>
</dataset>
```

This is a rather annoying format to work with. Let's transform it, generically, into something normalized (or strongly typed). We can nest two XSLT foreach statements – for each row, for each item, output a node with the name of the item and the corresponding value. The node name cannot contain special characters and will need to have some replacements. We’ll also have to count rows and items to get the right mapping.

```xml
<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:cognos="http://developer.cognos.com/schemas/xmldata/1/">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" standalone="yes" indent="yes"/>
  <xsl:template match="/">
    <xsl:element name="DataSet">
      <xsl:for-each select="//*[name()='row']">
        <xsl:variable name="row" select="position()" />
        <xsl:element name="Row">
          <xsl:for-each select="//*[name()='item']">
            <xsl:variable name="elementName" select="@name" />
            <xsl:variable name="index" select="position()" />
            <xsl:element name="{translate($elementName,' ','_')}">
              <xsl:value-of select="//cognos:row[$row]/cognos:value[$index]" />
            </xsl:element>
          </xsl:for-each>
        </xsl:element>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
```

Here’s the output.

```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<DataSet>
  <Row>
    <IP_Address>172.16.0.26</IP_Address>
    <Host>server1</Host>
    <Port>1433</Port>
    <Instance>MSSQLSERVER</Instance>
    <Database_Type>Microsoft SQL Server 2008</Database_Type>
  </Row>
  <Row>
    <IP_Address>172.16.0.31</IP_Address>
    <Host></Host>
    <Port>1434</Port>
    <Instance></Instance>
    <Database_Type>Microsoft SQL Server Redirector</Database_Type>
  </Row>
</DataSet>
```

If we need to transform this data further, we now have a stable format to work with. The order of columns in the report may change, but we won’t have to rewrite the XSLT again.
