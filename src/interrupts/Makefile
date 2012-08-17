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

store_print_regs.o: store_print_regs.asm
divide_error_exception.o: divide_error_exception.asm store_print_regs.asm
debug_exception.o: debug_exception.asm store_print_regs.asm
nmi_interrupt.o: nmi_interrupt.asm store_print_regs.asm
breakpoint_exception.o: breakpoint_exception.asm store_print_regs.asm
overflow_exception.o: overflow_exception.asm store_print_regs.asm
bound_range_exceeded_exception.o: bound_range_exceeded_exception.asm store_print_regs.asm
invalid_opcode_exception.o: invalid_opcode_exception.asm store_print_regs.asm
device_not_available_exception.o: device_not_available_exception.asm store_print_regs.asm
double_fault_exception.o: double_fault_exception.asm store_print_regs.asm
invalid_tss_exception.o: invalid_tss_exception.asm store_print_regs.asm
segment_not_present_exception.o: segment_not_present_exception.asm store_print_regs.asm
stack_fault_exception.o: stack_fault_exception.asm store_print_regs.asm
general_protection_exception.o: general_protection_exception.asm store_print_regs.asm
page_fault_exception.o: page_fault_exception.asm store_print_regs.asm
x87_fpu_floating_point_error.o: x87_fpu_floating_point_error.asm store_print_regs.asm
alignment_check_exception.o: alignment_check_exception.asm store_print_regs.asm
machine_check_exception.o: machine_check_exception.asm store_print_regs.asm
simd_floating_point_exception.o: simd_floating_point_exception.asm store_print_regs.asm

$(INTERRUPTS_ARCHIVE): $(OBJS)
	$(AR) -cruv $(INTERRUPTS_ARCHIVE) $(OBJS)
	$(RANLIB) $(INTERRUPTS_ARCHIVE)

clean:
	rm -frv $(OBJS) $(INTERRUPTS_ARCHIVE)

