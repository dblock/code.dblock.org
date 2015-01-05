---
layout: post
title: "Upgrading, FreshInstall, Maintenance and other MSI convenience properties"
redirect_from: "/upgrading-freshinstall-maintenance-and-other-msi-convenience-properties"
date: 2009-06-05 14:15:00
tags: [wix]
comments: true
---
In writing new MSI installers, we always have to deal with legacy InstallShield installers, upgrading, maintenance mode, etc. The properties get confusing very quickly, so we came up with some shortcuts that make life easier.

```xml
<!--
  FirstInstall: when product is installed for the first time
  Upgrading: when we run upgrade for the installed product
  RemovingForUpgrade: when upgrade removes previous installation
  Uninstalling: when product is being completely unistalled
  FreshInstall: not upgrading legacy version
  UpgradingFromLegacy: upgrading from a legacy version
  UpgradingAny: Upgrading OR UpgradingFromLegacy
  Maintenance: configuration maintenance
  -->
```

You must first detect your legacy and existing product(s). For legacy, this is up to you (eg. we look in some old registry key under `Windows\Uninstall`). For MSI you can use the Upgrade table.

```xml
<Upgrade Id="$(var.UpgradeCode)">
  <UpgradeVersion Minimum="$(var.BUILD_VERSION_STRING)" IncludeMinimum="no" OnlyDetect="yes" Property="NEWERVERSION_INSTALLED" />
  <UpgradeVersion Minimum="1.0.0" IncludeMinimum="yes" Maximum="$(var.BUILD_VERSION_STRING)" IncludeMaximum="no" Property="OLDERVERSION_BEINGUPGRADED" />
</Upgrade>
```

The properties.

```xml
<!-- previously installed version of product -->
<Property Id="INSTALLEDPRODUCTVERSION">
  <RegistrySearch Id="GetInstalledProductVersion" Type="raw" Root="HKLM" Key="$(var.ProductRegistryKey)" Name="InstalledDisplayVersion" />
</Property>
<!-- legacy product location -->
<Property Id="LEGACYPRODUCT_INSTALLLOCATION">
  <RegistrySearch Id="GetInstalledLegacyProductInstallLocation" Type="raw" Root="HKLM" Key="$(var.WindowsUninstallKey)\$(var.LegacyProductProductCode)" Name="InstallLocation" />
</Property>
<!-- legacy product product guid -->
<Property Id="LEGACYPRODUCT_BEINGUPGRADED">
  <RegistrySearch Id="GetInstalledLegacyProductProductGuid" Type="raw" Root="HKLM" Key="$(var.WindowsUninstallKey)\$(var.LegacyProductProductCode)" Name="ProductGuid" />
</Property>
<!-- legacy product version (for display) -->
<Property Id="LEGACYPRODUCT_INSTALLEDVERSION">
  <RegistrySearch Id="GetInstalledLegacyProductVersion" Type="raw" Root="HKLM" Key="$(var.WindowsUninstallKey)\$(var.LegacyProductProductCode)" Name="DisplayVersion" />
</Property>
```

And finally the install sequences and custom actions that define the properties.

```xml
<CustomAction Id="SetFirstInstall" Property="FirstInstall" Value="true"/>
<CustomAction Id="SetUpgrading" Property="Upgrading" Value="true"/>
<CustomAction Id="SetRemovingForUpgrade" Property="RemovingForUpgrade" Value="true"/>
<CustomAction Id="SetUninstalling" Property="Uninstalling" Value="true"/>
<CustomAction Id="SetFreshInstall" Property="FreshInstall" Value="true"/>
<CustomAction Id="SetUpgradingFromLegacy" Property="UpgradingFromLegacy" Value="true"/>
<CustomAction Id="SetUpgradingAny" Property="UpgradingAny" Value="true"/>
<CustomAction Id="SetMaintenance" Property="Maintenance" Value="true"/>
<InstallExecuteSequence>
  <Custom Action="SetFirstInstall" After="FindRelatedProducts">
    NOT Installed AND NOT OLDERVERSION_BEINGUPGRADED AND NOT NEWERVERSION_INSTALLED AND NOT UPGRADINGPRODUCTCODE
  </Custom>
  <Custom Action="SetUpgrading" After="FindRelatedProducts">
    OLDERVERSION_BEINGUPGRADED AND NOT (REMOVE="ALL")
  </Custom>
  <Custom Action="SetRemovingForUpgrade" After="FindRelatedProducts">
    (REMOVE="ALL") AND UPGRADINGPRODUCTCODE
  </Custom>
  <Custom Action="SetUninstalling" After="FindRelatedProducts">
    Installed AND (REMOVE="ALL") AND NOT (OLDERVERSION_BEINGUPGRADED OR UPGRADINGPRODUCTCODE)
  </Custom>
  <Custom Action="SetFreshInstall" After="SetFirstInstall">
    FirstInstall AND NOT LEGACYPRODUCT_BEINGUPGRADED
  </Custom>
  <Custom Action="SetUpgradingFromLegacy" After="SetFirstInstall">
    FirstInstall AND LEGACYPRODUCT_BEINGUPGRADED
  </Custom>
  <Custom Action="SetUpgradingAny" After="SetUpgradingFromLegacy">
    Upgrading OR UpgradingFromLegacy
  </Custom>
  <Custom Action="SetMaintenance" After="SetUpgradingAny">
    Installed AND REINSTALLMODE
  </Custom>
</InstallExecuteSequence>
<InstallUISequence>
  <Custom Action="SetFirstInstall" After="FindRelatedProducts">
    NOT Installed AND NOT OLDERVERSION_BEINGUPGRADED AND NOT NEWERVERSION_INSTALLED AND NOT UPGRADINGPRODUCTCODE
  </Custom>
  <Custom Action="SetUpgrading" After="FindRelatedProducts">
    OLDERVERSION_BEINGUPGRADED AND NOT (REMOVE="ALL")
  </Custom>
  <Custom Action="SetRemovingForUpgrade" After="FindRelatedProducts">
    (REMOVE="ALL") AND UPGRADINGPRODUCTCODE
  </Custom>
  <Custom Action="SetUninstalling" After="FindRelatedProducts">
    Installed AND (REMOVE="ALL") AND NOT (OLDERVERSION_BEINGUPGRADED OR UPGRADINGPRODUCTCODE)
  </Custom>
  <Custom Action="SetFreshInstall" After="SetFirstInstall">
    FirstInstall AND NOT LEGACYPRODUCT_BEINGUPGRADED
  </Custom>
  <Custom Action="SetUpgradingFromLegacy" After="SetFirstInstall">
    FirstInstall AND LEGACYPRODUCT_BEINGUPGRADED
  </Custom>
  <Custom Action="SetUpgradingAny" After="SetUpgradingFromLegacy">
    Upgrading OR UpgradingFromLegacy
  </Custom>
  <Custom Action="SetMaintenance" After="SetUpgradingAny">
    Installed AND REINSTALLMODE
  </Custom>
</InstallUISequence>
```
