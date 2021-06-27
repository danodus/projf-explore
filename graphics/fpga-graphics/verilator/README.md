# FPGA Graphics Verilator SDL Simulations

This folder contains Verilator simulations to accompany the Project F blog post: **[FPGA Graphics](https://projectf.io/posts/fpga-graphics/)**. There are separate instructions for building _FPGA Graphics_ for [FPGA dev boards](../README.md) (iCEBreaker and Arty).

If you're new to graphics simulations check out **[Verilog Simulation with Verilator and SDL](https://projectf.io/posts/verilog-sim-verilator-sdl/)**.

[Verilator](https://www.veripool.org/verilator/) creates C++ simulations of Verilog designs, while [SDL](https://www.libsdl.org) produces simple cross-platform graphics applications. By combining the two, you can simulate your design without needing an FPGA. Verilator is fast, but it's still much slower than an FPGA. For these single-threaded designs, you can expect around one frame per second on a modern PC.

![](../../../doc/img/top-bounce-verilator-sdl.png?raw=true "")

## Build & Run

If this is the first time you've used Verilator and SDL, you need to [install dependencies](#installing-dependencies)!

Then navigate to the Verilator directory:

```bash
cd projf-explore/graphics/fpga-graphics/verilator
```

### Top Square

```bash
verilator -I../ -cc top_square.sv --exe main_square.cpp -LDFLAGS "`sdl2-config --libs`"
make -C ./obj_dir -f Vtop_square.mk
./obj_dir/Vtop_square
```

### Top Beam

```bash
verilator -I../ -cc top_beam.sv --exe main_beam.cpp -LDFLAGS "`sdl2-config --libs`"
make -C ./obj_dir -f Vtop_beam.mk
./obj_dir/Vtop_beam
```

### Top Bounce

```bash
verilator -I../ -cc top_bounce.sv --exe main_bounce.cpp -LDFLAGS "`sdl2-config --libs`"
make -C ./obj_dir -f Vtop_bounce.mk
./obj_dir/Vtop_bounce
```

## Installing Dependencies

To build the simulations, you need:

1. C++ Toolchain
2. Verilator
3. SDL

The simulations should work on any modern platform, but I've confined my instructions to Linux and macOS. Windows installation depends on your choice of compiler, but the sims should work fine there too. For advice on SDL development on Windows, see [Lazy Foo' - Setting up SDL on Windows](https://lazyfoo.net/tutorials/SDL/01_hello_SDL/windows/index.php).

### Linux

For Debian and Ubuntu-based distros, you can use the following. Other distros will be similar.

Install a C++ toolchain via 'build-essential':

```bash
apt update
apt install build-essential
```

Install packages for Verilator and the dev version of SDL:

```bash
apt update
apt install verilator libsdl2-dev
```

That's it!

_If you want to build the latest version of Verilator yourself, see [Building Verilator for Linux](https://projectf.io/posts/building-ice40-fpga-toolchain/#verilator)._

### macOS

Install [Xcode](https://developer.apple.com/xcode/) to get a C++ toolchain.

Install the [Homebrew](https://brew.sh/) package manager.

With Homebrew installed, you can run:

```bash
brew install verilator sdl2
```

And you're ready to go.