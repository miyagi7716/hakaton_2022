`timescale 1ns/1ns
    
`define prev_state(ev) $past(ev, 1, 1, @(posedge clk_i))
    
import vendmachine_pkg::*;
module vendmachine_assertions#(
  parameter COIN_STORAGE_VOLUME = 128
)(
  input
          logic         clk_i,
          logic         soft_reset_n_i,
          logic         hard_areset_n_i,
  // Coin interface 
          logic [7:0]   slave_data_coin_i,
          logic         slave_valid_coin_i,
          logic         slave_ready_coin_o,

  // Items pick interface
          logic [7:0]   slave_id_item_i,
          logic         slave_valid_item_i,
          logic         slave_ready_item_o,

  // Items eject interface
          logic [7:0]   master_id_item_o,
          logic         master_valid_item_o,
          logic         master_ready_item_i,
 
  // Exchavvzunin/VERIF_vvzuninnge interface
          logic [7:0]   master_data_exchange_o,
          logic         master_valid_exchange_o,
          logic         master_ready_exchange_i,

  // Internal signals
          State state,
          logic maintenance_reset,
          logic internal_reset,
          logic [2:0] eject_source,
          logic [7:0] current_coin,
          logic [7:0] current_item, // current_item == '1 means coin return request
          logic [7:0] coin_storage[4],
          logic [6:0] item_storage[2][8],
          logic [31:0] exchange,
          logic [31:0] current_balance
); 
      
    //============================================================================= Generating additional signals
    
        logic [2:0] idle_out_cond;
        logic cant_accept_coin;
        logic maintenance_reset;
    
        //--------------------------
    
        logic [3:0] coin_nominal_storage_is_full;
        logic [7:0] current_coin_nominal;
    
        always @ (*) begin
    
            for(int i = 0; i < 4; i++) coin_nominal_storage_is_full[i] = coin_storage[i] >= 128;
    
            case(current_coin)
                8'd1 : current_coin_nominal = RUBBLE;
                8'd2 : current_coin_nominal = TWO_RUBBLES;
                8'd5 : current_coin_nominal = FIVE_RUBBLES;
                8'd10: current_coin_nominal = TEN_RUBBLES;
                8'd18: current_coin_nominal = SERVICE;
                default: current_coin_nominal = INCORRECT;
            endcase
    
            cant_accept_coin = coin_nominal_storage_is_full[current_coin_nominal[1:0]] ||
                              (current_coin_nominal == INCORRECT) || 
                              (current_coin_nominal == SERVICE);
        end
    
        //--------------------------
        logic maintenance_reset_correct;
        assign maintenance_reset_correct = slave_valid_coin_i && slave_ready_coin_o && (slave_data_coin_i == 8'd18);
              
        logic idle_to_maintenance_cond;
        logic slave_coin_handshake;
        logic idle_to_serv_cond;
    
        logic item_storage_is_empty;
        logic coin_storage_is_full;
        logic coin_storage_is_almost_empty;
            
        always_comb begin
          item_storage_is_empty = 1;
          for(int i = 0; i < 8; i++) begin
            item_storage_is_empty = item_storage_is_empty && (item_storage[1][i] == 7'd0);
          end
        end
    
        always_comb begin
          coin_storage_is_full = 1;
          for(int i = 0; i < 4; i++) begin
            coin_storage_is_full = coin_storage_is_full && coin_storage[i] >= 128;
          end
        end
    
        always_comb begin
          coin_storage_is_almost_empty = 1'b0;
          for(int i = 0; i < 4; i++) begin
            coin_storage_is_almost_empty = coin_storage_is_almost_empty || (coin_storage[i] < 8'd10);
          end
        end
    
        assign idle_to_maintenance_cond = item_storage_is_empty ||
                      (coin_storage_is_full && (current_balance == 0)) ||
                      coin_storage_is_almost_empty ||
                      (internal_reset && (current_balance == 0));
    
        assign slave_coin_handshake  = slave_valid_coin_i && slave_ready_coin_o;
        assign slave_item_handshake  = slave_valid_item_i && slave_ready_item_o;
    
        assign idle_to_serv_cond = (coin_storage_is_full && (current_balance != 0)) ||
                            slave_item_handshake || internal_reset;
    
        assign idle_out_cond =  {idle_to_maintenance_cond, slave_coin_handshake, idle_to_serv_cond};   
          //                       1.maintance                2.process            3.serve          // priority
          
          
        assign slave_ready_coin_o_correct = ((state == IDLE) && !( item_storage_is_empty || coin_storage_is_full || coin_storage_is_almost_empty || internal_reset )) ||
                    ((state == MAINTENANCE) && (slave_data_coin_i == 8'd18) && (current_coin != 8'd18));
                    
        State last_state;
        always @(posedge clk_i or negedge hard_areset_n_i)
            last_state <= state;
        
    /// ================================================================== Проверка основных input/output сигналов
        /// soft_reset_n_i == DONE
        soft_reset_n_i_maintenance: assert property(
            @(posedge soft_reset_n_i) disable iff($isunknown(state))
                internal_reset == 1'b1
        ) else $error("soft_reset_n_i_maintenance. internal_reset = %b", internal_reset);
        
        /// hard_areset_n_i == DONE
        hard_areset_n_i_maintenance: assert property(
            @(posedge hard_areset_n_i) disable iff($isunknown(state))
                state == MAINTENANCE
        ) else $error("hard_areset_n_i_maintenance. state = %s", state.name());
        hard_areset_n_i_internal_reset: assert property(
            @(posedge hard_areset_n_i) disable iff($isunknown(state))
                internal_reset == 1'b0
        ) else $error("hard_areset_n_i_internal_reset. internal_reset = %b", internal_reset);
        hard_areset_n_i_eject_source: assert property(
            @(posedge hard_areset_n_i) disable iff($isunknown(state))
                eject_source == 'b0
        ) else $error("hard_areset_n_i_eject_source. eject_source = %d", eject_source);
        hard_areset_n_i_current_coin: assert property(
            @(posedge hard_areset_n_i) disable iff($isunknown(state))
                current_coin == 'b0
        ) else $error("hard_areset_n_i_current_coin. current_coin = %d", current_coin);
        hard_areset_n_i_current_item: assert property(
            @(posedge hard_areset_n_i) disable iff($isunknown(state))
                current_item == 'b0
        ) else $error("hard_areset_n_i_current_item. current_item = %d", current_item);
        hard_areset_n_i_coin_storage: assert property(
            @(posedge hard_areset_n_i) disable iff($isunknown(state))
                (coin_storage[0] == 'b0) && 
                (coin_storage[1] == 'b0) && 
                (coin_storage[2] == 'b0) && 
                (coin_storage[3] == 'b0)
        ) else $error("hard_areset_n_i_coin_storage. coin_storage = %3d %3d %3d %3d ", 
                           coin_storage[0], coin_storage[1], coin_storage[2], coin_storage[3]);
        hard_areset_n_i_item_storage_price: assert property(
            @(posedge hard_areset_n_i) disable iff($isunknown(state))
                  (item_storage[PRICE][0] == 'b0) && 
                  (item_storage[PRICE][1] == 'b0) && 
                  (item_storage[PRICE][2] == 'b0) && 
                  (item_storage[PRICE][3] == 'b0) && 
                  (item_storage[PRICE][4] == 'b0) && 
                  (item_storage[PRICE][5] == 'b0) && 
                  (item_storage[PRICE][6] == 'b0) && 
                  (item_storage[PRICE][7] == 'b0)
        ) else $error("hard_areset_n_i_item_storage_price. item_storage[PRICE] = %3d %3d %3d %3d\n%3d %3d %3d %3d ", 
        item_storage[PRICE][0], item_storage[PRICE][1], item_storage[PRICE][2], item_storage[PRICE][3], 
        item_storage[PRICE][4], item_storage[PRICE][5], item_storage[PRICE][6], item_storage[PRICE][7]);
        hard_areset_n_i_item_storage_count: assert property(
            @(posedge hard_areset_n_i) disable iff($isunknown(state))
                  (item_storage[COUNT][0] == 'b0) &&
                  (item_storage[COUNT][1] == 'b0) &&
                  (item_storage[COUNT][2] == 'b0) &&
                  (item_storage[COUNT][3] == 'b0) &&
                  (item_storage[COUNT][4] == 'b0) &&
                  (item_storage[COUNT][5] == 'b0) &&
                  (item_storage[COUNT][6] == 'b0) &&
                  (item_storage[COUNT][7] == 'b0)
        ) else $error("hard_areset_n_i_item_storage_count. item_storage[COUNT] = %3d %3d %3d %3d\n%3d %3d %3d %3d ", 
        item_storage[COUNT][0], item_storage[COUNT][1], item_storage[COUNT][2], item_storage[COUNT][3], 
        item_storage[COUNT][4], item_storage[COUNT][5], item_storage[COUNT][6], item_storage[COUNT][7]);	
        hard_areset_n_i_current_balance: assert property(
            @(posedge hard_areset_n_i) disable iff($isunknown(state))
                current_balance == 'b0
        ) else $error("hard_areset_n_i_current_balance. current_balance = %d", current_balance);
        hard_areset_n_i_exchange: assert property(
            @(posedge hard_areset_n_i) disable iff($isunknown(state))
                exchange == 'b0
        ) else $error("hard_areset_n_i_exchange. exchange = %d", exchange);
        hard_areset_n_i_maintenance_reset: assert property(
            @(posedge hard_areset_n_i) disable iff($isunknown(state))
                maintenance_reset == 'b0
        ) else $error("hard_areset_n_i_maintenance_reset. maintenance_reset = %b", 
                           maintenance_reset);
            
        /// slave_data_coin_i == DONE
        slave_data_coin_i_is_correct: assert property(
            @(posedge clk_i) disable iff(!hard_areset_n_i)
                (slave_data_coin_i == 0) ||
                (slave_data_coin_i == 1) ||
                (slave_data_coin_i == 2) || 
                (slave_data_coin_i == 5) || 
                (slave_data_coin_i == 10) || 
                (slave_data_coin_i == 18)
        ) else $error("slave_data_coin_i_is_correct. slave_data_coin_i = %d", 
                           slave_data_coin_i);
        
        /// slave_valid_coin_i == DONE
        /// slave_ready_coin_o == DONE
        slave_ready_coin_o_is_correct: assert property(
            @(posedge clk_i) disable iff(!hard_areset_n_i)
                slave_ready_coin_o == slave_ready_coin_o_correct
        ) else $error("slave_ready_coin_o_is_correct. slave_ready_coin_o(%b) != slave_ready_coin_o_correct(%b)", 
                           slave_ready_coin_o, slave_ready_coin_o_correct);
        
        /// slave_id_item_i == DONE
        /// slave_valid_item_i == DONE
        /// slave_ready_item_o == DONE
        lslave_ready_item_o_is_correct: assert property(
            @(posedge clk_i) disable iff(!hard_areset_n_i)
                slave_ready_item_o == ((state == IDLE) && !slave_valid_coin_i)
        ) else $error("lslave_ready_item_o_is_correct. slave_ready_item_o = %b, state = %s, slave_valid_coin_i = %b", 
                           slave_ready_item_o, state.name(), slave_valid_coin_i);
            
        /// master_id_item_o == ...
        /// master_valid_item_o == DONE
        master_valid_item_o_already_true: assert property(
            @(posedge clk_i) disable iff(!hard_areset_n_i)
            master_valid_item_o == (state == SERV)
        ) else $error("master_valid_item_o_already_true. master_valid_item_o = %b, state = %s", 
                           master_valid_item_o, state.name());
        /// master_ready_item_i == DONE
        master_ready_item_i_already_true: assert property(
            @(posedge clk_i) disable iff(!hard_areset_n_i)
            master_ready_item_i == 1'b1
        ) else $error("master_ready_item_i_already_true");
    
        /// master_data_exchange_o == ...
        /// master_valid_exchange_o == DONE
        master_valid_exchange_o_already_true: assert property(
            @(posedge clk_i) disable iff(!hard_areset_n_i)
            master_valid_exchange_o == ((state == EJECT) && (|eject_source))
        ) else $error("master_valid_exchange_o_already_true. master_valid_exchange_o = %b, state = %s, eject_source = %3b",
                           master_valid_exchange_o, state.name(), eject_source);
        /// master_ready_exchange_i == DONE
        master_ready_exchange_i_already_true: assert property(
            @(posedge clk_i) disable iff(!hard_areset_n_i)
            master_ready_exchange_i == 1'b1
        ) else $error("master_ready_exchange_i_already_true");
    
    
    
        
    /// ================================================================================  Check main states
        /// ~~~~~~~~~~~~~~~~~~~~~~~~~~ IDLE
        change_state_to_idle: assert property(
            @(negedge clk_i) disable iff(!hard_areset_n_i)
            state == IDLE |-> (`prev_state(state) == INCREMENT) || 
                              ((`prev_state(state) == EJECT) && (`prev_state(eject_source) == 'd0)) ||
                              ((`prev_state(state) == IDLE) && ((`prev_state(idle_out_cond)) == 'd0))
        ) else $error("change_state_to_idle. Current state (%s) cannot be reached from prev (%s)", 
                           state.name(), last_state.name());
        
        /// ~~~~~~~~~~~~~~~~~~~~~~~~~~ PROCESS
        change_state_to_process: assert property(
            @(negedge clk_i) disable iff(!hard_areset_n_i)
            state == PROCESS |-> (`prev_state(state) == IDLE)
        ) else $error("change_state_to_process. Current state (%s) cannot be reached from prev (%s)", 
                           state.name(), last_state.name());
           
        /// ~~~~~~~~~~~~~~~~~~~~~~~~~~ INCREMENT
        change_state_to_increment: assert property(
            @(negedge clk_i) disable iff(!hard_areset_n_i)
            state == INCREMENT |-> (`prev_state(state) == PROCESS) && (`prev_state(cant_accept_coin) == 1'b0)
        ) else $error("change_state_to_increment. Current state (%s) cannot be reached from prev (%s)", 
                           state.name(), last_state.name());
            
        /// ~~~~~~~~~~~~~~~~~~~~~~~~~~ SERV
        change_state_to_serv: assert property(
            @(negedge clk_i) disable iff(!hard_areset_n_i)
            state == SERV |-> (`prev_state(state) == IDLE) && (`prev_state(idle_out_cond) == 3'b001)
        ) else $error("change_state_to_serv. Current state (%s) cannot be reached from prev (%s)", 
                           state.name(), last_state.name());
           
        /// ~~~~~~~~~~~~~~~~~~~~~~~~~~ MAINTENANCE
        change_state_to_maintenance: assert property(
            @(negedge clk_i) disable iff(!hard_areset_n_i)
            state == MAINTENANCE |-> ((`prev_state(state) == IDLE) && (`prev_state(idle_to_maintenance_cond))) ||
                                     ((`prev_state(state) == MAINTENANCE) && (`prev_state(maintenance_reset) == 1'b0))
        ) else $error("change_state_to_maintenance. Current state (%s) cannot be reached from prev (%s)", 
                           state.name(), last_state.name());
    
        /// ~~~~~~~~~~~~~~~~~~~~~~~~~~ EJECT
        change_state_to_eject: assert property(
            @(negedge clk_i)  disable iff(!hard_areset_n_i)
            state == EJECT |-> ((`prev_state(state) == MAINTENANCE) && (`prev_state(maintenance_reset))) ||
                               ((`prev_state(state) == EJECT) && (`prev_state(eject_source) != 3'b000)) ||
                               (`prev_state(state) == SERV) ||
                               ((`prev_state(state) == PROCESS) && (`prev_state(cant_accept_coin) == 1'b1))		
        ) else $error("change_state_to_eject. Current state (%s) cannot be reached from prev (%s)", 
                           state.name(), last_state.name());
    
        
    ///================================================================================ Проверка internal signals
    
        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // maintenance_reset = DONE
        check_maintenance_reset: assert property(
            @(posedge maintenance_reset) disable iff(!hard_areset_n_i)
            (state == MAINTENANCE) && slave_coin_handshake && (slave_data_coin_i == 8'd18)
        ) else $error("check_maintenance_reset. state = %s, slave_coin_handshake = %b, slave_data_coin_i = %d",
                           state.name(), slave_coin_handshake, slave_data_coin_i);
        
        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // internal_reset = DONE!
    
        change_internal_reset_to_0: assert property(
            @(posedge clk_i) disable iff(!hard_areset_n_i)
            internal_reset == 1'b0 |-> ((`prev_state(state) == MAINTENANCE) || (`prev_state(internal_reset) == 1'b0))
        ) else $error("internal_reset transitioned to 0 for wrong reason");
    
        change_internal_reset_to_1: assert property(
            @(posedge clk_i) disable iff(!hard_areset_n_i)
            internal_reset == 1'b1 |-> ((`prev_state(soft_reset_n_i) == 1'b0) || (`prev_state(internal_reset) == 1'b1))
        ) else $error("internal_reset transitioned to 1 for wrong reason");
        
        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // eject_source[2:0] = ....
    
    
        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // current_coin[7:0] = DONE!
    
        change_current_coin_when_eject: assert property(
            @(posedge clk_i) disable iff(!hard_areset_n_i)
            `prev_state(eject_source[0]) && `prev_state(master_valid_exchange_o) |-> (current_coin == 0) 
        ) else $error("current_coin changed incorrectly at eject");
    
        change_current_coin_insert: assert property(
            @(posedge clk_i) disable iff(!hard_areset_n_i)
            !(`prev_state(eject_source[0]) && `prev_state(master_valid_exchange_o)) && `prev_state(slave_valid_coin_i) && `prev_state(slave_ready_coin_o) |-> (current_coin == `prev_state(slave_data_coin_i)) 
        ) else $error("current_coin changed incorrectly at insert");
    
    
        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // current_item [7:0] = ....
        
        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // coin_storage[3:0][7:0] = ....
    
        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // item_storage[1][7:0][6:0] = ....
    
        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // exchange [31:0] = ....
        
        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // current_balance[31:0] = DONE!
    
        change_current_balance_to_0: assert property(
            @(posedge clk_i) disable iff(!hard_areset_n_i)
            current_balance == 0 |-> ((`prev_state(state) == SERV) || (`prev_state(current_balance) == 0))
        ) else $error("current_balance changed to 0 for wrong reasons");
    
        change_current_balance_changed: assert property(
            @(posedge clk_i) disable iff(!hard_areset_n_i)
            ((current_balance != 0) && (current_balance != `prev_state(current_balance))) |-> ((`prev_state(state) == INCREMENT) && (current_balance == `prev_state(current_balance)) + `prev_state(current_coin))
        ) else $error("current_balance changed to a non zero value for wrong reasons");
    
        /* change_current_balance_at_SERV: assert property(
            @(posedge clk_i) disable iff(!hard_areset_n_i)
            `prev_state(state) == SERV |-> (current_balance == 0)
        ) else $error("current_balance changed incorrectly at SERV");
    
        change_current_balance_at_INCREMENT: assert property(
            @(posedge clk_i) disable iff(!hard_areset_n_i)
            `prev_state(state) == INCREMENT |-> (current_balance == `prev_state(current_balance) + `prev_state(current_coin))
        ) else $error("current_balance changed to a non zero value for wrong reasons");
         */	
         
        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    endmodule
