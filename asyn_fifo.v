// Code your design here
module Asyn_fifo(wrclk,rdclk,rst,wr,rd,wdata,rdata,valid,empty,full,overflow,underflow);
parameter datawidth=8;
input wrclk,rdclk,rst,wr,rd;
input [datawidth-1:0]wdata;
output reg [datawidth-1:0]rdata;
output valid,empty,full,overflow,underflow;
parameter adress_size=4; 
parameter fifo_depth=1<<adress_size;
reg [adress_size-1:0]wr_pointer;
reg [adress_size-1:0]rd_pointer;
  reg [datawidth-1:0]mem[0:fifo_depth-1];
wire [adress_size-1:0]wr_pointer_g;
wire [adress_size-1:0]rd_pointer_g;
reg  [adress_size-1:0]wr_pointer_g_s1;
reg  [adress_size-1:0]wr_pointer_g_s2;
reg  [adress_size-1:0]rd_pointer_g_s1;
reg  [adress_size-1:0]rd_pointer_g_s2;

//Writing data to FIFO
always@(posedge wrclk) begin
if(rst)
wr_pointer<=0;
else begin
if(wr&&!full) begin
mem[wr_pointer]<=wdata;
wr_pointer<=wr_pointer+1;
end
end
end
//read data from FIFO
always @(posedge rdclk) begin
if(rst)
rd_pointer<=0;
else begin
if(rd && !empty) begin
rdata<=mem[rd_pointer];
rd_pointer<=rd_pointer+1;
end
end
end
//write and read pointer to gray pointer
assign wr_pointer_g=wr_pointer^(wr_pointer>>1);
assign rd_pointer_g=rd_pointer^(rd_pointer>>1);

//2 stage synchroniser  for wr_pointer wrt rd_clk
always @(posedge rdclk)
begin
if(rst) begin
wr_pointer_g_s1<=0;
wr_pointer_g_s2<=0;
end
else begin
wr_pointer_g_s1<=wr_pointer_g;
wr_pointer_g_s2<=wr_pointer_g_s1;
end
end
//2 stage synchroniser for rd_pointer wrt wr_clk
always @(posedge wrclk)
begin
if(rst) begin
rd_pointer_g_s1<=0;
rd_pointer_g_s2<=0;
end
else begin
rd_pointer_g_s1<=rd_pointer_g;
rd_pointer_g_s2<=rd_pointer_g_s1;
end
end
//Empty and full condition check
assign empty=rd_pointer_g==wr_pointer_g_s2;
assign full=wr_pointer_g[adress_size-1]!=rd_pointer_g_s2[adress_size-1]
&& wr_pointer_g[adress_size-2]!=rd_pointer_g_s2[adress_size-2] &&
wr_pointer_g[adress_size-3:0]==rd_pointer_g_s2[adress_size-3:0];

assign overflow=full&&wr;
assign underflow=empty&&rd;
assign valid =rd && !empty;
endmodule
