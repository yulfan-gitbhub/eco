proc disable_clk_mesh_buf {clk_mesh_nets} {
    global P
    foreach_in_coll clock_mesh_net [get_net "$clk_mesh_nets"] {
      set drv_of_net [sort_collection [filter_collection [all_conn -leaf $clock_mesh_net] "direction == out"] "full_name"]
      set net_name [get_attr $clock_mesh_net full_name]
      if [sizeof $drv_of_net] {
           set used_drv [index_collection $drv_of_net 0]
           set remain_drv [remove_from_collection $drv_of_net $used_drv]
           puts "#Leave [get_attr $used_drv full_name] as the driver of $net_name"
           set in_pin [get_attr [get_pins -of [get_cell -of $used_drv ] -f "direction == in"] full_name]
           set out_pin [get_attr [get_pins -of [get_cell -of $used_drv ] -f "direction == out"] full_name]
           puts "#set_disable_timing \[ get_timing_arcs -from \[ get_pins $in_pin \] -to \[ get_pins $out_pin \]\]"
           # record the used driver pin for later use, the MESH TMAC driver cell delay should be annotated to 0 as CES delay includes this
           lappend P(TMAC_ENABLED_PIN) $out_pin
           foreach_in_collection to_disable $remain_drv {
               set cell_name [get_attr [get_cell -of $to_disable] full_name]
               set in_pin [get_attr [get_pins -of $cell_name -f "direction == in"] full_name]
               set out_pin [get_attr [get_pins -of $cell_name -f "direction == out"] full_name]
               puts "set_disable_timing \[get_timing_arcs -from \[get_pins $in_pin\] -to \[get_pins $out_pin \]\]"
               set_disable_timing [get_timing_arcs -from [get_pins $in_pin] -to [get_pins $out_pin ]]
               lappend P(TMAC_DISABLE_PIN) $out_pin
           }
        }
        puts ""
    }
}
