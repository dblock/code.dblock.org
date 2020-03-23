---
layout: post
title: "Working with AWS SDK for C++ and Data Exchange"
date: "2020-03-06"
tags: [c++, aws, aws data exchange]
---
I haven't written any C++ since 2009, or [cross-platform C++ since the 90s](https://github.com/dblock/baseclasses). Working with the language in 2020 continues to require a lot of paper and glue (a.k.a. [autoconf and make](https://github.com/edrosten/autoconf_tutorial)). The scissors, however, have become dramatically sharper as the community seems to have adopted [CMake](https://cmake.org/).

And so, having found a spare half hour, I decided to build a "hello world" [C++ sample for AWS Data Exchange](https://github.com/aws-samples/aws-dataexchange-api-samples/pull/33). It was more challenging than I would have liked.

### Building the AWS SDK for C++

I began with [Getting Started Using the AWS SDK for C++](https://docs.aws.amazon.com/sdk-for-cpp/v1/developer-guide/getting-started.html) which links to [Setting Up the AWS SDK for C++](https://docs.aws.amazon.com/sdk-for-cpp/v1/developer-guide/setup.html). Since I'm using a Mac, I had to build the SDK from source.

{% highlight bash %}
> git clone git@github.com:aws/aws-sdk-cpp.git
> cd aws-sdk-cpp
aws-sdk-cpp>
{% endhighlight %}

I generally recommend using a released version of the SDK to ensure that you've checked out something stable.

{% highlight bash %}
aws-sdk-cpp> git checkout 1.7.278
{% endhighlight %}

The immediately confusing part of building the SDK was the idea that the `build` directory, i.e. the directory from which one runs `make`, is separate from the source. All my past projects required checking out the source, and typing `make`, or something similar. The sharp scissors, aka `cmake` generates a `Makefile` and is something you run from an empty `build` (sub)directory that you create.

{% highlight bash %}
aws-sdk-cpp> mkdir build
aws-sdk-cpp> cd build
aws-sdk-cpp/build> cmake .. -DCMAKE_BUILD_TYPE=Debug 
aws-sdk-cpp/build> make
{% endhighlight %}

You don't have to create a `build` directory inside the source directory, but it is even more confusing if you have to keep the source and the build in separate hierarchies.

### Installing the AWS SDK for C++

You must install the SDK with `make install`. I used the defaults, which is to copy the output to `/usr/local` on *nix systems, including MacOS. 

This destination is configured with `DCMAKE_INSTALL_PREFIX`. For example, the following builds the `Release` flavor and installs the SDK into `$HOME/bin/aws-sdk`.

{% highlight bash %}
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$HOME/bin/aws-sdk
make install
{% endhighlight %}

If you made a mistake, and want to change the destination, you can also uninstall the SDK with `make uninstall`, but it will leave a bunch of folders and some files behind, which is now [aws-sdk-cpp#1335](https://github.com/aws/aws-sdk-cpp/issues/1335).

It wasn't immediately clear whether installing the SDK was required, rather than just building it, because the documentation always referenced `sdk_build_dir`. It _is_ required and the docs really meant `sdk_install_dir`.

### Using the AWS SDK for C++

I then tried to build a very simple "hello world" sample using the C++ SDK. This, of course, didn't *just* work.

#### Minimal Code

A minimum example that uses the AWS SDK for C++ creates `Aws::SDKOptions`, calls `Aws::InitAPI`, does a bunch of work against one the many AWS services and calls `Aws::ShutdownAPI` to cleanup.

{% highlight c++ %}
#include <iostream>
#include <aws/core/Aws.h>
#include <aws/s3/S3Client.h>
#include <aws/s3/model/Bucket.h>

int main(int argc, char** argv)
{
    Aws::SDKOptions options;
    Aws::InitAPI(options);

    // Do something with S3 ...
    // Aws::S3::S3Client s3_client;
    // etc.

    Aws::ShutdownAPI(options);
}
{% endhighlight %}

#### CMakeLists.txt

A working `CMakeLists.txt` for version 1.7.278 of the SDK looks like this.

{% highlight cmake %}
cmake_minimum_required(VERSION 3.2)
project(project-name)

option(BUILD_SHARED_LIBS "Build shared libraries" ON)

find_package(AWSSDK REQUIRED COMPONENTS s3)
add_executable(project-name main.cpp)

target_compile_features(project-name PUBLIC cxx_std_11)
target_link_libraries(project-name ${AWSSDK_LINK_LIBRARIES})
{% endhighlight %}

I had started from an example in [this blog post](https://aws.amazon.com/blogs/developer/using-cmake-exports-with-the-aws-sdk-for-c/) from 2016 and from [the docs](https://docs.aws.amazon.com/sdk-for-cpp/v1/developer-guide/build-cmake.html), both of which were obsolete. I ran into a number of issues and have opened [aws-sdk-cpp#1334](https://github.com/aws/aws-sdk-cpp/issues/1334) to get help. This is the complete list of changes I had to make.

* The `find_package` arguments changed to `AWSSDK` (looks for `AWSSDKConfig.cmake`), `REQUIRED` (generates a fatal error if `AWSSDK` is not found), and `COMPONENTS`, followed by a list of components (e.g. `s3 dataexchange`).
* The `BUILD_SHARED_LIBS` option changed to being on, because the SDK recently started defaulting to building shared vs. static libraries.
* The `target_compile_features(my-example PUBLIC cxx_std_11)` was added to default to the C++ 11 standard required by the SDK code. This is potentially avoidable, see [aws-sdk-cpp#1338](https://github.com/aws/aws-sdk-cpp/issues/1338).
* When installed into a custom location, any reference to `-Daws-sdk-cpp_DIR` needed to become `-DAWSSDK_DIR` because of the new name for `AWSSDKConfig.cmake`. 
* The `target_link_libraries` arguments changed to include `${AWSSDK_LINK_LIBRARIES}` to avoid having to list all dependencies manually.

The minimal `CMakeLists.txt` example has been corrected in [aws-doc-sdk-examples#1022](https://github.com/awsdocs/aws-doc-sdk-examples/pull/1022), and the documentation in [aws-cpp-developer-guide#37](https://github.com/awsdocs/aws-cpp-developer-guide/pull/37).

### Listing S3 Buckets in C++

Now that I was able to build C++ code against the AWS SDK for C++, I wrote a demo that lists S3 buckets.

{% highlight cpp %}
#include <iostream>
#include <aws/core/Aws.h>
#include <aws/s3/S3Client.h>
#include <aws/s3/model/Bucket.h>

int main(int argc, char** argv)
{
    Aws::SDKOptions options;
    Aws::InitAPI(options);
    {
        Aws::S3::S3Client s3_client;
        auto outcome = s3_client.ListBuckets();

        if (outcome.IsSuccess()) {
            std::cout << "Your Amazon S3 buckets:" << std::endl;

            Aws::Vector<Aws::S3::Model::Bucket> bucket_list =
            outcome.GetResult().GetBuckets();

            for (auto const &bucket: bucket_list) {
                std::cout << "  * " << bucket.GetName() << std::endl;
            }
        } else {
            std::cout << "ListBuckets error: "
            << outcome.GetError().GetExceptionName() << " - "
            << outcome.GetError().GetMessage() << std::endl;
        }
    }
    Aws::ShutdownAPI(options);
}
{% endhighlight %}

The complete project can be found in [aws-samples/aws-sdk-cpp-list-s3-buckets](https://github.com/aws-samples/aws-sdk-cpp-list-s3-buckets).

### Listing Entitled Data Sets in AWS Data Exchange in C++

Finally, I wrote a sample for [AWS Data Exchange](https://aws.amazon.com/data-exchange). In the following example we list all the data sets that our current account is entitled to.

{% highlight cpp %}
Aws::DataExchange::DataExchangeClient client;

Aws::DataExchange::Model::ListDataSetsRequest list_data_sets_options;
list_data_sets_options.SetOrigin("ENTITLED");

auto outcome = client.ListDataSets(list_data_sets_options);

Aws::Vector<Aws::DataExchange::Model::DataSetEntry> data_sets_list = outcome.GetResult().GetDataSets();

for (auto const &data_set: data_sets_list) {
    std::cout 
        << data_set.GetOriginDetails().GetProductId() << "/"
        << data_set.GetId() << ": "
        << data_set.GetName() << std::endl 
        << "  " << data_set.GetDescription() 
        << std::endl;
}
{% endhighlight %}

See [aws-dataexchange-api-samples/subscribers/cpp/all-entitled-datasets](https://github.com/aws-samples/aws-dataexchange-api-samples/tree/master/subscribers/cpp/all-entitled-datasets), via [aws-dataexchange-api-samples#33](https://github.com/aws-samples/aws-dataexchange-api-samples/pull/33) for complete working code and a working `CMakeFile.txt`.
