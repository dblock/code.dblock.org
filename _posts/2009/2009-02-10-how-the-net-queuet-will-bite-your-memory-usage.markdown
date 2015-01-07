---
layout: post
title: "How the .NET Queue<T> will bite your memory usage"
redirect_from: "/how-the-net-queuet-will-bite-your-memory-usage/"
date: 2009-02-10 13:45:00
tags: [.net]
comments: true
dblog_post_id: 32
---
I was profiling an application at my real job with [MemProfiler](http://memprofiler.com/). It yielded a very high number of instances in a .NET `Queue<T>`. What was abnormal is a constant growth of the numbers over time.

I narrowed this down to the .NET Queue class. If you [examine the .NET Queue source code](http://blogs.msdn.com/sburke/archive/2008/01/16/configuring-visual-studio-to-debug-net-framework-source-code.aspx), you will notice that it grows infinitely by design in a rotating window pattern. Enqueue means incrementing the pointer modulo the length of the array and Dequeue means decrement the pointer, except when on a collision and needing to resize. In this case everything is copied to a larger array that grows by a factor.

{% highlight c# %}
public T Dequeue() {
  T removed = _array[_head];
  _array[_head] = default(T);
  _head = (_head + 1) % _array.Length;
  _size--;
  _version++;
  return removed;
}

public void Enqueue(T item) {
  if (_size == _array.Length) {
    int newcapacity = (int)((long)_array.Length * (long)_GrowFactor / 100);
    if (newcapacity < _array.Length + _MinimumGrow) {
      newcapacity = _array.Length + _MinimumGrow;
    }
    SetCapacity(newcapacity);
  }

  _array[_tail] = item;
  _tail = (_tail + 1) % _array.Length;
  _size++;
  _version++;
}
{% endhighlight %}

There's a way to reclaim the empty space by calling `Queue<T>.TrimExcess`. A regular call to this function fixed the apparent memory leak, but it's extremely inefficient. It comes down to the balance between performance and memory usage.

{% highlight c# %}
public void TrimExcess() {
  int threshold = (int)(((double)_array.Length) * 0.9);
  if( _size < threshold ) {
    SetCapacity(_size);
  }
}
{% endhighlight %}

The issue for our implementation is that the queue space isn't ever reclaimed automatically. We're using the queue in its processing sense: blocking, thread-safe and bounded. Hence if we had a million items in the queue once, we would keep an array of a million items until `TrimExcess` is called. That is just a lot of memory to hang onto.

A more efficient implementation for our needs was a double-queue. Inserting happens on the "in" queue while retrieving happens from the "out" queue. When the "out" queue is empty, it is dropped (reclaiming the memory in the next GC) the "in" queue is flipped with the "out" queue, and the "in" queue is re-created. The only lock taken is during the flip.

