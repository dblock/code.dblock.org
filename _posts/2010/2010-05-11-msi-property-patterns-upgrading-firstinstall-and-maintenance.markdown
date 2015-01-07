---
layout: post
title: "MSI Property Patterns: Upgrading, FirstInstall and Maintenance"
redirect_from: "/msi-property-patterns-upgrading-firstinstall-and-maintenance/"
date: 2010-05-11 20:00:00
tags: [msi, wix]
comments: true
dblog_post_id: 101
---
In writing new MSI installers, you must think about upgrade. I always recommend major upgrade – uninstall and reinstall is much cleaner. In that case the `Installed` vs. `NOT Installed` properties get confusing very quickly, so we came up with some shortcuts that make life easier.

We include the following file in every installer, as is.

{% highlight xml %}
<?include Runtime.wxi?>
{% endhighlight %}

Runtime.wxi follows.

{% highlight xml %}
<?xml version="1.0" encoding="utf-8"?>
<Include xmlns="http://schemas.microsoft.com/wix/2006/wi">

  <!--
   FirstInstall: when product is installed for the first time
   Upgrading: when we run upgrade for the installed product
   RemovingForUpgrade: when upgrade removes previous installation
   Uninstalling: when product is being completely unistalled
   Maintenance: configuration maintenance
  -->

  <CustomAction Id="SetFirstInstall" Property="FirstInstall" Value="true" />
  <CustomAction Id="SetUpgrading" Property="Upgrading" Value="true" />
  <CustomAction Id="SetRemovingForUpgrade" Property="RemovingForUpgrade" Value="true" />
  <CustomAction Id="SetUninstalling" Property="Uninstalling" Value="true" />
  <CustomAction Id="SetMaintenance" Property="Maintenance" Value="true" />

  <InstallExecuteSequence>
    <Custom Action="SetFirstInstall" After="FindRelatedProducts">
      NOT Installed AND NOT OLDERVERSION_BEINGUPGRADED AND NOT NEWERVERSION_INSTALLED
    </Custom>
    <Custom Action="SetUpgrading" After="SetFirstInstall">
      OLDERVERSION_BEINGUPGRADED AND NOT (REMOVE="ALL")
    </Custom>
    <Custom Action="SetUninstalling" After="SetUpgrading">
      Installed AND (REMOVE="ALL") AND NOT (OLDERVERSION_BEINGUPGRADED OR UPGRADINGPRODUCTCODE)
    </Custom>
    <Custom Action="SetMaintenance" After="SetUninstalling">
      Installed AND NOT Upgrading AND NOT Uninstalling AND NOT UPGRADINGPRODUCTCODE
    </Custom>
    <Custom Action="SetRemovingForUpgrade" After="RemoveExistingProducts">
      (REMOVE="ALL") AND UPGRADINGPRODUCTCODE
    </Custom>
  </InstallExecuteSequence>
  <InstallUISequence>
    <Custom Action="SetFirstInstall" After="FindRelatedProducts">
      Not Installed AND NOT OLDERVERSION_BEINGUPGRADED AND NOT NEWERVERSION_INSTALLED
    </Custom>
    <Custom Action="SetUpgrading" After="SetFirstInstall">
      OLDERVERSION_BEINGUPGRADED AND NOT (REMOVE="ALL")
    </Custom>
    <Custom Action="SetUninstalling" After="SetUpgrading">
      Installed AND (REMOVE="ALL") AND NOT (OLDERVERSION_BEINGUPGRADED OR UPGRADINGPRODUCTCODE)
    </Custom>
    <Custom Action="SetMaintenance" After="SetUninstalling">
      Installed AND NOT Upgrading AND NOT Uninstalling AND NOT UPGRADINGPRODUCTCODE
    </Custom>
  </InstallUISequence>
</Include>
{% endhighlight %}

Don’t forget to define the `OLDERVERSION_BEINGUPGRADED` and `NEWERVERSION_INSTALLED` properties in the `Upgrade` table.

{% highlight xml %}
<Upgrade Id="$(var.UpgradeCode)">
  <UpgradeVersion Property="OLDERVERSION_BEINGUPGRADED" Minimum="0.0.0" Maximum="$(var.ProductVersion)" IncludeMaximum="no" />
  <UpgradeVersion Property="NEWERVERSION_INSTALLED" OnlyDetect="yes" Minimum="$(var.ProductVersion)" IncludeMinimum="no" />
</Upgrade>
{% endhighlight %}

And change the install sequence for major upgrade.

{% highlight xml %}
<InstallExecuteSequence>
  <FindRelatedProducts Before="AppSearch" />
  <AppSearch Before="LaunchConditions" />
  <RemoveExistingProducts After="InstallInitialize" />
</InstallExecuteSequence>
<InstallUISequence>
  <FindRelatedProducts Before="AppSearch" />
  <AppSearch Before="LaunchConditions" />
</InstallUISequence>
{% endhighlight %}

Initially we had to deal with a legacy InstallShield installer and these properties were more complicated. Read [this post](/upgrading-freshinstall-maintenance-and-other-msi-convenience-properties) instead if that’s what you’re trying to do.
