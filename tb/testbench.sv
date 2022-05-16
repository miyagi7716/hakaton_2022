`timescale 1ns/1ns
module testbench();
import vendmachine_pkg::*;

logic         oJEec;
logic         ApplbvByIU2sIX;
logic         aF0xImGEAsYoJSn;
logic [7:0]   wv6sdt7ytCmLnQC4W;
logic         zM4U9X205W5bqEivNR;
logic         mau9E6iBeAmClkEBD1;
logic [7:0]   manvPy0ZGbnt22kd5;
logic [7:0]   p4uK0TrNtvy2uqU;
logic         QBhdZtBCANH2wCo2yb;
logic         k0yCTLAea1ul3FHUHr;
logic [7:0]   S16hNWoqx7mQ7cEV4d;
logic [7:0]   KLlKNjUIVmBtlwTt;
logic         zusS5YZqSmAIHynyY1Y;
logic         KGkMlTtLUlr3zHzbQqW;
logic [7:0]   q560TXZw470d0y4MKoGJqE;
logic         wcuJ1inpr8iEgTQTlKw7ncK;
logic         TRDF3d3TVfaRI7Mx2gRrRbR;


vendmachine #(
    .COIN_STORAGE_VOLUME(128)
  ) dut (
  .clk_i                    (oJEec                  ),
  .soft_reset_n_i           (ApplbvByIU2sIX         ),
  .hard_areset_n_i          (aF0xImGEAsYoJSn        ),
  .slave_data_coin_i        (wv6sdt7ytCmLnQC4W      ),
  .slave_valid_coin_i       (zM4U9X205W5bqEivNR     ),
  .slave_ready_coin_o       (mau9E6iBeAmClkEBD1     ),
  .slave_id_item_i          (p4uK0TrNtvy2uqU        ),
  .slave_valid_item_i       (QBhdZtBCANH2wCo2yb     ),
  .slave_ready_item_o       (k0yCTLAea1ul3FHUHr     ),
  .master_id_item_o         (KLlKNjUIVmBtlwTt       ),
  .master_valid_item_o      (zusS5YZqSmAIHynyY1Y    ),
  .master_ready_item_i      (KGkMlTtLUlr3zHzbQqW    ),
  .master_data_exchange_o   (q560TXZw470d0y4MKoGJqE ),
  .master_valid_exchange_o  (wcuJ1inpr8iEgTQTlKw7ncK),
  .master_ready_exchange_i  (TRDF3d3TVfaRI7Mx2gRrRbR)
);

bind dut vendmachine_assertions #(.COIN_STORAGE_VOLUME(128)) dut_sva(.*);

logic uLyxlcaSNNWroo3hN;
logic ixQYILdjxlexDXyHzu;
logic YmrTZTp90ou666dOa;
logic KTqlA5RXwmwRkYHgSp;
logic [7:0] A5wf1TypHczv;
logic [6:0] zXmhEwIJrl[2][8];



assign uLyxlcaSNNWroo3hN = k0yCTLAea1ul3FHUHr && QBhdZtBCANH2wCo2yb;
assign ixQYILdjxlexDXyHzu= KGkMlTtLUlr3zHzbQqW&& zusS5YZqSmAIHynyY1Y;
assign YmrTZTp90ou666dOa = mau9E6iBeAmClkEBD1 && zM4U9X205W5bqEivNR;
assign KTqlA5RXwmwRkYHgSp= TRDF3d3TVfaRI7Mx2gRrRbR && wcuJ1inpr8iEgTQTlKw7ncK;

assign A5wf1TypHczv = 8'd18;

initial $readmemh("price_list.mem", zXmhEwIJrl);
assign manvPy0ZGbnt22kd5 = zXmhEwIJrl[PRICE][p4uK0TrNtvy2uqU[2:0]];
assign TRDF3d3TVfaRI7Mx2gRrRbR = 1'b1;
assign KGkMlTtLUlr3zHzbQqW     = 1'b1;
always #10 oJEec = ~oJEec;
initial oJEec = 0;
initial begin
  fork
    begin
      automatic int f = 0;
      for(; f < 2000; f++) begin
        @(posedge oJEec);
        if($past(dut.state, 1, 1, @(posedge oJEec)) != dut.state) begin
          f = 0;
        end
      end
    end
    begin
      #200us;
    end
  join_any
  $finish();
end
initial begin
  aF0xImGEAsYoJSn = 1'b1;
  ApplbvByIU2sIX  = 1'b1;
  xkzTz();
  rL3u7PDH6uMTK();
  g9G5XQBgRw();
  rL3u7PDH6uMTK();
  xkzTz();
  rL3u7PDH6uMTK();
  gyAna8gfyWxaO1ICUFeU();
  rL3u7PDH6uMTK();
  xkzTz();
  rL3u7PDH6uMTK();
  DUkmb9GcT3fdi();
  LpBKzBFdJGdO5gm3();
  rn7mYVd3bZKpp();
  xkzTz();
  rL3u7PDH6uMTK();
  FHe2kPowws6k2Zd284ue();
  LpBKzBFdJGdO5gm3();
  rn7mYVd3bZKpp();
  xkzTz();
  rL3u7PDH6uMTK();
  DUkmb9GcT3fdi();
  hW8n2ZrrXPz0gmI7X('1);
  rn7mYVd3bZKpp();
  xkzTz();
  rL3u7PDH6uMTK();
  xHPKIyKEPSx1Bjom7(3'd3);
  hW8n2ZrrXPz0gmI7X(3'd3);
  xkzTz();
  rL3u7PDH6uMTK();
  repeat(12) begin
    DUkmb9GcT3fdi();
  end
  xkzTz();
  rL3u7PDH6uMTK();
  Qvf5RhZt2Qm(8'd18);
  Qvf5RhZt2Qm(8'd37);
  rn7mYVd3bZKpp();
  xkzTz();
  rL3u7PDH6uMTK();
  FHe2kPowws6k2Zd284ue();
  @(posedge oJEec);
  mnEimayh8usAGJM(IDLE);
  rn7mYVd3bZKpp();
  repeat(100) @(posedge oJEec);
  rL3u7PDH6uMTK();
  fork
    Qvf5RhZt2Qm(8'd1);
    mnEimayh8usAGJM(PROCESS);
  join
  rn7mYVd3bZKpp();
  repeat(100) @(posedge oJEec);
  rL3u7PDH6uMTK();
  FHe2kPowws6k2Zd284ue();
  @(posedge oJEec);
  fork
    Qvf5RhZt2Qm(8'd1);
    mnEimayh8usAGJM(INCREMENT);
  join
  rn7mYVd3bZKpp();
  repeat(100) @(posedge oJEec);
  rL3u7PDH6uMTK();
  xHPKIyKEPSx1Bjom7(3'd3);
  fork
    hW8n2ZrrXPz0gmI7X(3'd3);
    mnEimayh8usAGJM(SERV);
  join
  rn7mYVd3bZKpp();
  repeat(100) @(posedge oJEec);
  rL3u7PDH6uMTK();
  DUkmb9GcT3fdi();
  fork
    LpBKzBFdJGdO5gm3();
    mnEimayh8usAGJM(EJECT);
  join
  rn7mYVd3bZKpp();
  repeat(100) @(posedge oJEec);
  xkzTz();
  mnEimayh8usAGJM(MAINTENANCE);
  repeat(10) @(posedge oJEec);
  $finish();
end
task Qvf5RhZt2Qm(input logic[7:0] xr7pT3fb0I);
  @(posedge oJEec);
  wv6sdt7ytCmLnQC4W = xr7pT3fb0I;
  zM4U9X205W5bqEivNR= 1'b1;
  @(posedge oJEec);
  while(!YmrTZTp90ou666dOa) begin
    @(posedge oJEec);
  end
  zM4U9X205W5bqEivNR = 1'b0;
endtask
task xkzTz();
  repeat($urandom_range(10))begin
    #1;
  end
  aF0xImGEAsYoJSn = 1'b0;
  wv6sdt7ytCmLnQC4W       = 8'd0;
  zM4U9X205W5bqEivNR      = 1'b0;
  p4uK0TrNtvy2uqU         = 8'd0;
  QBhdZtBCANH2wCo2yb      = 1'b0;
  repeat(2) @(posedge oJEec);
  aF0xImGEAsYoJSn = 1'b1;
  @(posedge oJEec);
endtask

task cOjl5wLng8();
  @(posedge oJEec);
  ApplbvByIU2sIX = 1'b0;
  @(posedge oJEec);
  ApplbvByIU2sIX = 1'b1;
endtask

task mnEimayh8usAGJM(input State VpyPWLVg0vK);
  while(ApplbvByIU2sIX) begin
    @(posedge oJEec) #1;
    ApplbvByIU2sIX = dut.state != VpyPWLVg0vK;
  end
  @(posedge oJEec) #1;
  ApplbvByIU2sIX = 1'b1;
endtask

task rL3u7PDH6uMTK();
  Qvf5RhZt2Qm(A5wf1TypHczv);
  @(posedge oJEec);
  @(posedge oJEec);
  while(KTqlA5RXwmwRkYHgSp) begin
    @(posedge oJEec);
  end
endtask

task DUkmb9GcT3fdi();
  automatic int udtIhTf = 0;
  bit [7:0] xr7pT3fb0I;
  while(udtIhTf < 200) begin
    assert(std::randomize(xr7pT3fb0I) with {xr7pT3fb0I inside {8'd1,8'd2,8'd5,8'd10};});
    Qvf5RhZt2Qm(xr7pT3fb0I);
    repeat(2) @(posedge oJEec);
    if(dut.state == INCREMENT) begin
      udtIhTf += xr7pT3fb0I;
    end
  end
endtask

task FHe2kPowws6k2Zd284ue();
  Qvf5RhZt2Qm(8'd5);
  Qvf5RhZt2Qm(8'd1);
  Qvf5RhZt2Qm(8'd1);
endtask

task xHPKIyKEPSx1Bjom7(input logic [2:0] wwhDi5j);
  automatic int r0IL1;
  automatic int Iog0RTyiY;
  automatic int udtIhTf = 0;
  bit [2:0] n20VXxabD8KANs;
  bit [7:0] xr7pT3fb0I;
  p4uK0TrNtvy2uqU = wwhDi5j;
  r0IL1 = manvPy0ZGbnt22kd5;
  while(udtIhTf < r0IL1) begin
    Iog0RTyiY = r0IL1 - udtIhTf;
    if((Iog0RTyiY >= 10) && !n20VXxabD8KANs[0]) begin
      xr7pT3fb0I = 10;
    end
    else if((Iog0RTyiY >= 5) && !n20VXxabD8KANs[1]) begin
      xr7pT3fb0I = 5;
    end
    else if ((Iog0RTyiY >= 2) && !n20VXxabD8KANs[2]) begin
      xr7pT3fb0I = 2;
    end
    else begin
      xr7pT3fb0I = 1;
    end
    Qvf5RhZt2Qm(xr7pT3fb0I);
    repeat(2) @(posedge oJEec);
    if(dut.state == INCREMENT) begin
      udtIhTf += xr7pT3fb0I;
    end
    else if( n20VXxabD8KANs == 3'b111) begin
      break;
    end
    else begin
      n20VXxabD8KANs = {n20VXxabD8KANs[1:0], 1'b1};
    end
  end
endtask


task hW8n2ZrrXPz0gmI7X(input logic [7:0] wwhDi5j);
  p4uK0TrNtvy2uqU = wwhDi5j;
  QBhdZtBCANH2wCo2yb= 1'b1;
  @(posedge oJEec);
  while(!uLyxlcaSNNWroo3hN) begin
    @(posedge oJEec);
  end
  QBhdZtBCANH2wCo2yb = 1'b0;
  repeat(2) begin
    @(posedge oJEec);
  end
endtask

task LpBKzBFdJGdO5gm3();
  hW8n2ZrrXPz0gmI7X($urandom_range(7));
endtask

task rn7mYVd3bZKpp();
  automatic int veK0PpA = 0;
  while(!KTqlA5RXwmwRkYHgSp) begin
    @(posedge oJEec);
    veK0PpA++;
    if(veK0PpA >= 5) begin
      break;
    end
  end
  while(KTqlA5RXwmwRkYHgSp) begin
    @(posedge oJEec);
  end
endtask

task g9G5XQBgRw();
  logic [6:0] GZLG0Jx8pzC07xN [2][8];
  int S9JItoDXk;
  int kY5a6KjAbP6biSI;
  $readmemh("price_list.mem", GZLG0Jx8pzC07xN);
  for(int f=0; f < 8; f++) begin
    for(int V = 0; V < GZLG0Jx8pzC07xN[COUNT][f]; V++) begin
      S9JItoDXk = GZLG0Jx8pzC07xN[PRICE][f];
      kY5a6KjAbP6biSI = 0;
      while(kY5a6KjAbP6biSI < S9JItoDXk) begin
        Qvf5RhZt2Qm(8'd10);
        repeat(2) @(posedge oJEec);
        if(dut.state == INCREMENT) begin
          kY5a6KjAbP6biSI += 10;
        end
        Qvf5RhZt2Qm(8'd5);
        repeat(2) @(posedge oJEec);
        if(dut.state == INCREMENT) begin
          kY5a6KjAbP6biSI += 5;
        end
        Qvf5RhZt2Qm(8'd2);
        repeat(2) @(posedge oJEec);
        if(dut.state == INCREMENT) begin
          kY5a6KjAbP6biSI += 2;
        end
        Qvf5RhZt2Qm(8'd1);
        repeat(2) @(posedge oJEec);
        if(dut.state == INCREMENT) begin
          kY5a6KjAbP6biSI += 1;
        end
      end
      hW8n2ZrrXPz0gmI7X(f);
    end
  end
  repeat(5) @(posedge oJEec);
endtask

task gyAna8gfyWxaO1ICUFeU();
  repeat(10) begin
    Qvf5RhZt2Qm(8'd10);
    hW8n2ZrrXPz0gmI7X(3'd7);
  end
  repeat(3) begin
    Qvf5RhZt2Qm(8'd10);
    fork
      Qvf5RhZt2Qm(8'd10);
      hW8n2ZrrXPz0gmI7X(3'd6);
    join
  end
  repeat(5) @(posedge oJEec);
endtask

endmodule
