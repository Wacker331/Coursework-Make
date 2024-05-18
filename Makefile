TARGET = MakeLanguage
LEX_SOURCE = src/lexer.l
LEX_PRECOMPILED = build/lex.yy.c
MAIN_SOURCE = src/main.c
BISON_SOURCE = src/MakeLanguage.y
BISON_PRECOMPILED = build/MakeLanguage.c
CCFLAGS = 

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(MAIN_SOURCE) MakeFile $(LEX_PRECOMPILED) $(BISON_PRECOMPILED)
	gcc $(MAIN_SOURCE) $(LEX_PRECOMPILED) $(BISON_PRECOMPILED) -o $(TARGET) $(CCFLAGS)

$(BISON_PRECOMPILED): $(BISON_SOURCE)
	bison -d $(BISON_SOURCE) -o $(BISON_PRECOMPILED)

$(LEX_PRECOMPILED): $(LEX_SOURCE)
	cd build; flex ../$(LEX_SOURCE);

MakeFile:

clean:
	rm build/*
	rm $(TARGET)