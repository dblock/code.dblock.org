---
layout: post
title: "Nesting multiple ConfigurationElement types in a ConfigurationElementCollection"
redirect_from: "/nesting-multiple-configurationelement-types-in-a-configurationelementcollection/"
date: 2009-02-18 23:15:00
tags: [.net]
comments: true
---
Today I stumbled upon an unpleasant problem with .NET configuration. I'd like to have a configuration file that looks like this.

```xml
<collection>
 <one />
 <two />
 <one />
</collection>
```

Well, this is not kosher in .NET configuration terms. So I reduced my expectations. I want the following.

```xml
<collection>
 <add type="one" />
 <add type="two" />
 <add type="one" />
</collection>
```

Every element has more-a-less similar parameters, but they might vary slightly. Since "one" and "two" are specialized, I'd like to implement two classes **One** and **Two** and derive them from the same common parent class. How do I achieve that?

The trick is to use a proxy class and to manufacture the right type during deserialization.

<!-- more -->

#### NestedConfiguration.cs

```cs
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Text;
using System.Xml;

namespace NestedConfiguration
{
  public class CollectionSection : ConfigurationSection
  {
    [ConfigurationProperty("collection", IsDefaultCollection = false)]
    [ConfigurationCollection(typeof(CollectionConfig), AddItemName = "add")]
    public CollectionConfig Collection
    {
      get
      {
        return (CollectionConfig) this["collection"];
      }

      set
      {
        this["collection"] = value;
      }
    }
  }

  public class Parent : ConfigurationElement
  {
    [ConfigurationProperty("name", IsRequired = true)]
    public string Name
    {
      get
      {
        return (string) this["name"];
      }

      set
      {
        this["name"] = value;
      }
    }

    [ConfigurationProperty("type", IsRequired = true)]
    public string Type
    {
      get
      {
        return (string) this["type"];
      }

      set
      {
        this["type"] = value;
      }
    }

    public void ProxyDeserializeElement(XmlReader reader, bool serializeCollectionKey)
    {
      DeserializeElement(reader, serializeCollectionKey);
    }
  }

  public class One : Parent
  {
    [ConfigurationProperty("p1")]
    public string P1
    {
      get
      {
        return (string)this["p1"];
      }

      set
      {
        this["p1"] = value;
      }
    }
  }

  public class Two : Parent
  {
    [ConfigurationProperty("p2")]
    public string P2
    {
      get
      {
        return (string)this["p2"];
      }

      set
      {
        this["p2"] = value;
      }
    }
  }

  public class Proxy : ConfigurationElement
  {
    private Parent _Parent = null;

    public Parent Parent
    {
      get
      {
        return _Parent;
      }
    }

    public Proxy()
    {
    }

    public Parent Instance
    {
      get
      {
        return _Parent;
      }
    }

    protected override void DeserializeElement(XmlReader reader, bool serializeCollectionKey)
    {
      string type = reader.GetAttribute("type");
      switch (type)
      {
        case "one":
          _Parent = new One();
          break;
        case "two":
          _Parent = new Two();
          break;
        default:
          throw new ArgumentException(string.Format("Invalid type: {0}", type));
      }

      _Parent.ProxyDeserializeElement(reader, serializeCollectionKey);
    }
  }

  public class CollectionConfig : ConfigurationElementCollection
  {
    public CollectionConfig()
    {

    }

    protected override ConfigurationElement CreateNewElement()
    {
      return new Proxy();
    }

    protected override Object GetElementKey(ConfigurationElement element)
    {
      return ((Proxy)element).Parent.Name;
    }

    public Parent this[int index]
    {
      get
      {
        return ((Proxy)BaseGet(index)).Parent;
      }

      set
      {
        if (BaseGet(index) != null)
        {
          BaseRemoveAt(index);
        }

        BaseAdd(index, value);
      }
    }
  }
}
```

#### App.config

```xml
<?xml version="1.0" encoding="utf-8" ?>
<configuration>
 <configSections>
  <section name="CollectionSection" type="NestedConfiguration.CollectionSection, NestedConfiguration" />
 </configSections>
 <CollectionSection>
  <collection>
   <add type="one" name="one-1" p1="one-1 p1" />
   <add type="one" name="one-2" p1="one-2 p1" />
   <add type="two" name="two-1" p2="two-1 p2" />
  </collection>
 </CollectionSection>
</configuration>
```

#### Program.cs

```cs
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Text;

namespace NestedConfiguration
{
  class Program
  {
    static void Main(string[] args)
    {
      try
      {
        ExeConfigurationFileMap map = new ExeConfigurationFileMap();
        map.ExeConfigFilename = "NestedConfiguration.exe.config";
        Configuration configuration = ConfigurationManager.OpenMappedExeConfiguration(map, ConfigurationUserLevel.None);
        CollectionSection config = (CollectionSection)configuration.Sections[typeof(CollectionSection).Name];
        Console.WriteLine("Nested configurations: {0}", config.Collection.Count);
        foreach (Proxy proxy in config.Collection)
        {
          Console.WriteLine("Type: {0}", proxy.Parent.GetType());
        }
      }
      catch(Exception ex)
      {
        Console.WriteLine(ex.Message);
      }
    }
  }
}
```
