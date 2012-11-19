.depcheck:
	@echo "DEPFILES=\$$(wildcard \$$(addsuffix .d, \$${OBJS}))" >.dep.inc; \
	echo "ifneq (\$${DEPFILES},)" >>.dep.inc; \
	echo "include \$${DEPFILES}" >>.dep.inc; \
	echo "endif" >>.dep.inc;
.dep.inc: .depcheck

clean: .depclean
.depclean:
	rm -fr .dep.inc $(wildcard $(addsuffix .d, ${OBJS}))

ifneq ($(wildcard .dep.inc),)
include .dep.inc
endif

