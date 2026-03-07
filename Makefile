CC = shc
BIN_PATH := $(HOME)/.local/bin

all: binx cleanup

binx: bin
	$(CC) -f bin -o binx

cleanup:
	rm -rf bin.x.c

install: binx
	mv ./binx $(BIN_PATH)

uninstall:
	rm -rf $(BIN_PATH)/binx

clean:
	rm -rf binx bin.x.c

