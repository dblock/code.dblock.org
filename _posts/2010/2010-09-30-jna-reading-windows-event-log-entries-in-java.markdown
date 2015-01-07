---
layout: post
title: "JNA: Reading Windows Event Log entries in Java"
redirect_from: "/jna-reading-windows-event-log-entries-in-java/"
date: 2010-09-30 15:19:37
tags: [jna, win32]
comments: true
dblog_post_id: 125
---

![Windows-Event-Viewer-Icon-Large]({{ site.url }}/images/posts/2010/2010-09-30-jna-reading-windows-event-log-entries-in-java/windows-event-viewer-icon-large_4.jpg)

I’ve recently had to deal with writing Windows event log entries in Java, part of the [Log4jna](https://github.com/dblock/log4jna) experiment. Writing was easy, but I have a stretch goal in my mind for our application: I would like to leverage the Windows event log for all kinds of operational events. We could write a service that reads the event log for events that services within our enterprise services conglomerate and reports events that have not much in common except that they were fired by our software.

Let’s read the Windows event log in Java with [JNA](https://github.com/twall/jna).

#### I Want Candy

I certainly don’t want to deal with the actual event log in my code - I’d like to be able to write something like this.

{% highlight java %}
EventLogIterator iter = new EventLogIterator("Application");
while(iter.hasNext()) {
    EventLogRecord record = iter.next();
    System.out.println(record.getRecordId()
            + ": Event ID: " + record.getEventId()
            + ", Event Type: " + record.getType()
            + ", Event Source: " + record.getSource());
}
{% endhighlight %}

If you don’t care about how it’s implemented, get the latest JNA build (this code will ship in JNA 3.2.8) and just use it. Otherwise keep reading.

#### Reading Events

Let’s step back and examine the Win32 API for events. The first call opens and closes an event log. An event log lives on a certain machine (null for current) and has a name (eg. _Application_ or _System_).

{% highlight java %}
public HANDLE OpenEventLog(String lpUNCServerName, String lpSourceName);
public boolean CloseEventLog(HANDLE hEventLog);
{% endhighlight %}

You can also find out the number of event log records and the ID of the oldest event log entry.

{% highlight java %}
public boolean GetNumberOfEventLogRecords(HANDLE hEventLog, IntByReference NumberOfRecords);
public boolean GetOldestEventLogRecord(HANDLE hEventLog, IntByReference OldestRecord);
{% endhighlight %}

Finally, reading the event log is exposed via the _ReadEventLog_ API.

{% highlight java %}
public boolean ReadEventLog(HANDLE hEventLog, int dwReadFlags, int dwRecordOffset,
        Pointer lpBuffer, int nNumberOfBytesToRead, IntByReference pnBytesRead,
        IntByReference pnMinNumberOfBytesNeeded);
{% endhighlight %}

The `ReadEventLog` function is meant to be called until there’re no more events. It will read forwards or backwards depending on the flags (`EVENTLOG_FORWARDS_READ` or `EVENTLOG_BACKWARDS_READ`). It will fill the buffer with data from multiple records or fail, telling us that the buffer is not large enough to hold even one record (`ERROR_INSUFFICIENT_BUFFER`). Finally, it will finish signaling that it has read all the entries (`ERROR_HANDLE_EOF`).

{% highlight java %}
if (! Advapi32.INSTANCE.ReadEventLog(_h,
        WinNT.EVENTLOG_SEQUENTIAL_READ | WinNT.EVENTLOG_FORWARDS_READ, ...) {

    // read failed
    int rc = Kernel32.INSTANCE.GetLastError();

    if (rc == W32Errors.ERROR_INSUFFICIENT_BUFFER) {
        // not enough bytes in the buffer, resize and read again
    } else {
        if (rc != W32Errors.ERROR_HANDLE_EOF) {
            // error, throw exception
        }
        // done
    }
}
// read succeeded, iterate in the buffer
{% endhighlight %}

After a successful `ReadEventLog` call we receive a buffer with multiple entries of the `EVENTLOGRECORD` type (it’s a simple structure with a bunch of fields). Each record has a different size (each record contains the same header, but different data). We can iterate through it by incrementing a native pointer (JNA’s `Pointer.share` returns a pointer to an offset from an existing pointer value).

{% highlight java %}
int dwRead = ... // number of bytes read this time
Pointer pevlr = buffer; // top of buffer
while (dwRead > 0)
{
    EVENTLOGRECORD record = new EVENTLOGRECORD(pevlr);
    // record contains event ID, etc.
    dwRead -= record.Length.intValue();
    pevlr = pevlr.share(record.Length.intValue());
}
{% endhighlight %}

We can put this together in a unit test.

{% highlight java %}
public void testReadEventLogEntries() {
    HANDLE h = Advapi32.INSTANCE.OpenEventLog(null, "Application");
    IntByReference pnBytesRead = new IntByReference();
    IntByReference pnMinNumberOfBytesNeeded = new IntByReference();
    Memory buffer = new Memory(1024 * 64);
    IntByReference pOldestRecord = new IntByReference();
    assertTrue(Advapi32.INSTANCE.GetOldestEventLogRecord(h, pOldestRecord));
    int dwRecord = pOldestRecord.getValue();
    int rc = 0;
    while(true) {
        if (! Advapi32.INSTANCE.ReadEventLog(h,
                WinNT.EVENTLOG_SEQUENTIAL_READ | WinNT.EVENTLOG_FORWARDS_READ,
                0, buffer, (int) buffer.size(), pnBytesRead, pnMinNumberOfBytesNeeded)) {
            rc = Kernel32.INSTANCE.GetLastError();
            if (rc == W32Errors.ERROR_INSUFFICIENT_BUFFER) {
                buffer = new Memory(pnMinNumberOfBytesNeeded.getValue());
                continue;
            }
            break;
        }
        int dwRead = pnBytesRead.getValue();
        Pointer pevlr = buffer;
        while (dwRead > 0)
        {
            EVENTLOGRECORD record = new EVENTLOGRECORD(pevlr);
            System.out.println(dwRecord
                    + " Event ID: " + record.EventID.intValue()
                    + " Event Type: " + record.EventType.intValue()
                    + " Event Source: " + pevlr.getString(record.size(), true));
            dwRecord++;
            dwRead -= record.Length.intValue();
            pevlr = pevlr.share(record.Length.intValue());
        }
    }
    assertTrue(rc == W32Errors.ERROR_HANDLE_EOF);
    assertTrue(Advapi32.INSTANCE.CloseEventLog(h));
}
{% endhighlight %}

#### Iterator

Let’s go back to our goal to write an iterator and break the above test apart.

First, we’ll declare an `EventLogRecord` class that encapsulates the the auto-incremented record ID, the event source and the record data itself.

{% highlight java %}
public static class EventLogRecord {
    private EVENTLOGRECORD _record = null;
    private int _recordId;
    private String _source;
    ...
{% endhighlight %}

We’ll write an iterator for this type. It will need to hold the handle to the event log, the buffer to store events, a flag that indicates that the iteration has finished, the number of bytes remaining in the current buffer, a pointer to the current record and the auto-incremented logical record ID. The latter will have to start at some number, ie. the oldest record ID.

{% highlight java %}
public static class EventLogIterator
    implements Iterable<EventLogRecord>, Iterator<EventLogRecord> {

    private HANDLE _h = null;
    private Memory _buffer = new Memory(1024 * 64); // memory buffer to store events
    private boolean _done = false; // no more events
    private int _dwRead = 0; // number of bytes remaining in the current buffer
    private Pointer _pevlr = null; // pointer to the current record
    private int _dwRecord; // current record id

    public EventLogIterator(String sourceName) {
        this(null, sourceName);
    }

    public EventLogIterator(String serverName, String sourceName) {
        _h = Advapi32.INSTANCE.OpenEventLog(serverName, sourceName);
        if (_h == null) {
            throw new Win32Exception(Kernel32.INSTANCE.GetLastError());
        }
        IntByReference pOldestRecord = new IntByReference();
        if (! Advapi32.INSTANCE.GetOldestEventLogRecord(_h, pOldestRecord)) {
            throw new Win32Exception(Kernel32.INSTANCE.GetLastError());
        }
        _dwRecord = pOldestRecord.getValue();
    }
{% endhighlight %}

Eventually the iterator will have to terminate and close the event log. Let’s implement _close_. If the caller must abandon the iterator half way through the iteration or on an exception, it must call close to avoid leaking a handle.

{% highlight java %}
public void close() {
    _done = true;
    if (_h != null) {
        if (! Advapi32.INSTANCE.CloseEventLog(_h)) {
            throw new Win32Exception(Kernel32.INSTANCE.GetLastError());
        }
        _h = null;
    }
}
{% endhighlight %}

Knowing whether there’re more records in the iterator involves reading ahead and returning whether the iterator is done.

{% highlight java %}
@Override
public boolean hasNext() {
    read();
    return ! _done;
}
{% endhighlight %}

Similarly, the next record involves reading ahead, constructing and returning the record at the current location.

{% highlight java %}
@Override
public EventLogRecord next() {
    read();
    EventLogRecord record = new EventLogRecord(_dwRecord, _pevlr);
    _dwRecord++;
    _dwRead -= record.getLength();
    _pevlr = _pevlr.share(record.getLength());
    return record;
}
{% endhighlight %}

Finally, the actual `read`. Do nothing, for as long as there’re bytes in the current buffer and read the next block otherwise. Apply the same logic for resizing the buffer and for finishing the iteration.

{% highlight java %}
private boolean read() {
    // finished or bytes remain, don't read any new data
    if (_done || _dwRead > 0) {
        return false;
    }

    IntByReference pnBytesRead = new IntByReference();
    IntByReference pnMinNumberOfBytesNeeded = new IntByReference();

    if (! Advapi32.INSTANCE.ReadEventLog(_h,
            WinNT.EVENTLOG_SEQUENTIAL_READ | WinNT.EVENTLOG_FORWARDS_READ,
            0, _buffer, (int) _buffer.size(), pnBytesRead, pnMinNumberOfBytesNeeded)) {

        int rc = Kernel32.INSTANCE.GetLastError();

        // not enough bytes in the buffer, resize
        if (rc == W32Errors.ERROR_INSUFFICIENT_BUFFER) {
            _buffer = new Memory(pnMinNumberOfBytesNeeded.getValue());

            if (! Advapi32.INSTANCE.ReadEventLog(_h,
                    WinNT.EVENTLOG_SEQUENTIAL_READ | WinNT.EVENTLOG_FORWARDS_READ,
                    0, _buffer, (int) _buffer.size(), pnBytesRead, pnMinNumberOfBytesNeeded)) {
                throw new Win32Exception(Kernel32.INSTANCE.GetLastError());
            }
        } else {
            // read failed, no more entries or error
            close();
            if (rc != W32Errors.ERROR_HANDLE_EOF) {
                throw new Win32Exception(rc);
            }
            return false;
        }
    }

    _dwRead = pnBytesRead.getValue();
    _pevlr = _buffer;
    return true;
}
{% endhighlight %}

#### Links

- The code has been checked into JNA, see [Advapi32Util.java](https://github.com/twall/jna/blob/master/contrib/platform/src/com/sun/jna/platform/win32/Advapi32Util.java)
- MSDN [sample](http://msdn.microsoft.com/en-us/library/bb427356(v=VS.85).aspx) on reading the event log in C.
