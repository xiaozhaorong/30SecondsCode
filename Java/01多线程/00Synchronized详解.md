Synchronized详解
---
##### Synchronized 的作用
- 官网解释
> 同步方法支持一种简单的策略来防止线程干扰和内存一致性错误：如果一个对象对多个线程可见，则对该对象变量的所有读取或写入都是通过同步方法完成的
- 果然 看完感觉跟没看一样
> 自己理解 用Synchronized修饰的代码 可做到 保证在同一时刻只有一个线程执行这段代码（代码段变成原子性的，保证并发安全）
##### Synchronized的两个用法
- 对象锁
    1. 同步代码块锁(自己指定锁对象)
    2. 方法锁(默认锁对象为this当前实例对象)
   
```    
/**
 * 对象锁实例1 代码块形式
 */
public class SynchronizedObjectCodeBlock2 implements Runnable{
    public void run() {
        synchronized(this){
            try {
            System.out.println("对象锁代码块" + Thread.currentThread().getName() );
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            System.out.println("对象锁代码块" + Thread.currentThread().getName() + "运行结束");
        }
    }
    public static void main(String[] args) {
        SynchronizedObjectCodeBlock2 block2 = new SynchronizedObjectCodeBlock2();
        Thread thread01 = new Thread(block2);
        Thread thread02 = new Thread(block2);

        thread01.start();
        thread02.start();
    }
}
```

```
/**
 *对象锁实例 方法锁
 */
public class SynchronizedObjectMethod implements Runnable {
    public  synchronized void mymethod(){
        System.out.println("对像锁 锁方法" +Thread.currentThread().getName());
        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println(Thread.currentThread().getName() + "执行结束");
    }

    @Override
    public void run(){
        mymethod();
    }
    static SynchronizedObjectMethod smethod = new SynchronizedObjectMethod();

    public static void main(String[] args) {
        Thread thread1 = new Thread(smethod);
        Thread thread2 = new Thread(smethod);
        thread1.start();
        thread2.start();
    }
}

```

- 类锁
    1. 指synchronized修饰静态的方法或指定锁为Class对象
        - 概念(Java类可能会有很多实例对象,但只会有一个Class对象
        所谓类锁本质上就是Class对象的锁而已,类锁只能在同一时刻被一个对象拥有)
        - 形式1: synchronized加在static方法上
  
```
/**
 * 类锁 static形式
 */
public class SynchronizedClassStatic implements Runnable {
    @Override
    public void run(){
        method();
    }

    static SynchronizedClassStatic synchronizedClassStatic1 = new SynchronizedClassStatic();
    static SynchronizedClassStatic synchronizedClassStatic2 = new SynchronizedClassStatic();

    public static synchronized void method(){
        System.out.println("类锁形式1: static形式" + Thread.currentThread().getName());
        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println(Thread.currentThread().getName() + "运行结束!");
    }

    public static void main(String[] args) {
        Thread thread1 = new Thread(synchronizedClassStatic1);
        Thread thread2 = new Thread(synchronizedClassStatic2);
        thread1.start();
        thread2.start();
    }
}
```
- 形式2: synchronized加在(*.class)代码块上

```
/**
 * .class
 */
public class SynchronizedClassClass implements Runnable{
    @Override
    public void run() {
        method();
    }

    private void method(){
        synchronized (SynchronizedClassClass.class){
            System.out.println("synchronized(*.class)" + Thread.currentThread().getName());
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            System.out.println(Thread.currentThread().getName() + "执行结束!");
        }
    }

    static SynchronizedClassClass synchronizedClassClass1 = new SynchronizedClassClass();
    static SynchronizedClassClass synchronizedClassClass2 = new SynchronizedClassClass();

    public static void main(String[] args) {
        Thread thread1 = new Thread(synchronizedClassClass1);
        Thread thread2 = new Thread(synchronizedClassClass2);
        thread1.start();
        thread2.start();
    }
}
```