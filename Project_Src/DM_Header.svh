


typedef enum logic [7:0] {
    Data0        = 8'h04,
    Data1        = 8'h05,
    Data2        = 8'h06,
    Data3        = 8'h07,
    Data4        = 8'h08,
    Data5        = 8'h09,
    Data6        = 8'h0A,
    Data7        = 8'h0B,
    Data8        = 8'h0C,
    Data9        = 8'h0D,
    Data10       = 8'h0E,
    Data11       = 8'h0F,
    DMControl    = 8'h10,
    DMStatus     = 8'h11,
    AbstractCS   = 8'h16,
    Command      = 8'h17,
    ProgBuf0     = 8'h20,
    ProgBuf1     = 8'h21,
    ProgBuf2     = 8'h22,
    ProgBuf3     = 8'h23,
    ProgBuf4     = 8'h24,
    ProgBuf5     = 8'h25,
    ProgBuf6     = 8'h26,
    ProgBuf7     = 8'h27,
    ProgBuf8     = 8'h28,
    ProgBuf9     = 8'h29,
    ProgBuf10    = 8'h2A,
    ProgBuf11    = 8'h2B,
    ProgBuf12    = 8'h2C,
    ProgBuf13    = 8'h2D,
    ProgBuf14    = 8'h2E,
    ProgBuf15    = 8'h2F
} type_dm_reg_addr_e;





typedef struct packed {
    logic           haltreq;
    logic           resumereq;
    logic           hartreset;
    logic           ackhavereset;
    logic           ackunavail;
    logic           hasel;
    logic [9:0]     hartsello;
    logic [9:0]     hartselhi;
    logic           setkeepalive;
    logic           clrkeepalive;
    logic           setresethaltreq;
    logic           clrresethaltreq;
    logic           ndmreset;
    logic           dmactive;
} type_dm_reg_dmcontrol_e;



typedef struct packed {
    logic [6:0]     reserved_31_25;     // Bits 31:25: Reserved (0)
    logic           ndmresetpending;    // Bit 24: ndmresetpending
    logic           stickyunavail;      // Bit 23: stickyunavail
    logic           impebreak;          // Bit 22: impebreak
    logic [1:0]     reserved_21_20;     // Bits 21:20: Reserved (0)
    logic           allhavereset;       // Bit 19: allhavereset
    logic           anyhavereset;       // Bit 18: anyhavereset
    logic           allresumeack;       // Bit 17: allresumeack
    logic           anyresumeack;       // Bit 16: anyresumeack
    logic           allnonexistent;     // Bit 15: allnonexistent
    logic           anynonexistent;     // Bit 14: anynonexistent
    logic           allunavail;         // Bit 13: allunavail
    logic           anyunavail;         // Bit 12: anyunavail
    logic           allrunning;         // Bit 11: allrunning
    logic           anyrunning;         // Bit 10: anyrunning
    logic           allhalted;          // Bit 9: allhalted
    logic           anyhalted;          // Bit 8: anyhalted
    logic           authenticated;      // Bit 7: authenticated
    logic           authbusy;           // Bit 6: authbusy
    logic           hasresethaltreq;    // Bit 5: hasresethaltreq
    logic           confstrptrvalid;    // Bit 4: confstrptrvalid
    logic [3:0]     version;            // Bits 3:0: version
} type_dm_reg_dmstatus_e;




typedef struct packed {
    logic [2:0]     reserved_31_29;     // Bits 31:29: Reserved
    logic [4:0]     progbufsize;        // Bits 28:24: progbufsize
    logic [9:0]     reserved_23_13;     // Bits 23:13: Reserved
    logic           busy;               // Bit 12: busy
    logic           relaxedpriv;        // Bit 11: relaxedpriv
    logic [2:0]     cmderr;             // Bits 10:8: cmderr
    logic [3:0]     reserved_7_4;       // Bits 7:4: Reserved
    logic [3:0]     datacount;          // Bits 3:0: datacount
} type_dm_reg_abstractcs_e;




typedef struct packed {
    logic [7:0]     cmdtype;            // Bits 31:24: cmdtype
    logic           reser;
    logic [2:0]     aarsize;            // Bits 22:20: aarsize
    logic           aarpostincrement;   // Bit 19: aarpostincrement
    logic           postexec;           // Bit 18: postexec
    logic           transfer;           // Bit 17: transfer
    logic           write;              // Bit 16: write
    logic [15:0]    regno;              // Bits 15:0: regno
    
} type_dm_reg_command_e;


// State encoding
typedef enum logic [2:0] {
    NORMAL_EXECUTION = 3'b000,          // Normal Execution state (running)
    HALTING          = 3'b001,          // Halting state (running/halted)
    HALTED           = 3'b010,          // Halted state (halted)
    RESUMING         = 3'b011,          // Resuming state (running/halted)
    COMMAND_START    = 3'B100,
    COMMAND_TRANSFER = 3'B101,
    COMMAND_DONE     = 3'B110,
    HART_RESET       = 3'b111           // Hart Reset state

} type_states_hart_e;


// Define the data registers as an array
logic [31:0] data_reg [11:0];           // Array of 12 data registers, each 32 bits wide --> data_reg[0], data_reg[1],......data_reg[11]

// Define the Program Buffer registers as an array
logic [31:0] progBuf [0:15];

