- 获取两个日期相差的天数
```
    //参数格式 2020-11-11 获取两个日期相差的天数
    differDay(start, end) {
      console.log(start, end)
      return (Date.parse(start) - Date.parse(end)) / (24 * 3600 * 1000)
    },
```