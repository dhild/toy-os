COMPRESS=xz -zfk
DECOMPRESS=xz -dfk

all:
	make -C src

hd.img: hd.img.xz
	$(DECOMPRESS) hd.img.xz

fd.img: fd.img.xz
	$(DECOMPRESS) fd.img.xz

run: all hd.img fd.img
	mkdir -p hd
	sudo mount -o loop hd.img hd

close:
	sudo umount hd
	rmdir hd

compress: close
	$(COMPRESS) hd.img
	$(COMPRESS) fd.img

clean: compress
	make -C src clean
	rm -f hd hd.img fd.img

