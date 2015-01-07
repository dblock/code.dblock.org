---
layout: post
title: "Locating UI controls and clicking through menus with System.Windows.Automation and White"
redirect_from: "/locating-ui-controls-and-clicking-through-menus-with-systemwindowsautomation-and-white/"
date: 2009-12-16 14:21:00
tags: [testing, ui, .net, win32]
comments: true
dblog_post_id: 75
---
In a previous post I had implemented clicking through menus with White. Someone [pointed out](http://white.codeplex.com/Thread/View.aspx?ThreadId=77934) that this was a solved problem and I didn’t need to write any code.

{% highlight c# %}
Window mainWindow = installerEditor.GetWindow("Installer Editor", InitializeOption.NoCache);
MenuBar mainWindowMenuBar = mainWindow.MenuBar;
mainWindowMenuBar.MenuItem("File", "Save");
{% endhighlight %}

What I noticed next is that it would take anywhere from 3 to 10 seconds to resolve mainWindow.MenuBar. I looked at the implementation and it does a descendents (DFS?) search. The menu bar is a child of the window, so we can avoid the recursion altogether.

{% highlight c# %}
private static DictionaryMappedItemFactory _factory = new DictionaryMappedItemFactory();

public static T Find<T>(UIItem item, string name) where T : UIItem
{
    AutomationElementFinder finder = new AutomationElementFinder(item.AutomationElement);
    AutomationElement found = finder.Child(AutomationSearchCondition.ByName("Application"));
    return (T) _factory.Create(found, item.ActionListener);
}
{% endhighlight %}

Generalizing this further, a simple tree walker with a depth limit seems to be much more efficient for both scenarios of deep and wide trees. The following code comes from [this](http://white.codeplex.com/Thread/View.aspx?ThreadId=49778) thread, I didn’t write it.

{% highlight c# %}
private static AutomationElement Find(AutomationElement element, string name, int maxDepth)
{
    if (maxDepth == 0)
    {
        return null;
    }
    TreeWalker walker = TreeWalker.RawViewWalker;
    AutomationElement current = walker.GetFirstChild(element);
    while (current != null)
    {
        if ((string)current.GetCurrentPropertyValue(AutomationElement.NameProperty) == name)
        {
            return current;
        }
        current = walker.GetNextSibling(current);
    }
    current = walker.GetFirstChild(element);
    while (current != null)
    {
        AutomationElement found = Find(current, name, maxDepth - 1);
        if (found != null)
        {
            return found;
        }
        current = walker.GetNextSibling(current);
    }
    return null;
}

private static UIItem Find(UIItem item, string name, int maxDepth)
{
    AutomationElement element = Find(item.AutomationElement, name, maxDepth);
    if (element == null) return null;
    return (UIItem)_factory.Create(element, item.ActionListener);
}

public static T Find<T>(UIItem item, string name) where T : UIItem
{
    return (T)Find(item, name, 4);
}
{% endhighlight %}

The new test code executes magnitudes faster to click File –> Save.

{% highlight c# %}
Window mainWindow = installerEditor.GetWindow("Installer Editor", InitializeOption.NoCache);
UIAutomation.Find<MenuBar>(mainWindow, "Application").MenuItem("File", "Save").Click();
{% endhighlight %}

Another interesting aspect of this menu bar is that it is [virtualized](http://msdn.microsoft.com/en-us/library/ee684094(VS.85).aspx). This means that while you may be holding an instance of a MenuBar, it may have been hidden by another UI element at some point and will now throw an exception with the `UIA_E_ELEMENTNOTAVAILABLE` error code if you try to use it. This is annoying: if I need to click on 10 menu items, I have to do 10 searches, starting from the top every time! To solve this, .NET 4.0 has introduced a new [IUIAutomationVirtualizedItemPattern](http://msdn.microsoft.com/en-us/library/ee684094(VS.85).aspx) that has a `Realize` method to materialize the object again.
