.PHONY: all clean run test


%.o: %.asm
	nasm -f elf64 -o $@ $<

SRC := main.asm lib.asm dict.asm 
OBJ := $(SRC:.asm=.o)
EXE := lab_2
TST := test.py

$(EXE): $(OBJ)
	ld -o $@ $^

all:
	$(EXE)

clean:
	rm -f *.o $(EXE)

run: $(EXE)
	./$(EXE)

test:
	python $(TST)
