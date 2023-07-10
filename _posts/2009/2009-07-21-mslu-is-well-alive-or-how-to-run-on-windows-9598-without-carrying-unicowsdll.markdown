---
layout: post
title: "MSLU is well alive or how to run on Windows 95/98 without carrying unicows.dll"
redirect_from: "/mslu-is-well-alive-or-how-to-run-on-windows-9598-without-carrying-unicowsdll/"
date: 2009-07-21 04:00:00
tags: [win32]
comments: true
dblog_post_id: 43
---
I accidentally broke support for Windows 95/98/ME in [dotNetInstaller](https://github.com/dblock/dotnetinstaller). I was even more surprised that someone cared. A developer reported the bug, and then my friends in Botswana are saying that Windows 95/98/ME is alive and well all over the place. How can I say no to African children?!

The first problem is locating a Windows 98 CD in the pile of old MSDN distributions, creating a boot disk image in an .IMZ format, converting it to .IMG with [WinImage](http://www.winimage.com/index.html) and finally making a VM. Fixing the display driver was a pain. Phew, I now have a booting and running Windows 98 to test after half a day of travelling back 10 years of software development.

MSLU stands for Microsoft Layer for Unicode. Making MSLU work involves not upgrading to Visual Studio 2008 (sigh) and doing a few tricks [described in an excellent article in MSDN](http://msdn.microsoft.com/en-us/magazine/cc301794.aspx). I ran all C++ unit tests and fixed those that didn't run on Windows 98 (a couple of Win32 API calls only). Good.

Carrying unicows.dll is annoying, this is a setup bootstrapper. So I tried embedding it as a resource (`RES_UNICOWS CUSTOM "unicows.dll"`) and am now decompressing it at runtime to `%TEMP%\unicows.dll`. It works beautifully!

The complete code is [here](https://github.com/dotnetinstaller/dotnetinstaller/blob/2.4/dotNetInstallerLib/MSLU.cpp).

{% highlight c %}
static HMODULE SaveAndLoadMSLU()
{
  char tf[MAX_PATH] = { 0 };
  if (! GetTempPathA(MAX_PATH, tf))
    return NULL;
  if (0 != strcat_s<>(tf, "unicows.dll"))
    return NULL;

  if (GetFileAttributesA(tf) == INVALID_FILE_ATTRIBUTES)
  {
    HRSRC res_unicows = ::FindResourceA(NULL, "RES_UNICOWS", "CUSTOM");
    if (res_unicows == NULL)
      return NULL;

    HGLOBAL hgl = ::LoadResource(NULL, res_unicows);
    if (hgl == NULL)
      return NULL;

    DWORD size = SizeofResource(NULL, res_unicows);
    if (size == 0)
      return NULL;

    LPVOID buffer = LockResource(hgl);

    HANDLE h = CreateFileA(tf, GENERIC_READ | GENERIC_WRITE, FILE_SHARE_READ, NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
    if (h == INVALID_HANDLE_VALUE)
      return NULL;

    DWORD written = 0;
    if (! WriteFile(h, buffer, size, & written, NULL))
    {
      ::CloseHandle(h);
      return NULL;
    }

    ::CloseHandle(h);
  }

  return ::LoadLibraryA(tf);
}

static HMODULE __stdcall LoadMSLU (void)
{
  HMODULE hUnicows = ::LoadLibraryA("unicows.dll");
  if (hUnicows == 0) hUnicows = SaveAndLoadMSLU();
  if (hUnicows == 0)
  {
    MessageBoxA(0, "Error loading unicows.dll (Microsoft Layer for Unicode, MSLU)", "dotNetInstaller", MB_ICONSTOP | MB_OK);
    _exit(-1);
  }
  return hUnicows;
}

// load Microsoft Layer for Unicode (MSLU)
// http://msdn.microsoft.com/en-us/magazine/cc301794.aspx
extern "C" HMODULE (__stdcall *_PfnLoadUnicows) (void) = & LoadMSLU;
{% endhighlight %}
