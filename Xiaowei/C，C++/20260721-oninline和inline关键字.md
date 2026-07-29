# 出处

AOSP源码中msm/init/main.c中。

```c
static noinline void __init_refok rest_init(void) {...}
```

# 作用

C语言oninline与inline是一对意义相反的关键字，inline的作用是编译期间直接替换代码块，也就是说编译后就没有这个方法了，而是直接把代码块替换调用这个函数的地方，oninline就相反，强制不替换，保持原有的函数