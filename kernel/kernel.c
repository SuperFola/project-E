// must be the first function
void main(void) {
	unsigned char* vga = (unsigned char*) 0xB8000;

	vga[0] = 'X';
	vga[1] = 0x09;  // attribute

	for (;;);  // to make sure the kernel does not stop
}
