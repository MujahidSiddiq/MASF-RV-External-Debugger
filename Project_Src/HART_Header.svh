typedef enum logic [11:0] {
    Dcsr         = 12'h7b0,
    Dpc          = 12'h7b1,
    Dscratch0    = 12'h7b2,
    Dscratch1    = 12'h7b3
} type_dmode_reg_addr_e;



// typedef struct packed {
//     logic [3:0]   debgver;
//     logic [2:0]   extcause;
//     logic         cetrig;
//     logic         ebreakvs;
//     logic         ebreakvu;
//     logic         ebreakvm;
//     logic         ebreaks;
//     logic         ebreaku;
//     logic         stepie;
//     logic         stopcount;
//     logic         stoptime;
//     logic [2:0]   cause;
//     logic         v;
//     logic         mpreven;
//     logic         nmip;
//     logic         step;
//     logic         prv;
// } type_dmode_reg_dcsr_e;

typedef struct packed {
    logic [3:0] debugver;                    // Bits 31:28
    logic fixed_zero_bit_27;                 // Bit 27 
    logic [2:0] extcause;                    // Bits 26:24
    logic [3:0] fixed_zero_bits_20_to_23;    // Bits 23:20
    logic cetrig;                            // Bit 19
    logic fixed_zero_bit_18;                 // Bit 18 
    logic ebreakvs;                          // Bit 17
    logic ebreakvu;                          // Bit 16
    logic ebreakm;                           // Bit 15
    logic fixed_zero_bit_14;                 // Bit 14
    logic ebreaks;                           // Bit 13
    logic ebreaku;                           // Bit 12
    logic stepie;                            // Bit 11
    logic stopcount;                         // Bit 10
    logic stoptime;                          // Bit 9
    logic [2:0] cause;                       // Bits 8:6
    logic v;                                 // Bit 5    
    logic mprven;                            // Bit 4
    logic nmip;                              // Bit 3
    logic step;                              // Bit 2
    logic [1:0] prv;                         // Bits 1:0
} type_dmode_reg_dcsr_e;


// State encoding
typedef enum logic [2:0] {
    NORMAL_EXEC         = 3'b000, 
    WAITING_FOR_ACK     = 3'b001,
    DEBUG_MODE          = 3'b010, 
    HART_RESUMING       = 3'b011,
    STEP_EXEC           = 3'b100, 
    WAITING_FOR_I_COMP  = 3'b101, 
    EBREAK              = 3'b110,
    RESUME_FOR_EBREAK   = 3'b111
} type_states_dmode_e;


