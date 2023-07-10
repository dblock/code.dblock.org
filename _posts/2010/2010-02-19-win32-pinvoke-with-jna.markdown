---
layout: post
title: "Win32 PInvoke with JNA"
redirect_from: "/win32-pinvoke-with-jna/"
date: 2010-02-19 02:20:03
tags: [jna, java, win32]
comments: true
dblog_post_id: 83
---
One of the main reasons I never liked JAVA is because of it's cross-platform philosophy. The idea is that everything needs to be so generic and portable, that you can’t get anything actually done. Running applications in the real world means integrating with the operating system. In my own experience I needed to get the username of the user logged into Windows, so I’ve generated everything from [JNI](http://java.sun.com/j2se/1.5.0/docs/guide/jni/) monstrosities, C# libraries with COM wrappers invoked via [Jacob](http://danadler.com/jacob/) to making remote service calls from [CXF](http://cxf.apache.org/) to [WCF](https://learn.microsoft.com/en-us/dotnet/framework/wcf/whats-wcf). Can someone please provide a solution that doesn’t make me feel retarded debugging SOAP messages for a local call to GetUserNameW?!

Thank you. The answer is called [JNA](https://github.com/twall/jna/).

Wrapping a Win32 function is a trivial exercise for any C/C++ developer who dealt with Win32. GetUserNameW takes a wchar_t buffer and a pointer to a length. In JNA this looks like this.

{% highlight java %}
import com.sun.jna.*;
import com.sun.jna.ptr.IntByReference;

public interface IAdvapi32 extends com.sun.jna.examples.win32.W32API {
    IAdvapi32 INSTANCE = (IAdvapi32) Native.loadLibrary("Advapi32", IAdvapi32.class);

    public boolean GetUserNameW(char[] buffer, IntByReference len);
}
{% endhighlight %}

In order not to feel too much like a Win32 developer, we ought to wrap this thing with a usable method. `GetUserName` returns a boolean for success or failure and can give us an additional error when the buffer isn’t sufficiently large.

{% highlight java %}
public abstract class Advapi32 {

    public static final int ERROR_INSUFFICIENT_BUFFER = 122;

    public static String getUserName() {
        char[] buffer = new char[128];
        IntByReference len = new IntByReference(buffer.length);
        boolean result = IAdvapi32.INSTANCE.GetUserNameW(buffer, len);

        if (! result) {

            int rc = Kernel32.INSTANCE.GetLastError();

            switch(rc) {
            case ERROR_INSUFFICIENT_BUFFER:
                buffer = new char[len.getValue()];
                break;
            default:
                throw new LastErrorException(Native.getLastError());
            }

            result = IAdvapi32.INSTANCE.GetUserNameW(buffer, len);
        }

        if (! result) {
            throw new LastErrorException(Native.getLastError());
        }

        return Native.toString(buffer);
    }
}
{% endhighlight %}

Note how JNA implements those nice methods that convert `char[]` buffers to `String`. That’s service!

