# Default target executed when no arguments are given to make.
default_target: all
.PHONY : default_target

CFLAGS += -I ../include
CXXFLAGS += -I ../include

SRCS = abi.cpp
SRCS += main.cpp
SRCS += multiboot_utils.cpp
SRCS += paging.cpp
OBJS = abi.o
OBJS += main.o
OBJS += multiboot_utils.o
OBJS += paging.o

all: kernellib.a
.PHONY: all clean

kernellib.a: $(OBJS)
	$(AR) -crs kernellib.a $(OBJS)

clean:
	rm -f kernellib.a $(OBJS)


$(shell mkdir -p $(DEPDIR) >/dev/null)
%.o : %.c
%.o : %.c $(DEPDIR)/%.d
	$(CC) $(CFLAGS) -MT $@ -MMD -MP -MF $(DEPDIR)/$*.Td -c -o $@ $<
	mv -f $(DEPDIR)/$*.Td $(DEPDIR)/$*.d

%.o : %.cpp
%.o : %.cpp $(DEPDIR)/%.d
	$(CXX) $(CXXFLAGS) -MT $@ -MMD -MP -MF $(DEPDIR)/$*.Td -c -o $@ $<
	mv -f $(DEPDIR)/$*.Td $(DEPDIR)/$*.d

%.o: %.nasm
	$(NASM) $(NASMFLAGS) -o $@ $<

$(DEPDIR)/%.d: ;
.PRECIOUS: $(DEPDIR)/%.d

-include $(patsubst %,$(DEPDIR)/%.d,$(basename $(SRCS)))
