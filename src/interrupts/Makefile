include $(BASEMAKE)

OBJS = \
	store_print_regs.o \
	divide_error_exception.o \
	debug_exception.o \
	nmi_interrupt.o \
	breakpoint_exception.o \
	overflow_exception.o \
	bound_range_exceeded_exception.o \
	invalid_opcode_exception.o \
	device_not_available_exception.o \
	double_fault_exception.o \
	invalid_tss_exception.o \
	segment_not_present_exception.o \
	stack_fault_exception.o \
	general_protection_exception.o \
	page_fault_exception.o \
	x87_fpu_floating_point_error.o \
	alignment_check_exception.o \
	machine_check_exception.o \
	simd_floating_point_exception.o

INTERRUPTS_ARCHIVE = interrupts.a

all: $(INTERRUPTS_ARCHIVE)

$(INTERRUPTS_ARCHIVE): $(OBJS)
	$(AR) -cruv $(INTERRUPTS_ARCHIVE) $(OBJS)
	$(RANLIB) $(INTERRUPTS_ARCHIVE)

clean:
	rm -frv $(OBJS) $(INTERRUPTS_ARCHIVE)

include $(DEPCHECK)
