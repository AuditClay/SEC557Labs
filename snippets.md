Visual Studio - Disable Restricted Mode
----------

Add the following line to the settings.json file for VSCode

```
"security.workspace.trust.enabled": false
"editor.hover.enabled": false
```

Graphite Storage Schema Config
----------

```
[carbon]
pattern = ^carbon\..*
retentions = 1m:30d,10m:1y,1h:5y

[sec557]
pattern = ^sec557\..*
retentions = 1d:1y

[issues]
pattern = ^issues\..*
retentions = 1d:1y

[benchdemo]
pattern = ^benchdemo\..*
retentions = 1d:1y

[benchmark]
pattern = ^benchmark\..*
retentions = 1d:1y

[patchage]
pattern = ^patchage\..*
retentions = 1d:1y

[patchvelocity]
pattern = ^patchvelocity\..*
retentions = 1d:1y

[ad]
pattern = ^ad\..*
retentions = 1d:1y

[default]
pattern = .*
retentions = 1m:30d

```


CIS Benchmark Inspec Profiles
----------

Windows Server 2016
https://github.com/dev-sec/windows-baseline.git
https://dev-sec.io/baselines/windows/