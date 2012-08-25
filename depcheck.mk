.depcheck:
	@echo "DEPFILES=\$$(wildcard \$$(addsuffix .d, \$${OBJS}))" >.dep.inc; \
	echo "ifneq (\$${DEPFILES},)" >>.dep.inc; \
	echo "include \$${DEPFILES}" >>.dep.inc; \
	echo "endif" >>.dep.inc;
.dep.inc: .depcheck

include .dep.inc
