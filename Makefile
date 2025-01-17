# ==========================================
#   Unity Project - A Test Framework for C
#   Copyright (c) 2007 Mike Karlesky, Mark VanderVoord, Greg Williams
#   [Released under MIT License. Please refer to license.txt for details]
# ===========================================

#We try to detect the OS we are running on, and adjust commands as needed
ifeq ($(OS),Windows_NT)
  ifeq ($(shell uname -s),) # not in a bash-like shell
	CLEANUP = del /F /Q
	MKDIR = mkdir
  else # in a bash-like shell, like msys
	CLEANUP = rm -f
	MKDIR = mkdir -p
  endif
	TARGET_EXTENSION=.exe
else
	CLEANUP = rm -f
	MKDIR = mkdir -p
	TARGET_EXTENSION=.out
endif

C_COMPILER=gcc
ifeq ($(shell uname -s), Darwin)
C_COMPILER=clang
endif

UNITY_ROOT=../..

CFLAGS=-std=c99
CFLAGS += -Wall
CFLAGS += -Wextra
CFLAGS += -Wpointer-arith
CFLAGS += -Wcast-align
CFLAGS += -Wwrite-strings
CFLAGS += -Wswitch-default
CFLAGS += -Wunreachable-code
CFLAGS += -Winit-self
CFLAGS += -Wmissing-field-initializers
CFLAGS += -Wno-unknown-pragmas
CFLAGS += -Wstrict-prototypes
CFLAGS += -Wundef
CFLAGS += -Wold-style-definition
CFLAGS += -fprofile-arcs -ftest-coverage 

TARGET_BASE1=meus_testes
TARGET1 = $(TARGET_BASE1)$(TARGET_EXTENSION)
SRC_FILES1=\
  src/unity.c \
  extras/fixture/src/unity_fixture.c \
  src/foo.c \
  src/TestFoo.c \
  src/TestFoo_Runner.c \
  src/all_tests.c
INC_DIRS=-Isrc -I$(UNITY_ROOT)/src -I$(UNITY_ROOT)/extras/fixture/src
SYMBOLS=

unity: clean compile run

compile:
	$(C_COMPILER) $(CFLAGS) $(INC_DIRS) $(SYMBOLS) $(SRC_FILES1) -o $(TARGET1)
	
cppcheck:
	cppcheck --enable=all --suppress=missingIncludeSystem $(SRC_FILES1)
	
valgrind:
	gcc -g -Wall -Wfatal-errors $(SRC_FILES1) -o $(TARGET1)
	valgrind --leak-check=full --show-leak-kinds=all ./$(TARGET1)
	
sanitizer:
	clang -g -Wall -Wfatal-errors -fsanitize=address $(SRC_FILES1) -o $(TARGET1)
	./$(TARGET1)
	
gcov: compile run
	gcov -b foo.c

run:
	./$(TARGET1) -v

clean:
	$(CLEANUP) $(TARGET1)

ci: CFLAGS += -Werror
ci: compile
