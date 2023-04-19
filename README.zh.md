# FlameGraphs-Instruments


FlameGraphs-Instruments是一个基于Xcode Instruments traces文件生成可交互svg火焰图的命令行工具

调研了两个火焰图实现的源码。


### [FlameGraph](https://github.com/brendangregg/FlameGraph)



《性能之巅》的作者， Brendan Gregg 提出的[Flame Graphs](https://www.brendangregg.com/flamegraphs.html) 使用可交互的svg格式。
缺点是 stackcollapse-instruments.pl 已经多年没有更新，最新traces格式已无法解析。


### [FlameGraph-Swift](https://github.com/lennet/FlameGraph)



使用Swift实现，主要功能解析csv格式数据，并生成png、jpg、pdf、html格式火焰图，简单易用，缺点是生成的格式无法交互并查看更深层的堆栈，堆栈层级过高文字展示不全。


融合以上两个项目的优点，FlameGraphs-Instruments做了以下优化
1. 支持Instruments traces解析.
2. 输出可交互svg格式，支持点击，层级查看.
3. 支持解析`CPU Profiler`、 `Time Profiler`.
4. 过滤Weight占比0.0%堆栈.


[![图例](https://github.com/Kelvenbit/FlameGraphs-Instruments/blob/main/example/output.svg)](https://github.com/Kelvenbit/FlameGraphs-Instruments/blob/main/example/output.svg)



## 安装


### Swift Package Manager
```
$ git clone git@github.com:Kelvenbit/FlameGraphs-Instruments.git
```

## 使用方法

1. 运行Instruments并选择`Time Profiler` 或者`CPU Profiler`
2. 选中堆栈
3. 菜单 `Edit > Deep copy ⇧⌘C` 复制完整堆栈到剪切板 
4. 进入目录     `cd FlameGraphs-Instruments`
5. 执行 `swift run FlameGraph output.svg` 或者 `swift run FlameGraph -f intput.csv output.svg`




## 许可证 

FlameGraphs-Instruments 使用 MIT 许可证，详情见 LICENSE 文件。
