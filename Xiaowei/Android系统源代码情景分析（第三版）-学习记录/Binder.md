# 运行在不同进程中的应用程序如何通信？

Android系统基于Linux内核开发，但是没有采用Linux自带的通信机制，比如Linux的管道（Pipe）、信号（Signal）、消息队列（Message）、共享内存（Share Memory）和插口（Socket）等。而是使用的**Binder**。

# Binder的优势

在进程间传输数据时，只需要执行一次复制操作，因此，它不仅提高了效率，而且节省了内存空间。