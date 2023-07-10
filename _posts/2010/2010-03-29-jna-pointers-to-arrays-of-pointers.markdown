---
layout: post
title: "JNA: pointers to arrays of pointers"
redirect_from: "/jna-pointers-to-arrays-of-pointers/"
date: 2010-03-29 16:55:31
tags: [jna, java, win32]
comments: true
dblog_post_id: 92
---
I recently had a few drinks too many with my coworkers at the Russian Vodka Room and took the subway home. It’s a thirty minute ride during which I tried to implement [EnumerateSecurityPackages](https://learn.microsoft.com/en-us/windows/win32/api/sspi/nf-sspi-enumeratesecuritypackagesa) in JNA. It was not a success and resulted in three dozen logs from JVM crashes. A good night sleep helped make it actually work.

{% highlight java %}
SECURITY_STATUS SEC_Entry EnumerateSecurityPackages(
  PULONG pcPackages,
  PSecPkgInfo* ppPackageInfo
);
{% endhighlight %}

This function wants a pointer to an array of pointer to a [SecPkgInfo](https://learn.microsoft.com/en-us/windows/win32/api/sspi/ns-sspi-secpkginfoa) structure.

{% highlight java %}
typedef struct _SecPkgInfo {
  ULONG    fCapabilities;
  USHORT   wVersion;
  USHORT   wRPCID;
  ULONG    cbMaxToken;
  SEC_CHAR *Name;
  SEC_CHAR *Comment;
} SecPkgInfo, *PSecPkgInfo;
{% endhighlight %}

In JNA this one is simple. The Name and Comment fields need to be explicitly declared `UNICODE` and an inner `ByReference` child added so that `SecPkgInfo` can be returned.

{% highlight java %}
public static class SecPkgInfo extends Structure {
    public static class ByReference extends SecPkgInfo implements Structure.ByReference {  }
    public NativeLong fCapabilities;
    public short wVersion;
    public short wRPCID;
    public NativeLong cbMaxToken;
    public WString Name;
    public WString Comment;
    public SecPkgInfo() {
        fCapabilities = new NativeLong(0);
        wVersion = 1;
        wRPCID = 0;
        cbMaxToken = new NativeLong(0);
    }
}
{% endhighlight %}

So what’s a pointer to an array of these? It’s another structure that has the first item in the array as a reference within it. The first item can also auto-magically give us the entire array of a given size.

{% highlight java %}
public static class PSecPkgInfo extends Structure {
    public static class ByReference extends PSecPkgInfo implements Structure.ByReference { }
    public SecPkgInfo.ByReference pPkgInfo;
    public PSecPkgInfo() { }
    public SecPkgInfo.ByReference[] toArray(int size) {
        return (SecPkgInfo.ByReference[]) pPkgInfo.toArray(size);
    }
}
{% endhighlight %}

What’s a pointer to `PSecPkgInfo` now? It’s a `PSecPkgInfo.ByReference`. `EnumerateSecurityPackages` becomes:

{% highlight java %}
public int EnumerateSecurityPackages(IntByReference pcPackages,
        PSecPkgInfo.ByReference ppPackageInfo);
{% endhighlight %}

Fortunately using this pointer to an array of pointers is a no-brainer.

{% highlight java %}
IntByReference pcPackages = new IntByReference();
PSecPkgInfo.ByReference pPackageInfo = new PSecPkgInfo.ByReference();
Secur32.INSTANCE.EnumerateSecurityPackages(pcPackages, pPackageInfo);
{% endhighlight %}

Now we can do something useful with this.

{% highlight java %}
public static String[] getSecurityPackages() {
    IntByReference pcPackages = new IntByReference();
    PSecPkgInfo.ByReference pPackageInfo = new PSecPkgInfo.ByReference();
    int rc = Secur32.INSTANCE.EnumerateSecurityPackages(pcPackages, pPackageInfo);
    if(W32Errors.SEC_E_OK != rc) {
        throw new LastErrorException(rc);
    }
    SecPkgInfo.ByReference[] packagesInfo = pPackageInfo.toArray(pcPackages.getValue());
    ArrayList<String> names = new ArrayList<String>(pcPackages.getValue());
    for(SecPkgInfo.ByReference packageInfo : packagesInfo) {
        names.add(packageInfo.Name.toString());
    }
    rc = Secur32.INSTANCE.FreeContextBuffer(pPackageInfo.getPointer());
    if(W32Errors.SEC_E_OK != rc) {
        throw new LastErrorException(rc);
    }
    return names.toArray(new String[0]);
}
{% endhighlight %}
