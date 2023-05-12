@echo off

:call C:\msys64\msys2_shell.cmd -where %cd% -mingw64 -c "gcc -c test.c && gcc test.o -o test.exe"

:gcc -w -Wl,-subsystem,console -lmingw32 test.c

:zig cc -c test.c && zig cc test.obj -o test.exe

:zig build-exe -O ReleaseSafe main.zig --subsystem console

:zig build-exe -fstrip -Ih -Llib -lc -lopengl32 -lsqlite3 -lglfw3dll test.c && zig build-exe -fstrip -Ih -Llib -lc -lopengl32 -lsqlite3 -lglfw3dll main.zig && del main.exe.obj

zig build-exe -fstrip -Ih -Llib -lc -lopengl32 -lsqlite3 main.zig && del main.exe.obj
