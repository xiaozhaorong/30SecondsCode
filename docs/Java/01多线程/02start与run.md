start()方法 与 run()方法
---
#### start() 方法的含义
    1. 启动新线程：通知jvm在空闲的时候启动线程
    2. 准备工作：
    3. 不能重复执行start():会抛```java.lang.IllegalThreadStateException``` 异常
- start源码解析
    1. start方法是被<b>synchronized</b>方法修饰的,可以保证线程安全
    2. 由JVM创建的main方法线程和system组线程，并不会通过start来启动
    3. start0是一个native方法 是由C和C++实现的 不在此次研究范围
   
    ```
        public synchronized void start() {
       
        // 1 检查线程状态 不是新线程会抛出异常  
        if (threadStatus != 0)
            throw new IllegalThreadStateException();
        // 2 将当前线程加入线程组    
          group.add(this);

        boolean started = false;
        try {
        // 3 调用start0()方法启动线程
            start0();
            started = true;
        } finally {
            try {
                if (!started) {
                    group.threadStartFailed(this);
                }
            } catch (Throwable ignore) {
                /* do nothing. If start0 threw a Throwable then
                  it will be passed up the call stack */
            }
        }
    }
    ```
    ```
    private native void start0();
    ```