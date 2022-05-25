all: img-builder

img-builder: main.cpp image_builder.cpp
	gcc -o $@ $<

clean:
	rm -f img-builder