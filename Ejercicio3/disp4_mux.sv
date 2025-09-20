
// Módulo para multiplexar 4 dígitos en un display de 7 segmentos
// Recibe un dato de 16 bits y muestra cada nibble (4 bits) en un dígito del display
// El barrido se realiza a ~4 kHz usando un contador de división
module disp4_mux (
    input  logic        clk,   // Reloj de 100 MHz
    input  logic        rst,   // Reset asíncrono
    input  logic [15:0] data,  // Datos a mostrar: {hex3,hex2,hex1,hex0}
    //es de 16 bits porque son 4 digitos y cada digito es 4 bits (4*4=16)
    output logic [7:0]  an,    // Control de ánodos (activos en 0)
//los anodos son 8 porque el display es de 8 digitos


    output logic [6:0]  seg,   // Segmentos del display (activos en 0)
    output logic        dp     // Punto decimal
);
    // Contador para generar la frecuencia de barrido (~4 kHz)
    logic [14:0] divcnt;
    always_ff @(posedge clk) begin
        if (rst) divcnt <= '0; // Si hay reset, el contador se pone en cero
        else     divcnt <= divcnt + 15'd1; // Incrementa el contador en cada ciclo de reloj
    end

    // Selector de dígito: toma los bits más altos del contador para elegir el dígito activo
    logic [1:0] sel = divcnt[14:13]; // Usa los bits 13 y 14 para seleccionar entre 4 dígitos (00, 01, 10, 11)
logic [3:0] nibble0, nibble1, nibble2, nibble3;
logic [3:0] nibble; // Nibble seleccionado para el dígito activo

// Selección de los nibbles individuales
always_comb begin
    nibble0 = data[3:0];
    nibble1 = data[7:4];
    nibble2 = data[11:8];
    nibble3 = data[15:12];
    case (sel)
        2'd0: nibble = nibble0;
        2'd1: nibble = nibble1;
        2'd2: nibble = nibble2;
        2'd3: nibble = nibble3;
        default: nibble = 4'd0;
    endcase
end

// Instancia única del decodificador de 7 segmentos
hex7seg_al u_dec(.hex(nibble), .seg(seg));

    // Control de los ánodos y del punto decimal
    always_comb begin
        an = 8'b11111111; // Todos los dígitos apagados por defecto
        dp = 1'b1;        // Punto decimal apagado
        unique case(sel)
            2'd0: an[0] = 1'b0; // Activa dígito 0
            2'd1: an[1] = 1'b0; // Activa dígito 1
            2'd2: an[2] = 1'b0; // Activa dígito 2
            2'd3: an[3] = 1'b0; // Activa dígito 3
        endcase
    end
endmodule