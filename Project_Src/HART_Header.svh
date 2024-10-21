typedef enum logic [11:0] {
    Dcsr         = 12'h7b0,
    Dpc          = 12'h7b1,
    Dscratch0    = 12'h7b2,
    Dscratch1    = 12'h7b3
} type_dmode_reg_addr_e;

logic [31:0] dpc_reg;

typedef struct packed {
    logic [3:0]   debgver;
    logic [2:0]   extcause;
    logic         cetrig;
    logic         ebreakvs;
    logic         ebreakvu;
    logic         ebreakvm;
    logic         ebreaks;
    logic         ebreaku;
    logic         stepie;
    logic         stopcount;
    logic         stoptime;
    logic [2:0]   cause;
    logic         v;
    logic         mpreven;
    logic         nmip;
    logic         step;
    logic         prv;
} type_dmode_reg_dcsr_e;

// State encoding
typedef enum logic [2:0] {
    NORMAL_EXEC         = 3'b000, // Normal Execution state (running)
    DEBUG_MODE          = 3'b001, // Halting state (running/halted)
    HART_RESUMING       = 3'b010,
    FIRST_STEP_EXEC     = 3'b011, // Halted state (halted)
    WAITING_FOR_I_COMP  = 3'b100, // Resuming state (running/halted)
    STEPPING            = 3'b101
} type_states_dmode_e;


