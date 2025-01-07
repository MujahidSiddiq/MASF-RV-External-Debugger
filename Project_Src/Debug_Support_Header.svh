

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



// State encoding
typedef enum logic [2:0] {
    NORMAL_EXEC         = 3'b000, 
    WAIT_FOR_ACK        = 3'b001,
    DEBUG_MODE          = 3'b010, 
    PPL_RESUMING        = 3'b011,
    STEP_EXEC           = 3'b100, 
    WAIT_FOR_I_COMP     = 3'b101, 
    EBREAK              = 3'b110,
    RES_FOR_EBREAK   = 3'b111
} type_states_dmode_e;


