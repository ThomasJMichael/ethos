ASM=nasm

SRC_DIR=src
BUILD_DIR=build

$(BUILD_DIR)/bootloader_floppy.img: $(BUILD_DIR)/bootloader.bin
	cp $(BUILD_DIR)/bootloader.bin $(BUILD_DIR)/bootloader_floppy.img
	truncate -s 1440k $(BUILD_DIR)/bootloader_floppy.img

$(BUILD_DIR)/bootloader.bin: $(SRC_DIR)/bootloader.asm 
	$(ASM) $(SRC_DIR)/bootloader.asm -f bin -o $(BUILD_DIR)/bootloader.bin