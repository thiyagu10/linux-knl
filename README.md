# Linux Kernel Compilation

Kernel Build Tools/Packages	description

* **build-essential**
		- Installs development tools such as gcc, and g++ for compiling C and C++ programs.
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


**Linux Kernel Build Tool Chains**
----------------------------------

* **Linux distribution**	– An operating system made as a collection of software based on the Linux kernel and, often, a package management system
* **OpenEmbedded**		– A software framework for creating Linux distributions tailored for embedded devices
* **uClibc**			– A small C standard library intended for Linux-based embedded systems
* **Yocto Project**		– A Linux Foundation workgroup focusing on architecture-independent embedded Linux distributions
* **BusyBox**			– A software project that provides several stripped-down Unix tools in a single executable file


**Run the built Kernel and INITRAMFS using KVM/QEMU Hypervisor**

qemu-system-x86_64 -nographic -no-reboot -kernel vmlinuz-6.0.2-generic -m 256 -initrd initramfs-6.0.2-generic -drive file=l17nos-disk01.img,format=raw -append "root=/dev/sda panic=10 console=ttyS0,115200 tsc=unstable"

virt-filesystems -a /opt/l17-netos/l17netos-1-0_x86-64.qcow2 -l
virt-filesystems -a /opt/l17-netos/l17netos-1-0_x86-64.img -l
qemu-img info /opt/l17-netos/l17netos-1-0_x86-64.qcow2
