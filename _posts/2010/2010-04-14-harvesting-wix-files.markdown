---
layout: post
title: "Harvesting wix files"
redirect_from: "/harvesting-wix-files/"
date: 2010-04-14 21:54:22
tags: [wix]
comments: true
dblog_post_id: 97
---
Sometimes great is the enemy of good. I recently had to harvest a large number of files to create a wix installer. I tried _heat.exe_, but after struggling with its generation style and even considering writing an XSLT, I decided it would be faster to just code what I want in C#. This generates a .wxi file that follows somewhat of a standard of naming components .C, directories .D and skipping .svn folders.

It just gets the job done.

{% highlight c# %}
using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Xml;

namespace WixHarvest
{
    class Program
    {
        static string MakeId(string id)
        {
            return id.Replace("_", ".").Replace("-", ".");
        }

        const String wixns = "https://schemas.microsoft.com/wix/2006/wi";

        static List<String> GenerateFragment(XmlDocument doc, XmlNode parent, DirectoryInfo dir, DirectoryInfo root)
        {
            List<String> componentIds = new List<string>();

            XmlNode directory = (doc.FirstChild == parent)
                ? parent.AppendChild(doc.CreateElement("DirectoryRef", wixns))
                : parent.AppendChild(doc.CreateElement("Directory", wixns));

            string id = "";
            if (parent.Attributes["Id"] != null) id = parent.Attributes["Id"].Value.Replace(".D", "") + ".";
            id += dir.Name + ".D";

            directory.Attributes.Append(doc.CreateAttribute("Id")).Value = MakeId(id);
            if (doc.FirstChild != parent)
            {
                directory.Attributes.Append(doc.CreateAttribute("Name")).Value = dir.Name;
            }

            FileInfo[] files = dir.GetFiles();
            List<DirectoryInfo> subdirs = new List<DirectoryInfo>(dir.GetDirectories());
            for (int i = subdirs.Count - 1; i >= 0; i--)
            {
                if (subdirs.Name == ".svn")
                {
                    subdirs.RemoveAt(i);
                }
            }

            if (files.Length == 0 && subdirs.Count == 0)
            {
                XmlNode component = directory.AppendChild(doc.CreateElement("Component", wixns));
                string componentId = id.Replace(".D", ".") + "C";
                componentIds.Add(componentId);
                component.Attributes.Append(doc.CreateAttribute("Id")).Value = MakeId(componentId);
                component.Attributes.Append(doc.CreateAttribute("Guid")).Value = Guid.NewGuid().ToString();
                component.AppendChild(doc.CreateElement("CreateFolder", wixns));
            }
            else if (files.Length > 0)
            {
                XmlNode component = directory.AppendChild(doc.CreateElement("Component", wixns));
                string componentId = id.Replace(".D", ".") + "C";
                componentIds.Add(componentId);
                component.Attributes.Append(doc.CreateAttribute("Id")).Value = MakeId(componentId);
                component.Attributes.Append(doc.CreateAttribute("Guid")).Value = Guid.NewGuid().ToString();
                foreach (FileInfo file in files)
                {
                    XmlNode node = component.AppendChild(doc.CreateElement("File", wixns));
                    node.Attributes.Append(doc.CreateAttribute("Id")).Value = MakeId(id.Replace(".D", ".") + file.Name);
                    node.Attributes.Append(doc.CreateAttribute("Source")).Value =
                        "$(var." + Path.GetFileName(root.FullName) + "Dir)\\" +
                        file.FullName.Substring(root.FullName.Length).TrimStart('\\');
                }
            }

            foreach (DirectoryInfo subdir in subdirs)
            {
                componentIds.AddRange(GenerateFragment(doc, directory, subdir, root));
            }

            return componentIds;
        }

        static void Main(string[] args)
        {
            try
            {
                if (args.Length == 0)
                {
                    throw new ArgumentException("Missing dir");
                }

                XmlDocument doc = new XmlDocument();
                doc.LoadXml("<Include xmlns=\"https://schemas.microsoft.com/wix/2006/wi\" />");
                DirectoryInfo root = new DirectoryInfo(args[0]);
                List<String> componentIds = GenerateFragment(doc, doc.FirstChild, root, root);
                XmlNode featureRef = doc.FirstChild.AppendChild(doc.CreateElement("Feature", wixns));
                featureRef.Attributes.Append(doc.CreateAttribute("Id")).Value = MakeId(root.Name);
                featureRef.Attributes.Append(doc.CreateAttribute("Level")).Value = "1";
                featureRef.Attributes.Append(doc.CreateAttribute("Title")).Value = root.Name;
                foreach (String componentId in componentIds)
                {
                    XmlNode node = featureRef.AppendChild(doc.CreateElement("ComponentRef", wixns));
                    node.Attributes.Append(doc.CreateAttribute("Id")).Value = MakeId(componentId);
                }
                Console.WriteLine(doc.OuterXml);
            }
            catch (Exception ex)
            {
                Console.WriteLine("ERROR: {0}", ex.Message);
            }
        }
    }
}
{% endhighlight %}
