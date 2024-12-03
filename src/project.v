
//8*16 FIFO module
module fifo(clk,resetn,wr_enb,rd_enb,wr_data,rd_data,f_full,f_empty,f_almostfull,f_almostempty,f_underrun,f_overrun);
  input              clk;
  input              resetn;
  input              wr_enb;
  input              rd_enb;
  input      [15:0]  wr_data;
  output reg [15:0]  rd_data;
  output             f_full;
  output             f_empty;
  output             f_almostfull;
  output             f_almostempty;
  output             f_underrun;
  output             f_overrun;
 
  //FIFO size declaration
  reg [15:0]fif[0:7];
 
  //intermediate signal
  reg        [3:0]   occupancy;
  reg        [2:0]   wr_pntr;
  reg        [2:0]   rd_pntr;
  wire               eff_write;
  wire               eff_read;
 
 //flag status signal
  assign f_full=((occupancy==4'd8)?1'b1:1'b0);
  assign f_empty=((occupancy==4'd0)?1'b1:1'b0);
  assign f_almostfull=((occupancy==4'd6)?1'b1:1'b0);
  assign f_almostempty=((occupancy==4'd2)?1'b1:1'b0);
  assign f_underrun=(((rd_enb==1'b1)&&(f_empty==1'b1))?1'b1:1'b0);
  assign f_overrun=(((wr_enb==1'b1)&&(f_full==1'b1))?1'b1:1'b0);
 
 //effective write & read
  assign eff_write=((wr_enb==1'b1)&&(f_full==1'b0))?1'b1:1'b0;
  assign eff_read=((rd_enb==1'b1)&&(f_empty==1'b0))?1'b1:1'b0;
 
 //occupancy
  always@(posedge clk or negedge resetn)
    begin
      if(!resetn)
        occupancy<=4'b0;
      else
        begin
          case({eff_write,eff_read})
            2'b00:occupancy<=occupancy;
            2'b01:occupancy<=occupancy-1'b1;
            2'b10:occupancy<=occupancy+1'b1;
            2'b11:occupancy<=occupancy;
          endcase
        end
    end
 
//updation of write pointer
  always@(posedge clk or negedge resetn)
    begin
      if(!resetn)
        wr_pntr<=3'b0;
      else
        begin
          if(eff_write==1'b1)
            wr_pntr<=wr_pntr+1;
          else
            wr_pntr<=wr_pntr;
        end
    end
 
//updation of read pointer
  always@(posedge clk or negedge resetn)
    begin
      if(!resetn)
        rd_pntr<=3'b0;
      else
        begin
          if(eff_read==1'b1)
            rd_pntr<=rd_pntr+1;
          else
            rd_pntr<=rd_pntr;
        end
    end
 
//write operation
 always@(posedge clk)
    begin
      if(eff_write==1'b1)
        fif[wr_pntr]<=wr_data;
    end
 
//read operation
 always@(posedge clk)
    begin
      if(eff_read==1'b1)
        rd_data<=fif[rd_pntr];
    end
endmodule

