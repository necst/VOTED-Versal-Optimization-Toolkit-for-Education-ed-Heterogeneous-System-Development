# MIT License
# Copyright (c) 2024 Paolo Salvatore Galfano, Giuseppe Sorrentino
# Updates Davide Conficconi
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

.PHONY: help build_hw build_sw testbench_all pack build_and_pack clean clean_aie clean_FPGA clean_hw clean_sw

help:
	@echo "Makefile Usage:"
	@echo "  make build_hw [TARGET=hw_emu] SHELL_NAME=<qdma|xdma>"
	@echo ""
	@echo "  make build_sw SHELL_NAME=<qdma|xdma>"
	@echo ""
	@echo "  make clean"
	@echo ""

TARGET := hw
SHELL_NAME := null
PLATFORM := null

ifeq ($(SHELL_NAME), qdma)
	PLATFORM := xilinx_vck5000_gen4x8_qdma_2_202220_1
else ifeq ($(SHELL_NAME), xdma)
	PLATFORM := xilinx_vck5000_gen4x8_xdma_2_202210_1
endif

test:
	@echo "TARGET: $(TARGET)"
	@echo "SHELL_NAME: $(SHELL_NAME)"
	@echo "PLATFORM: $(PLATFORM)"

#
## Build hardware (xclbin) objects
build_hw: compile_fpga compile_aie hw_link
#
compile_aie:
	@make -C ./aie aie_compile SHELL_NAME=$(SHELL_NAME)
#
compile_fpga:
	@make -C ./fpga compile TARGET=$(TARGET) PLATFORM=$(PLATFORM) SHELL_NAME=$(SHELL_NAME)
#
hw_link:
	@make -C ./linking all TARGET=$(TARGET) PLATFORM=$(PLATFORM) SHELL_NAME=$(SHELL_NAME)
#
## Build software object
build_sw: 
	@make -C ./sw all 
#
testbench_all:
	@make -C ./aie aie_compile_x86
	@make -C ./fpga testbench_setupaie
	@make -C ./fpga testbench_sink_from_aie
#
NAME := hw_build
#
pack:
	@cp sw/host_overlay.exe build/$(NAME)/
	@cp linking/overlay_hw.xclbin build/$(NAME)/
#
build_and_pack:
	@echo ""
	@echo "*********************** Building ***********************"
	@echo "- NAME          $(NAME)"
	@echo "- TARGET        $(TARGET)"
	@echo "- PLATFORM      $(PLATFORM)"
	@echo "- SHELL_NAME    $(SHELL_NAME)"
	@echo "********************************************************"
	@echo ""
	@make build_hw
	@make build_sw
	@make pack

# Clean objects
clean: clean_aie clean_FPGA clean_hw clean_sw

clean_aie:
	@make -C ./aie clean

clean_FPGA:
	@make -C ./fpga clean

clean_hw:
	@make -C ./linking clean

clean_sw: 
	@make -C ./sw clean
