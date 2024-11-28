`timescale 1ns/1ps
import axi_vip_pkg::*;
import ex_sim_axi_vip_mst_0_pkg::*;

module tb();

    localparam int LP_CLK_PERI = 5;
    localparam int LP_RST_PERI = 50;

    // DUT instance
    logic aresetn, aclk;
    chip dut(.*);

    task rst_gen();
        aresetn = '0;
        #(LP_RST_PERI);
        aresetn = '1;
    endtask

    task clk_gen();
        aclk = '0;
        forever #(LP_CLK_PERI/2) aclk = ~aclk;
    endtask

    task clk_dly(int n);
        repeat(n) @(posedge aclk);
    endtask

    // VIP decreation
    ex_sim_axi_vip_mst_0_mst_t   agent;

    task init_agent();
        agent = new("master vip agent", dut.ex_design.axi_vip_mst.inst.IF);
        agent.start_master();
    endtask

    // Transaction method
    task wr_tran();
        axi_transaction  wr_transaction;
        wr_transaction   = agent.wr_driver.create_transaction( "write transaction with randomization");
//        WR_TRANSACTION_FAIL: assert(wr_transaction.randomize());
        wr_transaction.set_write_cmd(0, XIL_AXI_BURST_TYPE_INCR, 0, 0, xil_axi_size_t'(xil_clog2((32)/8)));
        wr_transaction.set_data_block(32'h12345678);
        agent.wr_driver.send(wr_transaction);
    endtask

    task rd_tran();
        axi_transaction  rd_transaction;
        rd_transaction   = agent.rd_driver.create_transaction("read transaction with randomization");
//        RD_TRANSACTION_FAIL_1a:assert(rd_transaction.randomize());
//        agent.rd_driver.send(rd_transaction);
        
        rd_transaction.set_read_cmd(0, XIL_AXI_BURST_TYPE_INCR, 0, 0, xil_axi_size_t'(xil_clog2((32)/8)));
        agent.rd_driver.send(rd_transaction);
    endtask

    // Testscenario
    initial begin

        fork
            init_agent();
            clk_gen();
            rst_gen();
        join_none

        clk_dly(1000);

        rd_tran();

        clk_dly(1000);

        rd_tran();
        
        clk_dly(1000);

        wr_tran();

        clk_dly(1000);

        rd_tran();

        clk_dly(1000);
        $finish(2000);
    end
endmodule