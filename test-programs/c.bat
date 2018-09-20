rgbasm -oexample.obj helloWorld.asm
rgblink -mmap helloWorld.lnk
rgbfix -v helloWorld 
del *.obj

