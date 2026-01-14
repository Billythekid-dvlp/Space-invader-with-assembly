# Project Structure
# Part 1: Foundations (partie1.s)

# Objective: Basic timing and system calls

    Counts 1-10 with 500ms delays

    Demonstrates ecall usage for I/O and timing

    Simple loop control with branch instructions

# Part 2: Input Handling (partie2.s)

# Objective: Keyboard input processing

    Real-time keyboard polling

    Three-key control system:

        i = decrement counter

        p = increment counter

        o = quit program

    Memory-mapped I/O (addresses 0xffff0000-0xffff0004)

# Part 3: Graphics System (partie3.s)

# Objective: Bitmap display programming

    32×32 pixel coordinate system

    Core graphics functions:

        plot_pixel() - Draw single pixel

        rectangle() - Draw filled rectangle

        effacer_ecran() - Clear screen

    Basic color palette (black, red)

# Part 3 Extended (partie3_partie2.s)

" Objective: Advanced graphics with double buffering

    256×256 display resolution

    Double buffering system:

        I_buff (drawing buffer)

        I_visu (display buffer)

    Enhanced color palette (6 colors)

    Smooth animation demonstration

# Part 4: Game Scene (partie4.s)

# Objective: Static game scene creation

    Player spaceship: 4×2 green rectangle at bottom

    Invaders: 24 red enemies in 3×8 formation

    Defense barriers: 4 cyan obstacles

    Complete scene rendering

# Part 5: Complete Game (partie5.s)

# Objective: Fully interactive gameplay

    Game loop running at 10 FPS

    Player controls:

        i = move left

        p = move right

        ESC = quit

    Smooth movement with old-position erasing

    Game state management

# Technical Specifications
    Memory Map
    Address	Purpose
    0x10010000	Bitmap Display (32×32×4 bytes)
    0xffff0000	Keyboard Control Register
    0xffff0004	Keyboard Data Register
    Stack	Local variables & return addresses
    Display Configuration

    Resolution: 32×32 pixels (Part 3-5) or 256×256 (Part 3 extended)

    Color Format: 32-bit ARGB (0xAARRGGBB)

    Pixel Layout: Row-major order

# Performance

    Frame Rate: 10 FPS (100ms per frame)

    Input Latency: ≤100ms

    Memory Usage: ~4KB for display buffers

# Installation & Execution
# Requirements

    RARS 1.6 - RISC-V Assembler and Runtime Simulator

# Setup Instructions

    Launch RARS 1.6

    Load assembly file:

        File → Open → Select .s file

    Configure I/O:

        Tools → Bitmap Display

            Unit width/height: 8

            Display width/height: 256

            Base address: 0x10010000

        Tools → Keyboard and Display MMIO Simulator

    Assemble & Run:

        Assemble (F3)

        Run → Go (F5)

# Running Different Parts

    Part 1-2: Console-only, no display setup needed

    Part 3-5: Requires bitmap display configuration

    Interactive parts (2,5): Use keyboard simulator for input

# Controls
    Key	Function
    i	Move left / Decrement
    p	Move right / Increment
    o	Quit (Part 2)
    ESC	Quit game (Part 5)
