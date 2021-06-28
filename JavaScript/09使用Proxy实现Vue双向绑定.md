使用Proxy 手写实现Vue双向绑定
---
```
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>

<body>
    <input type="text" v-model="title" />
    <div v-bind="title"></div>
    <hr>
    <input type="text" v-model="title2" />
    <div v-bind="title2"></div>
    <script>
        function View() {
            //设置代理拦截 传入两个参数 1 target 被代理的对象 2 handler 被代理对象上的自定义行为
            let proxy = new Proxy(
                {},
                {
                    get(obj, property) { },
                    // obj = {} , property = title, value = input输入的值
                    set(obj, property, value) {
                        obj[property] = value;
                        document
                            .querySelectorAll(
                                `[v-model="${property}"],[v-bind="${property}"]`
                            )
                            .forEach(el => {
                                el.innerHTML = value;
                                el.value = value;
                            });
                    }
                }
            );
            //初始化绑定元素事件
            this.run = function () {
                // 查询包含v-model属性的元素
                const els = document.querySelectorAll("[v-model]");
                els.forEach(item => {
                    // 给元素绑定键盘抬起事件
                    item.addEventListener("keyup", function () {
                        // 代理属性值 即title 
                        proxy[this.getAttribute("v-model")] = this.value;
                    });
                });
            };
        }
        let view = new View().run();
    </script>
</body>


</html>
```