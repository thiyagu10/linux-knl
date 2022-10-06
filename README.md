# Linux Kernel Compilation

Kernel Build Tools/Packages	description

* **build-essential**
		- Installs development tools such as gcc, and g++ for compiling C and C++
* **ncurses-dev**
		- Programming library that provides API for the text-based terminals.
* **xz-utils**
		- Provides fast file compression and decompression.
* **libssl-dev**
		- Supports SSL and TSL that encrypt data and make the internet connection secure.
* **bc(Basic Calculator)**
		- A mathematical scripting language that supports the interactive execution of statements.
* **flex**
		- Generates lexical analyzers that convert characters into tokens. (Fast Lexical Analyzer Generator)	
* **libelf-dev**
		- Issues a shared library for managing ELF files (executable files, core dumps and object code)
* **bison**
		- GNU parser generator that converts grammar description to a C program


**Run the built Kernel and INITRAMFS using KVM/QEMU Hypervisor**

qemu-system-x86_64  -nographic -no-reboot -kernel vmlinuz-6.0-generic -m 256 -initrd initramfs-6.0-generic \
					-append "root=/dev/sda panic=10 console=ttyS0,115200 tsc=unstable"
