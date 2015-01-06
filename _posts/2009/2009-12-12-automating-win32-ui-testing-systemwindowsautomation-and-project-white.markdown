---
layout: post
title: "Automating Win32 UI Testing: System.Windows.Automation and Project White"
redirect_from: "/automating-win32-ui-testing-systemwindowsautomation-and-project-white"
date: 2009-12-12 14:10:45
tags: [testing, ui, .net, win32]
comments: true
---
Just when I thought things were well under control in [dotNetInstaller](https://github.com/dblock/dotnetinstaller/), someone filed [this bug](http://dotnetinstaller.codeplex.com/workitem/4856). It basically says that an installed check doesn’t work. This is pretty major functionality and I was under the impression that I unit-tested it in every possible direction. There’s at least a dozen tests that walk all kinds of scenarios around these checks and everything passes. It took ten seconds to find the culprit: the UI has a silly bug and such a check cannot be added to a configuration node. Naturally unit tests don’t use the UI. The user cannot take advantage of the functionality, even though the functionality itself ... functions.

It’s a great example of total failure. Something has to be done.

### Executing the Application

The first part of testing a UI is being able to execute and shutdown the application. Fortunately .NET has a very usable model for this.

```cs
public static int Run(string filename, string args)
{
    using(Process p = new Process())
    {
        p.StartInfo.WorkingDirectory = Path.GetDirectoryName(filename);
        p.StartInfo.FileName = filename;
        p.StartInfo.Arguments = args;
        p.StartInfo.WindowStyle = ProcessWindowStyle.Normal;
        p.Start();
        Thread.Sleep(2000);
        p.WaitForInputIdle();
        p.CloseMainWindow();
        p.WaitForExit();
        return p.ExitCode;
    }
}
```

### Simple UI Tests

We can fetch the window title and test simple scenarios such as passing /? on the command line: the window title should be "Help".

```cs
[Test]
public void TestRunHelp()
{
    using (Process p = new Process())
    {
        p.StartInfo.FileName = "InstallerEditor.exe";
        p.StartInfo.Arguments = "/?";
        p.StartInfo.WindowStyle = ProcessWindowStyle.Normal;
        p.Start();
        Thread.Sleep(2000);
        p.WaitForInputIdle();
        Assert.AreEqual("Help", p.MainWindowTitle);
        p.CloseMainWindow();
        p.WaitForExit();
    }
}
```

### Hitting Menu Items

Getting the window title is nice, but I want to click through menus, or drag and drop stuff! After a bit of search I stumbled on the [Microsoft UI Automation Framework](http://msdn.microsoft.com/en-us/library/ms747327.aspx) in .NET 3.0. I had it running in half an hour and I am impressed. I’ll agree with James McCaffrey who writes in [this post](http://msdn.microsoft.com/en-us/magazine/cc163288.aspx) "I believe the development of the UI Automation library is one of the most important advances in test automation to date" and John Robbins who says in [his article](http://msdn.microsoft.com/en-us/magazine/cc163465.aspx) that this is the "realization of the dream of being able to automate the GUI portions of your application plus the guarantee that the playback would be exactly what you expected". We’ve been doing this for web applications for ever, now this kind of robustness comes to Win32 forms and WPF applications.

I used these two articles to get started, so I’ll skip the how. Just read them.

- [GUI Control to Major Tom (John Robbins)](http://msdn.microsoft.com/en-us/magazine/cc163465.aspx)
- [The Microsoft UI Automation Library (Dr. James McCaffrey)](http://msdn.microsoft.com/en-us/magazine/cc163288.aspx)

### Dumping Controls

I was too lazy to look at the code of the application I am testing, so I wrote something simple to dump controls. This gives a tree of controls that I can now fetch, use, etc.

```cs
public abstract class UIAutomation
{
    public static void DumpControl(AutomationElement el)
    {
        DumpControl(el, true);
    }

    public static void DumpControl(AutomationElement el, bool recurse)
    {
        DumpControl(el, recurse, 0);
    }

    private static void DumpControl(AutomationElement el, bool recurse, int level)
    {
        Console.WriteLine("{0}{1}: {2}", new String(' ', level),
            el.Current.ControlType.LocalizedControlType, el.Current.Name);

        if (recurse)
        {
            foreach (AutomationElement child in el.FindAll(TreeScope.Children, Condition.TrueCondition))
            {
                DumpControl(child, true, level + 1);
            }
        }
    }
}
```

### Working with Menus

You can locate the application’s menu bar and each menu.

```cs
AutomationElement installerEditorForm = AutomationElement.FromHandle(p.MainWindowHandle);
// menus
AutomationElementCollection menuBars = installerEditorForm.FindAll(TreeScope.Children, new PropertyCondition(
    AutomationElement.ControlTypeProperty, ControlType.MenuBar));
Assert.AreEqual(1, menuBars.Count);
mainMenuItem = menuBars[0];
AutomationElementCollection menus = mainMenuItem.FindAll(TreeScope.Children, new PropertyCondition(
    AutomationElement.ControlTypeProperty, ControlType.MenuItem));
Assert.AreEqual(4, menus.Count);
fileMenuItem = menus[0];
viewMenuItem = menus[1];
toolsMenuItem = menus[2];
helpMenuItem = menus[3];
```

To click the File menu, you get a pattern that applies to menus and call a specific pattern method (for an ExpandCollapsePattern, Expand).

```cs
ExpandCollapsePattern fileMenuItemOpenPattern = (ExpandCollapsePattern) fileMenuItem.GetCurrentPattern(
    ExpandCollapsePattern.Pattern);
fileMenuItemOpenPattern.Expand();
AutomationElement fileMenu = fileMenuItem.FindFirst(TreeScope.Children,
    new AndCondition(
        new PropertyCondition(AutomationElement.ControlTypeProperty, ControlType.Menu),
        new PropertyCondition(AutomationElement.NameProperty, "File")));
AutomationElement fileMenuItemNew = installerEditorUI.fileMenuItem.FindFirst(TreeScope.Children,
    new AndCondition(
        new PropertyCondition(AutomationElement.ControlTypeProperty, ControlType.MenuItem),
        new PropertyCondition(AutomationElement.NameProperty, "New")));
```

You can already see that this is becoming rather cumbersome. I would have to write a UIMenu and UIMenuItem class or it’s going to be a copy-paste exercise.

### Project White

Someone must have had this problem before me. That someone is ThoughtWorks and they created [White](http://white.codeplex.com/). White exposes a strongly typed and therefore less verbose and more usable object model for the UI being tested.

```cs
[Test]
public void TestMainMenu()
{
    using (Application installerEditor = Application.Launch(InstallerEditorExeUtils.Executable))
    {
        Window mainWindow = installerEditor.GetWindow("Installer Editor", InitializeOption.NoCache);
        Menus mainMenu = mainWindow.MenuBar.TopLevelMenu;
        Assert.AreEqual(4, mainMenu.Count);
        Assert.AreEqual("File", mainMenu[0].Name);
        Assert.AreEqual("View", mainMenu[1].Name);
        Assert.AreEqual("Tools", mainMenu[2].Name);
        Assert.AreEqual("Help", mainMenu[3].Name);
    }
}
```

### Clicking Through Menus

Clicking through menus with White, starting with the top-level application menu, could use a helper function. Each item needs to be clicked in order to fetch its children, collapsed menu items don’t have any.

```cs
public static Menu ClickThroughMenu(Menus m, string[] items)
{
    List<string> itemsArray = new List<string>(items);
    if (itemsArray.Count == 0) throw new ArgumentOutOfRangeException();
    Menu rootMenu = m.Find(itemsArray[0]);
    if (rootMenu == null) throw new Exception(string.Format("Missing menu: ", itemsArray[0]));
    itemsArray.RemoveAt(0);
    return ClickThroughMenu(rootMenu, itemsArray.ToArray());
}

public static Menu ClickThroughMenu(Menu m, string[] items)
{
    m.Click();
    foreach (string item in items)
    {
        Menu itemMenu = m.ChildMenus.Find(item);
        if (itemMenu == null)
        {
            throw new Exception(string.Format("Missing menu: {0}", item));
        }
        itemMenu.Click();
        m = itemMenu;
    }
    return m;
}
```

Here’s how to use it:

```cs
UIAutomation.ClickThroughMenu(mainWindow.MenuBar.TopLevelMenu,
    new string[] { "Edit", "Add", "Configurations", "Setup Configuration" });
```

### Bug Solved and Unit-Tested

My original problem was [a bug in dotNetInstaller](http://dotnetinstaller.codeplex.com/workitem/4856) where adding an installed check through the UI would popup an error. I was now able to write a unit test for it, see [it’s source code](https://github.com/dblock/dotnetinstaller/SourceControl/changeset/view/36754#801450).

