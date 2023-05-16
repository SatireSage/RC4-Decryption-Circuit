# RC4-Decryption-Circuit

Authors:
[Sahaj Singh](https://github.com/SatireSage), [Bryce Leung](https://github.com/Bryce-Leung)

This repository contains the code for a fully implemented RC4 Decryption Circuit using FPGA. The circuit is designed and implemented on the DE2 board. The main goal of this project is to study digital circuits that make extensive use of on-chip memory and to implement RC4 decryption and cracking circuits.

## Table of Contents

- [Overview](#overview)
- [Requirements](#requirements)
- [Usage](#usage)
- [Implemented Tasks](#implemented-tasks)
  - [Task 1: Memory Creation and Writing](#task-1-memory-creation-and-writing)
  - [Task 2: Single Decryption Core](#task-2-single-decryption-core)
  - [Task 3: RC4 Cracking](#task-3-rc4-cracking)
  - [Challenge Task: Multi-Core Cracking](#challenge-task-multi-core-cracking)
  - [Bonus Task: LCD Display of Decoded Message](#bonus-task-lcd-display-of-decoded-message)

## Overview

The RC4 Decryption Circuit is divided into three main tasks and two additional tasks. All tasks have been implemented and completed in this repository. The implemented tasks include creating a memory, instantiating it, and writing to it; building a single decryption core; implementing a brute-force cracking algorithm for RC4 decryption; accelerating the keyspace search by using multiple instantiations of the decryption circuit (core); and displaying the decoded message on an LCD.

## Requirements

- Quartus Prime Lite Edition
- DE2 Board

## Usage

1. Clone the repository

<pre><div class="bg-black rounded-md mb-4"><div class="flex items-center relative text-gray-200 bg-gray-800 px-4 py-2 text-xs font-sans justify-between rounded-t-md"><span>bash</span><button class="flex ml-auto gap-2"><svg stroke="currentColor" fill="none" stroke-width="2" viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round" class="h-4 w-4" height="1em" width="1em" xmlns="http://www.w3.org/2000/svg"><path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"></path><rect x="8" y="2" width="8" height="4" rx="1" ry="1"></rect></svg>Copy code</button></div><div class="p-4 overflow-y-auto"><code class="!whitespace-pre hljs language-bash">git clone https://github.com/username/RC4-Decryption-Circuit.git
</code></div></div></pre>

2. Open the Quartus Prime Lite Edition and open the project file.
3. Compile the design and load it into the DE2 board.
4. Run the implemented tasks as described below.

## Implemented Tasks

### Task 1: Memory Creation and Writing

In this task, a RAM is created using the Wizard in the IP Catalog, circuitry is created to fill the memory, and the memory contents are observed using the In-System Memory Content Editor.

### Task 2: Single Decryption Core

In this task, a single decryption core is implemented. Given a 24-bit key and an encrypted message in a ROM, the algorithm decrypts the message and stores the result in another memory.

### Task 3: RC4 Cracking

In this task, the design from Task 2 is modified to "crack" a message that has been encrypted using RC4. A brute-force algorithm is implemented that cycles through all possible keys.

### Challenge Task: Multi-Core Cracking

In this task, the keyspace search is accelerated by using multiple instantiations of the decryption circuit (core) and searching a subset of the keyspace simultaneously.

### Bonus Task: LCD Display of Decoded Message

In this task, the decoded message is displayed on an LCD, reusing an LCD driver core from a previous lab. This makes debugging easier for both Task 2b and Task 3.
