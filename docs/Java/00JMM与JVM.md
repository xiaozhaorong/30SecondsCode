00 JMM与JVM
--- 
>  Java是运行在虚拟机上面的，这也是为什么Java能跨平台运行的原因，作为Java程序的底层，了解JVM内存结构就显得很重要了。有一个很常见的误解,JVM内存结构与Java内存模型到底指的是不是同一个东西。其实他们不是同一个东西来的。（以下基于JDK1.8）
- JVM内存结构指的是一个规范，规范里面规定了JVM内存结构要有类装载子系统、方法区,Java堆，Java栈、线程计数器、本地方法栈、执行引擎。GC垃圾回收器这些东西。而各个不同JDK则是实现了这些规范，他们的Java内存模型,会有一些不一样。
- 用一张图表示JVM内存结构（图1）
![JVM内存模型](https://note.youdao.com/yws/api/personal/file/680F798F8D244BF58824F588B75E0A83?method=download&shareKey=96ca1c9d907b4e507331ad92921cf7ee)
- 了解基本概念之后可以开始看看主流的Java内存模型是长什么样的用一张图来表示（这张图画了好久 -- 图2）
![image](https://note.youdao.com/yws/api/personal/file/35F90A0122F442EDABC1E2A5B5DFDDE0?method=download&shareKey=b8e71533ca46a2b3904a5cf1cfc3973b)
- 口说无凭 通过一个小例子看看栈是怎么执行的
```
/**
 * 一段简单的代码 一看便知道执行的结果是8
 * 那在虚拟机底层这个 8 是怎么计算出来的呢
 */
public class MyTest0 {
    public static void main(String[] args) {
        sum();
    }
    static void sum() {
        int a = 5;
        int b = 3;
        System.out.println(a + b);
    }
}
```

在当前Java文件的目录下输入 以下指令编译成MyTest0.class文件
> javac MyTest0.java 

这个时候会产生一个MyTest0.class的字节码文件，我们是看不懂的 截取一部分大概长这样子（不同的编码环境下 打开会不一样）
```
漱壕   4 
  
  	  
     <init> ()V Code LineNumberTable main ([Ljava/lang/String;)V sum 
SourceFile 
```
可以使用以下指令对class文件进行反编译，在控制台输出反编译后的代码
> javap -c MyTest0

为了方便编辑 在window环境下使用 以下指令 可以将编译后的代码之间输出到MyTest0.txt
> javap -c MyTest0 > MyTest0.txt

然后用编辑器打开 MyTest0.txt 长这个样子的
好像还是看不懂hh，这个时候告诉自己不要慌，这些东西需要结合Jvm指令集与上面的那张图2 结合起来解析 </br> **PS** （ /--/ 开头的注释是我自己加的说明）

```
Compiled from "MyTest0.java"
public class com.dms.MyTest0 {
  public com.dms.MyTest0();
    Code:
       0: aload_0 
       /--/  调用超类构造方法，实例初始化方法，私有方法 (看这里就能明白为什么，为什么类里面没有构造方法却能new对对象，编译器会自动调用超类构造方法)
       1: invokespecial #1  // Method java/lang/Object."<init>":()V 
       4: return

  public static void main(java.lang.String[]);
    Code:
       0: invokestatic  #2  // Method sum:()V  /--/ 调用静态方法 sum()
       3: return

  static void sum();
    Code:
       0: iconst_5  /--/ 将int型5推送至sum方法栈顶
       1: istore_0  /--/ 将栈顶int型数值存入第一个本地变量(也就是存到sum局部变量表)
       2: iconst_3  /--/ 将int型3推送至sum方法栈顶
       3: istore_1  /--/ 将栈顶int型数值存入第二个本地变量(也就是存到sum局部变量表)
       /--/ 获取指定类的静态域，并将其值压入栈顶
       4: getstatic     #3  // Field java/lang/System.out:Ljava/io/PrintStream;
       7: iload_0   /--/ 将第一个int型本地变量推送至栈顶(也就是把局部变量里的5 推至栈顶)
       8: iload_1   /--/ 将第二个int型本地变量推送至栈顶(也就是把局部变量里的3 推至栈顶)
       9: iadd      /--/ 将栈顶两int型数值相加并将结果压入栈顶 也就是8
      10: invokevirtual #4  // Method java/io/PrintStream.println:(I)V /--/  调用实例方法 也就是调用打印方法把8打印出来
      13: return    /--/ 返回
}
```
基础流程就是图2与以上 /--/ 注释所写的那样子了 自己跟着流程操作一遍可能会更好理解一些，更多的JVM指令集可以参考以下链接，或自行网上搜索
> https://www.cnblogs.com/dreamroute/p/5089513.html

- 图二说过当新new出来的对象很大时该对象会直接进入老年代,直接跑段代码看看是不是真的是这样子的。
```
public class MyTest {
    /**
     * 每个对象有一个1M的属性 使它一创建出来就是一个大对象
     */
    byte[] bytes = new byte[1024 * 1000];

    public static void main(String[] args) throws InterruptedException {
        // 程序刚启动时JVM会有一些初始化的处理,为避免影响实验结果，先睡眠5秒
        Thread.sleep(5000);
        // 为避免垃圾回收机制自动回收没有引用的对象,这里用一个数组先装着，保证对象存活
        List list = new ArrayList<>();
        // 循环添加1000个大对象
        for (int i = 0; i < 1000; i++) {
            System.out.println(i + "开始添加对象===");
            Thread.sleep(100);
            list.add(new MyTest());
        }
        
        System.out.println("开始清理垃圾");
        // 将引用置为空 然后通知JVM回收空对象
        list = null;
        System.gc();
        // 睡眠一会 防止执行垃圾回收前虚拟机就退出了 
        Thread.sleep(10000);
    }
}
```
以上代码的执行结果，心里预期应该是老年代的空间在1000个对象添加完成前一直会保持增长，在添加完一千个对象之后执行垃圾回收，空间又会断崖式的下跌。口说无凭，我们使用个工具观察一下老年代的内存情况。这里使用的工具是JDK带的jconsole
> window环境下使用小黑窗输入jconsole 即可调出来 选择本地进程 选择自己的程序
![image](https://note.youdao.com/yws/api/personal/file/8F59626A076C4BFB9F4A729185BBC882?method=download&shareKey=766de2bbfa33eb92e4d378b9cc1ad5b4)


然后选择内存 内存池"PS Old Gen" 观察老年代的内存变化 可以看到内存曲线变化是符合心理预期的
![image](https://note.youdao.com/yws/api/personal/file/4F1BC047FA94497A81E8D5545FBD7B01?method=download&shareKey=31a3a343d5846a3c60cb7fa9ee49e9e7)