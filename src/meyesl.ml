(** Module for scanning function *)
module Scanner = struct

  (* attempt to open a port and return an option *)
  let open_port target port timeout = fun () -> 
    let open Lwt.Infix in
    let sockaddr = Unix.ADDR_INET (Unix.inet_addr_of_string target, port) in
    let socket = Lwt_unix.socket Unix.PF_INET Unix.SOCK_STREAM 0 in
    Lwt.catch
      (* Port is open *)
      (fun () ->
        Lwt_unix.connect socket sockaddr >>= fun () ->
        Lwt_unix.close socket >>= fun () ->
        Lwt.return (Some port) 
      )
      (* Port is closed *)
      (fun _ ->
        Lwt_unix.close socket >>= fun () ->
        Lwt.return None 
      )

  (* scans a port by trying to open it or timing out *)
  let scan_port target port timeout =
    let open Lwt.Infix in
    let connect_task = open_port target port timeout in
    (*let timeout_task = Lwt_unix.sleep timeout >>= fun () -> Lwt.fail Lwt_unix.Timeout in*)
    let timeout_task = Lwt_unix.sleep timeout >>= fun () -> Lwt.fail Lwt.Canceled in
    Lwt.pick [connect_task (); timeout_task] >>= function
    | Some port -> Lwt.return (Some port)
    | None -> Lwt.return None

  (* scans a range of port *)
  let scan_ports target ports timeout =
    let open Lwt.Infix in
    let scan_results =
      List.map (fun port ->
        scan_port target port timeout >>= function 
        | Some port -> Printf.printf "Port %d is open\n" port; Lwt.return ()
        | None -> Printf.printf "Port %d is closed\n" port; Lwt.return ()
      ) ports
    in
    Lwt.join scan_results

end


(** Module for handling CLI args *)
module Cli = struct
  module C = Cmdliner

  let default_ports = [3000; 8000; 8080]

  (* Converts user-provided description of ports into list of unique numbers

     Ports can be expressed as:
       * list of numbers: `meyesl <target> -p 22,80,1336`
       * range of numbers: `meyesl <target> -p 22-80`
       * mix of both: `meyesl <target> -p 22,80,8000-8099,443,8443,3000-3443`
   *)
  let parse_ports input =
    let parse_range range_str =
      try
        let parts = String.split_on_char '-' range_str in
        match parts with
        | [start_str; end_str] ->
          let start = int_of_string start_str in
          let finish = int_of_string end_str in
          if start <= finish then
            Some (List.init (finish - start + 1) (fun i -> start + i))
          else
            Some (List.init (start - finish + 1) (fun i -> finish + i))
        | _ -> None
      with _ -> None
    in
    try
      let ports = String.split_on_char ',' input in
      let all_ports = List.fold_left (fun acc port ->
        match parse_range port with
        | Some range -> acc @ range
        | None -> acc @ [int_of_string port]
      ) [] ports in
      Some all_ports
    with _ -> None

  (* <target> *)
  let target = 
    let docv = "TARGET" in
    let doc = "The target to scan." in
    C.Arg.(required & pos 0 (some string) None & info [] ~docv ~doc)

  (* --ports <arg> *)
  let ports = 
    let docv = "PORTS" in
    let doc = "List of ports to scan." in
    C.Arg.(value & opt (some string) None & info ["p"; "ports"] ~docv ~doc)

  (* --timeout <arg> *)
  let timeout = 
    let docv = "TIMEOUT" in
    let doc = "Connection timeout (default is 2.0)." in
    C.Arg.(value & opt float 3.0 & info ["t"; "timeout"] ~docv ~doc)

  (* Does the conversion of CLI params into scan params and then uses the
     Scanner module to perform a scan.
   *)
  let scan_action target ports timeout =
    let open Lwt.Infix in
    let ports_to_scan =
      match ports with
      | Some port_str -> (
        match parse_ports port_str with
        | Some ports -> ports
        | None -> default_ports 
      )
      | None -> default_ports 
    in
    Lwt_main.run (
      Scanner.scan_ports target ports_to_scan timeout >>= fun () -> 
      Lwt.return ()
    )

  (* Parse the CLI params and pass them into scan_action *)
  let cmd =
    C.Term.(const scan_action $ target $ ports $ timeout)
end


(** Main function parses the CLI params and runs the scans *)
let () =
  let version = "v3.1415" in
  let doc = "A simple port scanner written in OCaml. Hack the planet." in
  let info = Cmdliner.Cmd.info "meyesl" ~version ~doc in
  exit @@ Cmdliner.Cmd.eval @@ Cmdliner.Cmd.v info Cli.cmd 

