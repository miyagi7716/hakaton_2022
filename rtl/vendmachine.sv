`timescale 1ns/1ns
module vendmachine#(
  parameter COIN_STORAGE_VOLUME = 128
)(
  input
          logic         clk_i,
          logic         soft_reset_n_i,
          logic         hard_areset_n_i,
  // Coin interface
          logic [7:0]   slave_data_coin_i,
          logic         slave_valid_coin_i,
  output  logic         slave_ready_coin_o,

  // Items pick interface
  input
          logic [7:0]   slave_id_item_i,
          logic         slave_valid_item_i,
  output  logic         slave_ready_item_o,

  // Items eject interface
          logic [7:0]   master_id_item_o,
          logic         master_valid_item_o,
  input   logic         master_ready_item_i,    // << always must be 1'b1

  // Exchange interface
  output
          logic [7:0]   master_data_exchange_o,
          logic         master_valid_exchange_o,
  input   logic         master_ready_exchange_i // << always must be 1'b1

);

import vendmachine_pkg::*;
State state;
logic internal_reset;
logic maintenance_reset;
logic [2:0] eject_source;

logic [7:0] current_coin;
logic [7:0] current_item; // current_item == '1 means coin return request

logic [7:0] coin_storage[4];

logic [6:0] item_storage[2][8];

logic [31:0] exchange;

logic [31:0] current_balance;
/*
=====================
Internal combinational logic
=====================
*/
logic cant_accept_coin;
logic [6:0] picked_item_price;
logic exchange_can_be_returned;
logic picked_item_is_available;
logic item_can_be_sold;
logic sell_has_been_completed;
logic coin_return_request;
logic [3:0] coin_nominal_storage_is_full;
logic coin_storage_is_full;
logic coin_storage_is_almost_empty;
logic item_storage_is_empty;
logic slave_coin_handshake;
logic slave_item_handshake;
logic master_exhange_handshake;
logic master_item_handshake;
logic idle_to_maintenance_cond;
logic idle_to_serv_cond;
logic [3:0] idle_out_cond;
eject_source_bit current_eject_source;

coin_nominal current_coin_nominal;
coin_nominal max_of_coins_1_2;
coin_nominal min_of_coins_1_2;
coin_nominal max_of_coins_5_10;
coin_nominal min_of_coins_5_10;
coin_nominal max_of_coins_nominal;
coin_nominal pre_max_of_coins_nominal;
coin_nominal min_of_coins_nominal;
coin_nominal pre_min_of_coins_nominal;
coin_nominal cur_exchange_nominal;
coin_nominal cur_storage_nominal;
logic [7:0] max_of_coins_value;
logic [7:0] pre_max_of_coins_value;
logic [7:0] min_of_coins_value;
logic [7:0] pre_min_of_coins_value;
logic [7:0] cur_exchange_value;
logic [7:0] cur_storage_value;

assign cant_accept_coin = coin_nominal_storage_is_full[current_coin_nominal[1:0]] ||
            ((state == PROCESS) && ((current_coin_nominal == INCORRECT) || (current_coin_nominal == SERVICE))) ||
            ((state == MAINTENANCE) && (current_coin_nominal == INCORRECT));

assign picked_item_price = item_storage[PRICE][current_item[2:0]];
assign picked_item_is_available= item_storage[COUNT][current_item[2:0]] > 0;

assign item_can_be_sold = (picked_item_price <= current_balance) &&
                          picked_item_is_available && !coin_storage_is_almost_empty &&
                          (current_item != '1);

assign sell_has_been_completed = (state == SERV) && item_can_be_sold;
assign coin_return_request = current_item == '1;

always_comb begin
  for(int i = 0; i < 4; i++) begin
    coin_nominal_storage_is_full[i] = coin_storage[i] >= COIN_STORAGE_VOLUME;
  end
end

assign coin_storage_is_full = &coin_nominal_storage_is_full;

always_comb begin
  coin_storage_is_almost_empty = 1'b0;
  for(int i = 0; i < 4; i++) begin
    coin_storage_is_almost_empty = coin_storage_is_almost_empty || (coin_storage[i] < 8'd10);
  end
end

always_comb begin
  item_storage_is_empty = 1;
  for(int i = 0; i < 8; i++) begin
    item_storage_is_empty = item_storage_is_empty && (item_storage[COUNT][i] == 7'd0);
  end
end

assign slave_coin_handshake    = slave_valid_coin_i && slave_ready_coin_o;
assign slave_item_handshake    = slave_valid_item_i && slave_ready_item_o;
assign master_exhange_handshake= master_valid_exchange_o;
assign master_item_handshake   = master_valid_item_o;

always_comb begin
  casez(eject_source)
    3'b??1: current_eject_source = INPUT_COIN;
    3'b?10: current_eject_source = EXCHANGE;
    3'b100: current_eject_source = STORAGE;
    default:current_eject_source = INPUT_COIN;
  endcase
end

always_comb begin
  case(current_coin)
    8'd1 : current_coin_nominal = RUBBLE;
    8'd2 : current_coin_nominal = TWO_RUBBLES;
    8'd5 : current_coin_nominal = FIVE_RUBBLES;
    8'd10: current_coin_nominal = TEN_RUBBLES;
    8'd18: current_coin_nominal = SERVICE;
    default: current_coin_nominal = INCORRECT;
  endcase
end

assign max_of_coins_1_2 = coin_storage[RUBBLE] > coin_storage[TWO_RUBBLES] ?
                                RUBBLE : TWO_RUBBLES;
assign min_of_coins_1_2 = max_of_coins_1_2 == RUBBLE?
                                TWO_RUBBLES : RUBBLE;

assign max_of_coins_5_10 = coin_storage[FIVE_RUBBLES] > coin_storage[TEN_RUBBLES] ?
                                  FIVE_RUBBLES : TEN_RUBBLES;
assign min_of_coins_5_10 = max_of_coins_1_2 == FIVE_RUBBLES?
                                  TEN_RUBBLES : FIVE_RUBBLES;

assign max_of_coins_nominal = coin_storage[max_of_coins_1_2] >
                                    coin_storage[max_of_coins_5_10] ?
                                    max_of_coins_1_2 : max_of_coins_5_10;

assign pre_max_of_coins_nominal =
  coin_storage[max_of_coins_1_2] > coin_storage[max_of_coins_5_10] ?
    (coin_storage[min_of_coins_1_2] >= coin_storage[max_of_coins_5_10] ? min_of_coins_1_2 : max_of_coins_5_10) :
    (coin_storage[max_of_coins_1_2] >= coin_storage[min_of_coins_5_10] ? max_of_coins_1_2 : min_of_coins_5_10);

assign min_of_coins_nominal = coin_storage[min_of_coins_1_2] <
                              coin_storage[min_of_coins_5_10] ?
                              min_of_coins_1_2 : min_of_coins_5_10;

assign pre_min_of_coins_nominal =
  coin_storage[min_of_coins_1_2] < coin_storage[min_of_coins_5_10] ?
    (coin_storage[max_of_coins_1_2] <= coin_storage[min_of_coins_5_10] ? max_of_coins_1_2 : min_of_coins_5_10) :
    (coin_storage[min_of_coins_1_2] <= coin_storage[max_of_coins_5_10] ? min_of_coins_1_2 : max_of_coins_5_10);

always_comb begin
  case(max_of_coins_nominal)
    RUBBLE      : max_of_coins_value <= 8'd1;
    TWO_RUBBLES : max_of_coins_value <= 8'd2;
    FIVE_RUBBLES: max_of_coins_value <= 8'd5;
    TEN_RUBBLES : max_of_coins_value <= 8'd10;
    default     : max_of_coins_value <= 8'd0;
  endcase
end

always_comb begin
  case(pre_max_of_coins_nominal)
    RUBBLE      : pre_max_of_coins_value <= 8'd1;
    TWO_RUBBLES : pre_max_of_coins_value <= 8'd2;
    FIVE_RUBBLES: pre_max_of_coins_value <= 8'd5;
    TEN_RUBBLES : pre_max_of_coins_value <= 8'd10;
    default     : pre_max_of_coins_value <= 8'd0;
  endcase
end

always_comb begin
  case(min_of_coins_nominal)
    RUBBLE      : min_of_coins_value <= 8'd1;
    TWO_RUBBLES : min_of_coins_value <= 8'd2;
    FIVE_RUBBLES: min_of_coins_value <= 8'd5;
    TEN_RUBBLES : min_of_coins_value <= 8'd10;
    default     : min_of_coins_value <= 8'd0;
  endcase
end

always_comb begin
  case(pre_min_of_coins_nominal)
    RUBBLE      : pre_min_of_coins_value <= 8'd1;
    TWO_RUBBLES : pre_min_of_coins_value <= 8'd2;
    FIVE_RUBBLES: pre_min_of_coins_value <= 8'd5;
    TEN_RUBBLES : pre_min_of_coins_value <= 8'd10;
    default     : pre_min_of_coins_value <= 8'd0;
  endcase
end


always_comb begin
  if(exchange >= max_of_coins_value) begin
    cur_exchange_nominal <= max_of_coins_nominal;
  end
  else if(exchange >= pre_max_of_coins_value) begin
    cur_exchange_nominal <= pre_max_of_coins_nominal;
  end
  else if(exchange >= pre_min_of_coins_value) begin
    cur_exchange_nominal <= pre_min_of_coins_nominal;
  end
  else begin
    cur_exchange_nominal <= min_of_coins_nominal;
  end

end

always_comb begin
  if(coin_storage[TEN_RUBBLES] != 8'd0) begin
    cur_storage_nominal = TEN_RUBBLES;
  end
  else if(coin_storage[FIVE_RUBBLES] != 8'd0)begin
    cur_storage_nominal = FIVE_RUBBLES;
  end
  else if(coin_storage[TWO_RUBBLES] != 8'd0) begin
    cur_storage_nominal = TWO_RUBBLES;
  end
  else begin
    cur_storage_nominal = RUBBLE;
  end
end

always_comb begin
  case(cur_exchange_nominal)
    RUBBLE      : cur_exchange_value <= 8'd1;
    TWO_RUBBLES : cur_exchange_value <= 8'd2;
    FIVE_RUBBLES: cur_exchange_value <= 8'd5;
    TEN_RUBBLES : cur_exchange_value <= 8'd10;
    SERVICE     : cur_exchange_value <= 8'd18;
    default     : cur_exchange_value <= 8'd0;
  endcase
end

always_comb begin
  case(cur_storage_nominal)
    RUBBLE      : cur_storage_value <= 8'd1;
    TWO_RUBBLES : cur_storage_value <= 8'd2;
    FIVE_RUBBLES: cur_storage_value <= 8'd5;
    TEN_RUBBLES : cur_storage_value <= 8'd10;
    default     : cur_storage_value <= 8'd0;
  endcase
end

assign idle_to_maintenance_cond = item_storage_is_empty ||
                            (coin_storage_is_full && (current_balance == 0)) ||
                            coin_storage_is_almost_empty ||
                            (internal_reset && (current_balance == 0));

assign idle_to_serv_cond = (coin_storage_is_full && (current_balance != 0)) ||
                            slave_item_handshake || internal_reset;

assign idle_out_cond = {idle_to_maintenance_cond, slave_coin_handshake,
                        idle_to_serv_cond};
/*
=====================
Internal synchronous logic
=====================
*/

/*
  Переход между состояниями организован в соответствии с графом переходов в
  спецификации.
  Важно отметить приоритет при переходе из состояния Idle:
  В первую очередь, если дальнейшие продажи невозможны (закончился товар или
  сдача, не осталось места для других монет или выполнился программный сброс при
  нулевом депоизте), происходит переход в состояние Maintenance.
  Следующим состоянием в приоритете стоит обработка опущенной монеты и в
  последнюю очередь происходит переход в Serv.
  Логика интерфейсов axi stream построена так, чтобы не происходило одновременных
  транзакций по интерфейсам item/coin, если автомат видит valid на интерфейсе
  монет, он опускает ready интерфейса товаров.
*/
always_ff @(posedge clk_i or negedge hard_areset_n_i) begin
  if(!hard_areset_n_i) begin
    state <= MAINTENANCE;
  end
  else begin
    case(state)
      IDLE        : begin
        casez(idle_out_cond)
          3'b1??: state <= MAINTENANCE;
          3'b01?: state <= PROCESS;
          3'b001: state <= SERV;
          3'b000: state <= IDLE;
        endcase
      end
      PROCESS     : begin
        if(cant_accept_coin) begin
          state <= EJECT;
        end
        else begin
          state <= INCREMENT;
        end
      end
      INCREMENT   : begin
        state <= IDLE;
      end
      SERV        : begin
        state <= EJECT;
      end
      EJECT       : begin
        if(eject_source != 0) begin
          state <= EJECT;
        end
        else begin
          state <= IDLE;
        end
      end
      MAINTENANCE : begin
        if(maintenance_reset) begin
          state <= EJECT;
        end
        else begin
          state <= MAINTENANCE;
        end
      end
      default     : begin
        state <= MAINTENANCE;
      end
    endcase
  end
end

/*
  Внутренний сигнал сброса. Используется для перехода в состояние Maintenance из
  состояния Idle при нулевом депозите. Взводится в 1 при приходе сигнала
  soft_reset_n по тактовому сигналу, опускается в 0 из состояния Maintenance.
*/
always_ff @(posedge clk_i or negedge hard_areset_n_i) begin
  if(!hard_areset_n_i) begin
    internal_reset <= 1'b0;
  end
  else if(state == MAINTENANCE) begin
    internal_reset <= 1'b0;
  end
  else if(!soft_reset_n_i) begin
    internal_reset <= 1'b1;
  end
  else begin
    internal_reset <= internal_reset;
  end
end

/*
  Сигнал источников для выдачи монет.
  Источников выдачи три: INPUT_COIN, EXCHANGE, STORAGE.
  В первую очередь, выдаётся только что опущенная монета, если таковое требуется.
  Это может произойти в следующих случаях:
  * будучи в состоянии Idle опустили монету неподходящего номинала;
  * находясь в состоянии Maintenance опустили сервисную монету номиналом 18
  (монеты всех 4х номиналов);
  * опустили монету, под которую в хранилище уже нет места.
  Во всех случаях, при попадании в состояние Eject, автомат вернет такие монеты.
  Поскольку для возврата монеты требуется одна транзакция, и возврат монеты имеет
  высший приоритет в выдаче, по переходу в состояние Eject, этот источник можно
  сразу же сбрасывать.
  Источник EXCHANGE используется для возврата депозита пользователя, либо выдачи
  сдачи. Возврат депозита может произойти по многим причинам:
  * Запрос от пользователя (выбран товар с id 8'b1111_1111);
  * Стоимость выбранного пользователем товара превышает имеющийся ненулевой
    депозит или же выбранный товар закончился (опять же, при ненулевом депозите);
  * Во время пополнения депозита хранилище монет переполнилось (однако, если
    сразу после перехода в состояние Idle, пользователь выберет товар, автомат
    произведет попытку его выдачи, в противном случае на следующий такт
    произойдет возврат депозита);
  * Если произошел программный сброс при ненулевом депозите.
  Сдача выдаётся после успешного завершения покупки, выдавая разницу между
  депозитом и стоимостью выданного товара.
  Последним источником является STORAGE — опустошение хранилища работником.
  Источник взводится при переходе в состояние Maintenance.
*/
always_ff @(posedge clk_i or negedge hard_areset_n_i) begin
  if(!hard_areset_n_i) begin
    eject_source = 3'b0;
  end
  else begin
    case(state)
      MAINTENANCE : begin
        eject_source[STORAGE] <= 1'b1;
        eject_source[INPUT_COIN] <= 1'b1;
      end
      PROCESS     : begin
        if(cant_accept_coin) begin
          eject_source[INPUT_COIN] <= 1'b1;
        end
      end
      SERV        : eject_source[EXCHANGE] <=
        (sell_has_been_completed && (current_balance - item_storage[PRICE][current_item]) != 0) ||
        (!sell_has_been_completed && (current_balance != 0));
      EJECT       : begin
        eject_source[INPUT_COIN]<= 1'b0;
        eject_source[EXCHANGE]  <= (exchange <= cur_exchange_value) &&
                                      (current_eject_source == EXCHANGE) ?
                                          1'b0 : eject_source[EXCHANGE];
        /*
          Рублевые монеты возвращаются при опустошении хранилища в последнюю очередь
          если coin_storage[RUBBLE] <= 1 -- значит сейчас идет последняя транзакция
          по опустошению хранилища, либо произошел аппаратный сброс и регистр пуст.
        */
        eject_source[STORAGE]   <= coin_storage[RUBBLE] <= 1 ? 1'b0 : eject_source[STORAGE];
      end
      default: eject_source <= eject_source;
    endcase
  end
end


/*
  Регистр, хранящий значение текущей опущенной монеты. В случае возврата монеты,
  регистр очищается.
*/
always_ff @(posedge clk_i or negedge hard_areset_n_i) begin
  if(!hard_areset_n_i) begin
    current_coin <= 8'd0;
  end
  else begin
    if(eject_source[INPUT_COIN] && master_exhange_handshake) begin
      current_coin <= 8'd0;
    end
    else if(slave_coin_handshake) begin
      current_coin <= slave_data_coin_i;
    end
    else begin
      current_coin <= current_coin;
    end
  end
end

/*
  Регистр, хранящий выбранный товар. В случае выдачи товара, регистр очищается,
  в случае переполнения хранилища при ненулевом балансе или аппаратном сбросе,
  имитируется выбор пользователем опции "возврат монет".
*/
always_ff @(posedge clk_i or negedge hard_areset_n_i) begin
  if(!hard_areset_n_i) begin
    current_item <= 8'd0;
  end
  else begin
    if(master_item_handshake) begin
      current_item <= 8'd0;
    end
    else if(slave_item_handshake) begin
      current_item <= slave_id_item_i;
    end
    else if((state == IDLE) &&
        ((coin_storage_is_full && (current_balance != 0)) || internal_reset)) begin
      current_item <= '1;
    end
    else begin
      current_item <= current_item;
    end
  end
end


/*
  Хранилище монет. При опускании монеты подходящего номинала, хранилище
  пополняется, во время выдачи сдачи или опустошения хранилища сотрудником, оно
  опустевает, по одной монете за транзакцию.
  После опустошения хранилища по запросу из Maintenance, хранилище автоматически
  пополняется двадцатью монетами каждого номинала.
  Если в автомате находится менее 10 монет какого-либо номинала, автомат считает
  себя не способным выдать сдачу и переходит в состояние Maintenance.
*/
always_ff @(posedge clk_i or negedge hard_areset_n_i) begin
  if(!hard_areset_n_i) begin
    for(int i = 0; i < 4; i++) begin
      coin_storage[i] <= '0;
    end
  end
  else if(state == INCREMENT) begin
    coin_storage[current_coin_nominal] <= coin_storage[current_coin_nominal] + 1'b1;
  end
  else if((state == EJECT) && master_exhange_handshake) begin
    case(current_eject_source)
      EXCHANGE: coin_storage[cur_exchange_nominal ] <= coin_storage[cur_exchange_nominal] - 1'b1;
      STORAGE : coin_storage[cur_storage_nominal  ] <= coin_storage[cur_storage_nominal ] - 1'b1;
    endcase
  end
  else if((state == EJECT) && (eject_source == 3'd0) && maintenance_reset) begin
    for(int i = 0; i < 4; i++) begin
      coin_storage[i] <= coin_storage[i] + 8'd20;
    end
  end
end

/*
  Хранилище товаров. В рабочем состоянии, содержимое может только уменьшаться.
  Пополнение происходит только при сбросе из состояния Maintenance.
*/
always_ff @(posedge clk_i or negedge hard_areset_n_i) begin
  if(!hard_areset_n_i) begin
    for(int i = 0; i < 8; i++) begin
      item_storage[PRICE][i] <= 7'd0;
      item_storage[COUNT][i] <= 7'd0;
    end
  end
  else begin
    if(sell_has_been_completed) begin
      item_storage[COUNT][current_item] <= item_storage[COUNT][current_item] - 1'b1;
    end
    else if((state == EJECT) && (eject_source == 3'd0) && maintenance_reset) begin
      $readmemh("price_list.mem",item_storage);
    end
    else begin
      for(int i = 0; i < 8; i++) begin
        item_storage[COUNT][i] <= item_storage[COUNT][i];
      end
    end
  end
end

/*
  Текущий депозит. Увеличивается при попадании в состояние Increment. По переходу
  в состояние Serv обнуляется, т.к. вне зависимости от того, совершится покупка
  или нет, будет либо выдан товар со сдачей или без, либо возвращён депозит.
*/
always_ff @(posedge clk_i or negedge hard_areset_n_i) begin
  if(!hard_areset_n_i) begin
    current_balance <= 32'd0;
  end
  else begin
    if(state == INCREMENT) begin
      current_balance <= current_balance + current_coin;
    end
    else if(state == SERV) begin
      current_balance <= 32'd0;
    end
    else begin
      current_balance <= current_balance;
    end
  end
end

/*
  Регистр сдачи. Используется как при выдачи сдачи, так и при возврате депозита.
  В случае совершения продажи, вычисляется разность между стоимостью товара и
  депозитом, в противном случае, приравнивается депозиту. Приравнивание к
  депозиту происходит и в случае программного сброса.
  Сдача не может оказаться меньше нуля (либо очень большим положительным числом),
  поэтому даже если произошло страшное, и автомат выдал товар на стоимость,
  большую депозиту, сдача выдана не будет.
  Во время этапа выдачи монет, уменьшается на соответствующий выдаваемой монете
  номинал.
*/
always_ff @(posedge clk_i or negedge hard_areset_n_i) begin
  if(!hard_areset_n_i) begin
    exchange <= '0;
  end
  else begin
    case(state)
      SERV: begin
        if(sell_has_been_completed) begin
          exchange <= current_balance >= item_storage[PRICE][current_item] ?
                        current_balance - item_storage[PRICE][current_item] : 0;
        end
        else begin
          exchange <= current_balance;
        end
      end
      EJECT: begin
        if(master_exhange_handshake && (current_eject_source == EXCHANGE)) begin
          exchange <= exchange >= master_data_exchange_o ?
                        exchange - master_data_exchange_o : 0;
        end
      end
      default: exchange <= exchange;
    endcase
  end
end

always_ff @(posedge clk_i or negedge hard_areset_n_i) begin
  if(!hard_areset_n_i) begin
    maintenance_reset <= 1'b0;
  end
  else begin
    if((state == MAINTENANCE) &&
        slave_coin_handshake && (slave_data_coin_i == 8'd18)) begin
      maintenance_reset <= 1'b1;
    end
    else if((state == EJECT) && (eject_source == 3'd0)) begin
      maintenance_reset <= 1'b0;
    end
    else begin
      maintenance_reset <= maintenance_reset;
    end
  end
end

/*
=====================
Interfaces logic
=====================
*/

assign slave_ready_coin_o = ((state == IDLE) && !(
 item_storage_is_empty || coin_storage_is_full || coin_storage_is_almost_empty || internal_reset )) ||
  ((state == MAINTENANCE) && (slave_data_coin_i == 8'd18) && (current_coin != 8'd18));
assign slave_ready_item_o = (state == IDLE) && !slave_valid_coin_i;

assign master_id_item_o   = item_can_be_sold || coin_return_request ? current_item : -8'd2;
assign master_valid_item_o= state == SERV;

always_comb begin
  case(current_eject_source)
    INPUT_COIN: master_data_exchange_o = current_coin;
    EXCHANGE  : master_data_exchange_o = cur_exchange_value;
    STORAGE   : master_data_exchange_o = cur_storage_value;
    default   : master_data_exchange_o = current_coin;
  endcase
end

assign master_valid_exchange_o = (state == EJECT) && (|eject_source);

endmodule
