rgbasm -o example.obj helloWorld.asm
rgblink -mmap example.obj 
rgbfix -v helloWorld 
del *.obj

