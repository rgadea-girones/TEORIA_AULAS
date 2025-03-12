// Code your testbench here
// or browse Examples
`timescale 1 ns / 1 ps


module Shifter_basico_tb  ; 
localparam T=50;
localparam Thold=5;
localparam Td=10;
localparam Tsetup=5;
localparam Profundidad=4;
localparam tamanyo=8;
localparam Size=$clog2(Profundidad);

logic [7:0] out   ;
  
integer A;
reg aleatorio;

reg    clk   ; 
reg    reset   ; 
reg  [tamanyo-1:0]  in   ;
reg   enable;
  SHIFTER2D    DUT  ( 
     .SS (out ) ,
     .enable,
     .clk (clk  ) ,
     .reset (reset ) ,
     .ES (in ) ); 

initial begin clk = 1'b0;
forever #(T/2)  clk = !clk;
end

initial begin
  $dumpfile("SHIFTER2D.vcd");
  $dumpvars(0,Shifter_basico_tb);
end  
initial
begin
	$warning("SIMULANDO!!!"); 
    aleatorio=1'b0;
    reset=1'b1;
    enable=1'b0;
    in=8'b0;
	# (T*5);                    
  	$warning("VERIFICACION 1 desplazamiento de un UNO");     CASO_1(); 
 	#(T*5);
	aleatorio=1'b1;
  $warning("VERIFICACION 2 desplazamiento de otros 3 valores");CASO_2(); 
 	#(T*5);
  $warning("VERIFICACION 3 desplazamiento de otros 5 valores");CASO_3();
 	#(T*5);
    $stop;  
    $finish;
	end      

task resetea;
  	begin
      @(negedge clk) reset = 1'b0;
      enable=1'b1;
      @(negedge clk) reset  = 1'b1;
    end
endtask
  
always wait(aleatorio)
begin
                @(posedge clk)
	 	A = ({$random} % 2);
		#0 enable=A;
end

task CASO_1;
	begin
      resetea();
	  in=8'b1;
      enable=1'b1;
      @(negedge clk) in=8'b1;
      enable=1'b0;
      repeat (2) 	@(negedge clk);
      enable=1'b1; 
      repeat (2) 	@(negedge clk);  
      comprueba_vector_2pos(8'b1);
	end
endtask
task CASO_2;
	begin
      resetea();
	    in=8'b0;
      enable=1'b1;
      fork
        if (enable) estimula_y_comprueba(4,5);
        begin
        @(posedge clk);
        if (enable ) estimula_y_comprueba(4,7);
        end
        begin
          repeat(2)  @(posedge clk);
          if (enable )estimula_y_comprueba(4,48);
        end

      join
	end
endtask

task CASO_3;
   integer i;
	begin
      resetea();
      i=$random%8;
      fork
        if (enable) estimula_y_comprueba(4,i-1);
        begin
        @(posedge clk);
        if (enable ) estimula_y_comprueba(4,i);
        end
        begin
          repeat(2)  @(posedge clk);
          if (enable )estimula_y_comprueba(4,i+1);
        end
        begin
          repeat(3)  @(posedge clk);
          if (enable )estimula_y_comprueba(4,i+2);
        end
        begin
          repeat(4)  @(posedge clk);
          if (enable )estimula_y_comprueba(4,i+3);
        end

      join
	end
endtask 

task automatic comprueba_vector_neg;
ref  datos_sal_obtenido;
ref  reloj;  
input  datos_sal_esperado;
begin
  @(posedge reloj);
  @(negedge reloj);
  if(datos_sal_obtenido !== datos_sal_esperado)
    $error ("TEST: El shifter no da un retardo de 4 etapas");       
end
endtask  
  
  
task automatic comprueba_vector_2pos;
input  datos_sal_esperado;
begin
  @(posedge clk); 
  #(T-Tsetup);
  if(out !== datos_sal_esperado)
    $error ("TEST: El shifter no da un retardo de 4 etapas");       
  else 
       fork: espero_no_cambio
         @(out) $error ("fallo setup");
         @(posedge clk)  disable espero_no_cambio;                  
       join
end
endtask  
  
task automatic estimula_y_comprueba;
input int profundidad_shift;
input  [7: 0] dato_entrada_shift;

 automatic integer count;

       fork: espero
         count=0;      
         begin
             //@(posedge clk); 
                    #Thold in=dato_entrada_shift;
         end


         #0 begin 
           wait(count==profundidad_shift ); 
           #(T-Tsetup);
           if (out != dato_entrada_shift)
             $error ("TEST: El shifter no da un retardo de 4 etapas, da %d y debería dar %d",out,dato_entrada_shift );  
            else
              $info ("TEST: El shifter da un retardo de 4 etapas, da %d y debería dar %d",out,dato_entrada_shift ); 
         end
        while (count<profundidad_shift)
              begin 
                @(posedge clk);
                      if (enable==1'b1)
                          count=count+1;

              end
       join  

endtask  

endmodule