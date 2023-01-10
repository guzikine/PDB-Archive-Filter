# This is a GNU-make file made for
# automatic testing to validate the
# pdb_file_statistics script.

MAKEFLAGS = -r

.PHONY: all display

SCRIPT_DIR = \.

all:

display:
	@echo ${${VAR}}

# Declaring variables.
TEST_DIR = tests

TEST_CASE_DIR = ${TEST_DIR}/cases
TEST_DIFF_DIR = ${TEST_DIR}/outputs
TEST_OUTP_DIR = ${TEST_DIR}/outputs

TEST_CASE_PDB_INPUTS = $(wildcard ${TEST_CASE_DIR}/*.pdb)
TEST_CASE_CIF_INPUTS = $(wildcard ${TEST_CASE_DIR}/*.cif)
TEST_CASE_DIR_INPUTS = $(wildcard ${TEST_CASE_DIR}/*.dir)

TEST_CIF_OUTPS =\
	$(sort $(TEST_CASE_CIF_INPUTS:${TEST_CASE_DIR}/%.cif=\
	$(TEST_OUTP_DIR)/%.cifout))
TEST_PDB_OUTPS =\
	$(sort $(TEST_CASE_PDB_INPUTS:${TEST_CASE_DIR}/%.pdb=\
	$(TEST_OUTP_DIR)/%.pdbout))
TEST_DIR_OUTPS =\
	$(sort $(TEST_CASE_DIR_INPUTS:${TEST_CASE_DIR}/%.dir=\
	$(TEST_OUTP_DIR)/%.dirout))

TEST_CIF_DIFFS =\
	$(sort $(TEST_CASE_CIF_INPUTS:${TEST_CASE_DIR}/%.cif=\
	$(TEST_DIFF_DIR)/%.cifdiff))
TEST_PDB_DIFFS =\
	$(sort $(TEST_CASE_PDB_INPUTS:${TEST_CASE_DIR}/%.pdb=\
	$(TEST_DIFF_DIR)/%.pdbdiff))
TEST_DIR_DIFFS =\
	$(sort $(TEST_CASE_DIR_INPUTS:${TEST_CASE_DIR}/%.dir=\
	$(TEST_DIFF_DIR)/%.dirdiff))

# Section for test dependencies.

TEST_DEPENDENCIES = .test_depend

include ${TEST_DEPENDENCIES}

${TEST_DEPENDENCIES}: .pdb_depend .cif_depend .dir_depend
	@cat $^ > $@

.pdb_depend: ${TEST_CASE_PDB_INPUTS}
	@find tests/cases/ -name "*.pdb" \
	| sed 's|/cases/|outputs/|; s|\.pdb$$|\.pdbdiff|' \
	| awk '{ \
		pgm = $$1; \
		sub("${TEST_OUTP_DIR}/","",pgm); \
		sub("_[0-9]*[a-z]\..*$$","",pgm); \
		print $$1 ": " "${SCRIPT_DIR}/"pgm".pl" \
		}' \
	| sort\
	> $@

.cif_depend: ${TEST_CASE_CIF_INPUTS}
	@find tests/cases/ -name "*.cif" \
	| sed 's|/cases/|outputs/|; s|\.cif$$|\.cifdiff|' \
	| awk '{ \
		pgm = $$1; \
		sub("${TEST_OUTP_DIR}/","",pgm); \
		sub("_[0-9]*[a-z]\..*$$","",pgm); \
		print $$1 ": " "${SCRIPT_DIR}/"pgm".pl" \
		}' \
	| sort \
	> $@

.dir_depend: ${TEST_CASE_DIR_INPUTS}
	@find tests/cases/ -name "*.dir" \
	| sed 's|/cases/|outputs/|; s|\.dir$$|\.dirdiff|' \
	| awk '{ \
		pgm = $$1; \
		sub("${TEST_OUTP_DIR}/","",pgm); \
		sub("_[0-9]*[a-z]\..*$$","",pgm); \
		print $$1 ": " "${SCRIPT_DIR}/"pgm".pl" \
		}' \
	| sort \
	> $@


# Make targets with dependencies and recipes.
# Because there are 3 possible ways of parsing
# files into this program, there will be three
# kinds of tests for each type of given
# file format: directory, PDB and CIF files.
.PHONY: test test_cif test_pdb test_dir

test: test_cif test_pdb test_dir


test_cif: ${TEST_CIF_OUTPS} ${TEST_CIF_DIFFS}

test_pdb: ${TEST_PDB_OUTPS} ${TEST_PDB_DIFFS}

test_dir: ${TEST_DIR_OUTPS} ${TEST_DIR_DIFFS}


# Generating output files with the .cifout,
# .pdbout and .dirout extensions.
${TEST_OUTP_DIR}/%.cifout:
	@${SCRIPT_DIR}/$(shell echo $* | sed 's/\(.*\)_[0-9]*[a-z]/\1\.pl/') \
	$(shell echo -cif) ${TEST_CASE_DIR}/$*.cif > $@

${TEST_OUTP_DIR}/%.pdbout:
	@${SCRIPT_DIR}/$(shell echo $* | sed 's/\(.*\)_[0-9]*[a-z]/\1\.pl/') \
	$(shell echo -pdb) ${TEST_CASE_DIR}/$*.pdb > $@

${TEST_OUTP_DIR}/%.dirout:
	@${SCRIPT_DIR}/$(shell echo $* | sed 's/\(.*\)_[0-9]*[a-z]/\1\.pl/') \
	$(shell echo -d -pdb) ${TEST_CASE_DIR}/$*.dir > $@


# Generating diff files.
${TEST_DIFF_DIR}/%.cifdiff: ${TEST_CASE_DIR}/%.cif ${TEST_OUTP_DIR}/%.cifout
	@echo -n $*": "
	@${SCRIPT_DIR}/$(shell echo $* | sed 's/\(.*\)_[0-9]*[a-z]/\1\.pl/') \
	$(shell echo -cif) $< 2>&1 | diff - $(word 2, $^) > $@; \
	if [ $$? -eq 0 ]; then echo "OK"; else echo "FAILED"; cat $@; fi

${TEST_DIFF_DIR}/%.pdbdiff: ${TEST_CASE_DIR}/%.pdb ${TEST_OUTP_DIR}/%.pdbout
	@echo -n $*": "
	@${SCRIPT_DIR}/$(shell echo $* | sed 's/\(.*\)_[0-9]*[a-z]/\1\.pl/') \
	$(shell echo -pdb) $< 2>&1 | diff - $(word 2, $^) > $@; \
	if [ $$? -eq 0 ]; then echo "OK"; else echo "FAILED"; cat $@; fi

${TEST_DIFF_DIR}/%.dirdiff: ${TEST_CASE_DIR}/%.dir ${TEST_OUTP_DIR}/%.dirout
	@echo -n $*": "
	@${SCRIPT_DIR}/$(shell echo $* | sed 's/\(.*\)_[0-9]*[a-z]/\1\.pl/') \
	$(shell echo -d -pdb) $(shell FILE=`readlink -f $<`; echo $$FILE) 2>&1 \
	| diff - $(word 2, $^) > $@; \
	if [ $$? -eq 0 ]; then echo "OK"; else echo "FAILED"; cat $@; fi

.PHONY: clean-tests

clean-tests:
	rm -f ${TEST_CIF_DIFFS}
	rm -f ${TEST_PDB_DIFFS}
	rm -f ${TEST_DIR_DIFFS}
	rm -f ${TEST_CIF_OUTPS}
	rm -f ${TEST_PDB_OUTPS}
	rm -f ${TEST_DIR_OUTPS}
