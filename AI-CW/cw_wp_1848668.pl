% True if link L appears on A's wikipedia page
actor_has_link(L,A) :- 
    actor(A), wp(A,WT), wt_link(WT,L).

% Attempt to solve by visiting each oracle in ID order
eliminate(As,A) :-
    As=[A], !
    ;
    my_agent(Agent), get_agent_energy(Agent, Energy), ailp_grid_size(Size),
    say(Energy, Agent),
    (
        Energy >= ((Size * Size) / 4) / 4
        ;
        say("Need to topup real quick", Agent),
        get_agent_position(Agent, P1),
        solve_task_bfs(find(c(Station)), [_:P1:[]],[],[P1|Path]), !,
        agent_do_moves(Agent, Path), agent_topup_energy(Agent, c(Station))
    ),
    get_agent_position(Agent, P),
    findall(Oracle, (
        solve_task_bfs(find(o(Oracle)), [_:P:[]], [], [P | _]),
        \+ agent_check_oracle(Agent, o(Oracle)), !
        ), [Oracle | _]),
    solve_task(find(o(Oracle)),_),
    agent_ask_oracle(Agent,o(Oracle),link,L), 
    include(actor_has_link(L),As,ViableAs), 
    eliminate(ViableAs,A).

% Deduce the identity of the secret actor A
find_identity(A) :- 
    findall(A,actor(A),As), eliminate(As,A)
    ;
    A = unknown.