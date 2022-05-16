`timescale 1ns/1ns
package vendmachine_pkg;
typedef enum logic [1:0] {
  INPUT_COIN  = 2'd0,
  EXCHANGE    = 2'd1,
  STORAGE     = 2'd2
} eject_source_bit;

localparam  PRICE       = 1'b0,
            COUNT       = 1'b1;

typedef enum logic [2:0] {
  RUBBLE      = 3'd0,
  TWO_RUBBLES = 3'd1,
  FIVE_RUBBLES= 3'd2,
  TEN_RUBBLES = 3'd3,
  SERVICE     = 3'd4,
  INCORRECT   = 3'd5
} coin_nominal;

typedef enum logic [2:0] {
  IDLE        = 3'd0,
  PROCESS     = 3'd1,
  INCREMENT   = 3'd2,
  SERV        = 3'd3,
  EJECT       = 3'd4,
  MAINTENANCE = 3'd5
 } State;
endpackage