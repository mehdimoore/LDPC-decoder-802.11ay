`include "../../LDPC_Params/LDPC_Params.svh"
module FSM_Engine(
    input  logic                         clk,
    input  logic                         reset,
    input  logic                         llrInLast,
    input  logic                         validIn,
    input  logic [WIDTH_RATE-1:0]        rate,
    input  logic [WIDTH_ITERATION-1 : 0] iterMax,
    input  logic                         syndrome,
    output logic [WIDTH_LAYER-1 : 0]     CurrLayer,
    output logic [WIDTH_ITERATION-1 : 0] CurrIter,
    
    output logic                         CopyLLRIn2LLRNew,
    output logic                         ChkNInputValid,
    output logic                         VarNInputValid
  );

  // used in FSM engine
  enum logic [WIDTH_STATE_FSM_ENG-1:0]{
         state_idle,
         state_copy_L2L,
         state_chkN_proc_L0,
         state_chkN_proc_L1,
         state_chkN_proc_L2,
         state_chkN_proc_L3,
         state_chkN_proc_L4,
         state_chkN_proc_L5,
         state_chkN_proc_L6,
         state_chkN_proc_L7,
         state_varN_proc
       } state, next_state;


  always_ff @(negedge clk)begin
    if (reset) state <= state_idle;
    else       state <= next_state;
  end

  // state transition logics
  logic       idle_TO_copy;
  logic       L0_TO_L1;
  logic       L1_TO_L2;
  logic       L2_TO_L3;
  logic       L3_TO_L4;
  logic       L4_TO_L5;
  logic       L5_TO_L6;
  logic       L6_TO_L7;
  logic       L7_TO_varNproc;
  logic       varNproc_TO_L0;
  logic [2:0] cnt_CHKN_proc[0:7];  // TODO: proper value instead of 2
  logic [2:0] cnt_VN_proc;  // TODO: proper value instead of 2
  always@* begin
    if (rate == rate_1_2 )begin
      idle_TO_copy     = validIn & llrInLast;
      L0_TO_L1         = (cnt_CHKN_proc[0] == 4);  //seems needs minimum 4
      L1_TO_L2         = (cnt_CHKN_proc[1] == 4);
      L2_TO_L3         = (cnt_CHKN_proc[2] == 4);
      L3_TO_L4         = (cnt_CHKN_proc[3] == 4);
      L4_TO_L5         = (cnt_CHKN_proc[4] == 4);
      L5_TO_L6         = (cnt_CHKN_proc[5] == 4);
      L6_TO_L7         = (cnt_CHKN_proc[6] == 4);
      L7_TO_varNproc   = (cnt_CHKN_proc[7] == 4);
      varNproc_TO_L0   = (cnt_VN_proc      == 1 );

    end
  end


  always@* begin
    case(state)
      //
      default: //state_idle:
      begin
        CurrLayer = 0;
        if (idle_TO_copy) begin
          next_state             = state_copy_L2L;
        end else begin
          next_state             = state_idle;
        end
      end
      //
      state_copy_L2L:
      begin
        CurrLayer = 0;
        if (CopyLLRIn2LLRNew) next_state        = state_chkN_proc_L0;
        else                next_state        = state_copy_L2L;
      end
      //
      state_chkN_proc_L0:
      begin
        CurrLayer = 0;
        if (syndrome == 1'b0 | CurrIter>iterMax)
          next_state                        = state_idle;//      put final state here
        else if(L0_TO_L1)
          next_state                        = state_chkN_proc_L1;
        else
          next_state                        = state_chkN_proc_L0;
      end
      //
      state_chkN_proc_L1:
      begin
        CurrLayer = 1;
        if (L1_TO_L2)  next_state             = state_chkN_proc_L2;
        else           next_state             = state_chkN_proc_L1;
      end
      //
      state_chkN_proc_L2:
      begin
        CurrLayer = 2;
        if (L2_TO_L3)  next_state             = state_chkN_proc_L3;
        else           next_state             = state_chkN_proc_L2;
      end
      //
      state_chkN_proc_L3:
      begin
        CurrLayer = 3;
        if (L3_TO_L4)  next_state             = state_chkN_proc_L4;
        else           next_state             = state_chkN_proc_L3;
      end
      //
      state_chkN_proc_L4:
      begin
        CurrLayer = 4;
        if (L4_TO_L5)  next_state             = state_chkN_proc_L5;
        else           next_state             = state_chkN_proc_L4;
      end
      //
      state_chkN_proc_L5:
      begin
        CurrLayer = 5;
        if (L5_TO_L6)  next_state             = state_chkN_proc_L6;
        else           next_state             = state_chkN_proc_L5;
      end
      //
      state_chkN_proc_L6:
      begin
        CurrLayer = 6;
        if (L6_TO_L7)  next_state             = state_chkN_proc_L7;
        else           next_state             = state_chkN_proc_L6;
      end
      //
      state_chkN_proc_L7:
      begin
        CurrLayer = 7;
        if (L7_TO_varNproc)  next_state       = state_varN_proc;
        else               next_state         = state_chkN_proc_L7;
      end
      //
      state_varN_proc:
      begin
        CurrLayer = 7;   //TODO should be 0 or 7?
        if (varNproc_TO_L0)         next_state = state_chkN_proc_L0;
        else                        next_state = state_varN_proc;
      end
    endcase
  end

  always@(posedge clk)begin
    if (reset) begin
      for (integer idx = 0; idx < NUM_LAYERS; idx++)begin
        cnt_CHKN_proc[idx]                    <= '0;
      end
      cnt_VN_proc                               <= '0;
      ChkNInputValid                            <= 1'b0;
      VarNInputValid                            <= 1'b0;
      CurrIter                                  <= '0;
    end else begin
      case (state)
        //
        default: //state_idle:
        begin
          CopyLLRIn2LLRNew                  <= 1'b0;
          ChkNInputValid                    <= 1'b0;
          CurrIter                          <= '0;
        end
        //
        state_copy_L2L:
        begin
          CopyLLRIn2LLRNew                  <= 1'b1;
          ChkNInputValid                    <= 1'b0;
          for (integer idx = 0; idx < NUM_LAYERS; idx++)begin
            cnt_CHKN_proc[idx]            <= '0;
          end
        end
        //
        state_chkN_proc_L0:
        begin
          if (cnt_CHKN_proc[0] == 0) begin
            ChkNInputValid                <= 1'b1;
            CurrIter                      <= CurrIter + 1;
            cnt_VN_proc                   <= '0;
          end else begin
            ChkNInputValid                <= 1'b0;
          end
          CopyLLRIn2LLRNew                  <= 1'b0;
          cnt_CHKN_proc[0]                  <= cnt_CHKN_proc[0] + 1'b1;
          VarNInputValid                    <= 1'b0;
        end
        //
        state_chkN_proc_L1:
        begin
          ChkNInputValid                    <= (cnt_CHKN_proc[1] == 0)? 1'b1 :  1'b0;
          CopyLLRIn2LLRNew                      <= 1'b0;
          cnt_CHKN_proc[1]                  <= cnt_CHKN_proc[1] + 1'b1;
        end
        //
        state_chkN_proc_L2:
        begin
          ChkNInputValid                    <= (cnt_CHKN_proc[2] == 0)? 1'b1 :  1'b0;
          CopyLLRIn2LLRNew                      <= 1'b0;
          cnt_CHKN_proc[2]                  <= cnt_CHKN_proc[2] + 1'b1;
        end
        //
        state_chkN_proc_L3:
        begin
          ChkNInputValid                    <= (cnt_CHKN_proc[3] == 0)? 1'b1 :  1'b0;
          CopyLLRIn2LLRNew                      <= 1'b0;
          cnt_CHKN_proc[3]                  <= cnt_CHKN_proc[3] + 1'b1;
        end
        //
        state_chkN_proc_L4:
        begin
          ChkNInputValid                    <= (cnt_CHKN_proc[4] == 0)? 1'b1 :  1'b0;
          CopyLLRIn2LLRNew                      <= 1'b0;
          cnt_CHKN_proc[4]                  <= cnt_CHKN_proc[4] + 1'b1;
        end
        //
        state_chkN_proc_L5:
        begin
          ChkNInputValid                    <= (cnt_CHKN_proc[5] == 0)? 1'b1 :  1'b0;
          CopyLLRIn2LLRNew                  <= 1'b0;
          cnt_CHKN_proc[5]                  <= cnt_CHKN_proc[5] + 1'b1;
        end
        //
        state_chkN_proc_L6:
        begin
          ChkNInputValid                    <= (cnt_CHKN_proc[6] == 0)? 1'b1 :  1'b0;
          CopyLLRIn2LLRNew                  <= 1'b0;
          cnt_CHKN_proc[6]                  <= cnt_CHKN_proc[6] + 1'b1;
        end
        //
        state_chkN_proc_L7:
        begin
          ChkNInputValid                    <= (cnt_CHKN_proc[7] == 0)? 1'b1 :  1'b0;
          CopyLLRIn2LLRNew                  <= 1'b0;
          cnt_CHKN_proc[7]                  <= cnt_CHKN_proc[7] + 1'b1;
        end
        //
        state_varN_proc:
        begin
          VarNInputValid                    <= 1'b1;
          cnt_VN_proc                       <= cnt_VN_proc + 1'b1;
          CopyLLRIn2LLRNew                  <= 1'b0;
          ChkNInputValid                    <= 1'b0;
          for (integer idx = 0; idx < NUM_LAYERS; idx++)begin
            cnt_CHKN_proc[idx]            <= '0;
          end
        end
      endcase
    end
  end



endmodule
