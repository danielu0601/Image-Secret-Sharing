CC   = g++
FLAG = -O2 -Wall -std=c++11
FLAG += -I/usr/local/Cellar/opencv/3.4.1_5/include/
FLAG += -L/usr/local/Cellar/opencv/3.4.1_5/lib/
FLAG += 'pkg-config --cflags --libs opencv'
exe  = main
obj  = main.o

all:$(obj)
	$(CC) $(obj) $(FLAG) -o $(exe)
%.o:%.c
	$(CC) -c $^ -o $@

.PHONY:clean run
clean:
	rm $(obj)
run:
	g++ main.cpp Encrypt_P_D.cpp -o main -std=c++11 `pkg-config --cflags --libs opencv`
	./main
