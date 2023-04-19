# FlameGraphs-Instruments

[中文版](README.zh.md)

FlameGraphs-Instruments is a command-line tool that generates interactive SVG flame graphs based on Xcode Instruments traces files.

This project was created after researching the source code of two flame graph implementations.

### [FlameGraph](https://github.com/brendangregg/FlameGraph)

Author of "Systems Performance," Brendan Gregg proposed [Flame Graphs](https://www.brendangregg.com/flamegraphs.html) which uses interactive SVG format. The downside is that stackcollapse-instruments.pl has not been updated for several years, and the latest traces format cannot be parsed.

### [FlameGraph-Swift](https://github.com/lennet/FlameGraph)

Implemented in Swift, it mainly parses CSV format data and generates flame graphs in PNG, JPG, PDF, and HTML formats. It is simple and easy to use, but the generated format is not interactive and cannot view deeper stack levels. When the stack level is too high, the text display is incomplete.

Combining the advantages of the above two projects, FlameGraphs-Instruments has made the following optimizations:

1. Supports Instruments traces parsing.
2. Outputs interactive SVG format, supporting click and level view.
3. Supports parsing `CPU Profiler` and `Time Profiler`.
4. Filters stacks with a 0.0% Weight.

[![Example](https://github.com/Kelvenbit/FlameGraphs-Instruments/blob/main/example/output.svg)](https://github.com/Kelvenbit/FlameGraphs-Instruments/blob/main/example/output.svg)

## Installation

### Swift Package Manager

$ git clone git@github.com:Kelvenbit/FlameGraphs-Instruments.git

## Usage

1. Run Instruments and select `Time Profiler` or `CPU Profiler`.
2. Select the stack.
3. Use the menu `Edit > Deep copy ⇧⌘C` to copy the full stack to the clipboard.
4. Enter the directory `cd FlameGraphs-Instruments`.
5. Execute `swift run FlameGraph output.svg` or `swift run FlameGraph -f intput.csv output.svg`.

## License

FlameGraphs-Instruments is licensed under the MIT License. See the LICENSE file for details.
