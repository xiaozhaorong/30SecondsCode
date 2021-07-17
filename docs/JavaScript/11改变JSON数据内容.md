改变JSON数据内容
---
```
let user = {
    id:"1",
    name:"小白"
}
let json = JSON.stringify(user)
console.log(json)
let obj = JSON.parse(json,(key,value)=>{
    if(key === "id"){
        value += "Vip " + value
    }
    return value
})
console.log(JSON.stringify(obj))
```