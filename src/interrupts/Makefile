include $(TOS_BASEMAKE)

OBJS := store_print_regs.o
OBJS += divide_error_exception.o
OBJS += debug_exception.o
OBJS += nmi_interrupt.o
OBJS += breakpoint_exception.o
OBJS += overflow_exception.o
OBJS += bound_range_exceeded_exception.o
OBJS += invalid_opcode_exception.o
OBJS += device_not_available_exception.o
OBJS += double_fault_exception.o
OBJS += invalid_tss_exception.o
OBJS += segment_not_present_exception.o
OBJS += stack_fault_exception.o
OBJS += general_protection_exception.o
OBJS += page_fault_exception.o
OBJS += x87_fpu_floating_point_error.o
OBJS += alignment_check_exception.o
OBJS += machine_check_exception.o
OBJS += simd_floating_point_exception.o

INTERRUPTS_ARCHIVE = interrupts.a

all: $(INTERRUPTS_ARCHIVE)

$(INTERRUPTS_ARCHIVE): $(OBJS)
	$(TOS_AR) -cruv $(INTERRUPTS_ARCHIVE) $(OBJS)
	$(TOS_RANLIB) $(INTERRUPTS_ARCHIVE)

clean:
	rm -fr $(OBJS) $(INTERRUPTS_ARCHIVE)

