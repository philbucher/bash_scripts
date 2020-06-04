bash_scripts

add the following lines to `.git/info/exclude`

```
cmake_build*
install*
kratos_configure_sh_general.sh
.kratoscompilation.info
.vscode/*
```

Helpful commands:
- silence output from programs run in terminal: e.g.: `alias virtualbox='virtualbox &> /dev/null'`