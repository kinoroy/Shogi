#=networking.jl - Auth: Kino Roy for Shogi, an assignment for CMPT276:
 provides a server on port 8080 where up to two client
may connect to play Shogi.
Current state: accepts starting payload to set game settings, allows users to make
moves with wincode 2, sends move to opponent =#

function getAt(arr, index,backup)
  local res
  try
    res = arr[index]
  catch err
    res = backup
  end
  return res
end

function serverStart()
  global server = listen(8080)
  global settingsSet = false
  global output = ""
  global player1
  global player2
  global whosTurn
  global moveNumber = 1
#  global wincode,sL
  global connections = Dict() #Array(TCPSocket,0)
  listenForClientsTask = Task(listenForClients)
  schedule(listenForClientsTask)
end

function serverClose()
  global server
  for i in values(connections)
    close(i)
  end
  close(server)
end

function listenForClients()
  while true
    local client
    try
      client = accept(server)
    catch
      println("goodbye!")
      close(client)
      break;
    end
    (host,port)=getsockname(client)
    connections[port] = client
    clientCommTask = @task(handleClientComm(client))
    schedule(clientCommTask)
  end
end

function handleClientComm(client)
  (host,port) = getsockname(client)
  message = Array(UInt8,4096)
   while (true)
       bytesRead = 1;
       local wincode,sL
       try
           #blocks until a client sends a message
           message = chomp(readline(client))
           sL = split(message,r":",keep=false)
           wincode = parse(getAt(sL,1,-1))
        #=  (wincode,authString,movenum,movetype,sourcex,sourcey,targetx,targety,option,cheating,
targetx2,targety2) = (getAt(sL,1,-1),getAt(sL,2,-1),getAt(sL,3,-1),getAt(sL,1,-1),getAt(sL,1,-1),getAt(sL,1,-1),
getAt(sL,1,-1),getAt(sL,1,-1),getAt(sL,1,-1),getAt(sL,1,-1))=# #possibly iterate through these size of sL and set or null??
          # write(client,message)
       catch err
         #println("socket error: $err")
           #a socket error has occured
        #   write(client,"e:Readline failed with $err")
           break;
       end
       if (bytesRead == 0) #Doesnt detect

           #the client has disconnected from the server
           println("Player on port $port disconected :(")
           write(client,"e:sorry, player disconected")
           break;
        end
        # message recieved
        global settingsSet
        if wincode == 0 && !settingsSet
          #"<wincode>: <gametype>: <legality>: <timelimit>: <limitadd>"
          (gametype,legality,timelimit,limitadd) = (sL[2],sL[3],sL[4],sL[5])
          global output = "$gametype:$legality:$timelimit:$limitadd"
          #prints to player 1
          #=try
            write(connections[player1],"0:$(player1*10^3):$gametype:$legality:$timelimit:$limitadd")
          catch err
            println("$err")
          end =#
          #prints to player 2

        elseif wincode == 1 #Quit the game
        elseif wincode == 2 #Play a move
          (wincode,authString,movenum,movetype,sourcex,sourcey,targetx,targety,option,cheating,
  targetx2,targety2) = (getAt(sL,1,-1),getAt(sL,2,-1),getAt(sL,3,-1),getAt(sL,4,-1),getAt(sL,5,-1),getAt(sL,6,-1),
  getAt(sL,7,-1),getAt(sL,8,-1),getAt(sL,9,-1),getAt(sL,10,-1),getAt(sL,11,-1),getAt(sL,12,-1))

          if whosTurn == port #check if its the clients turn
            opponent = client == player1 ? player2 : player1
            write(opponent,"9:$movenum:$movetype:$sourcex:$sourcey:$targetx:$targety:$option:$cheating
$targetx2:$targety2") #send move to opponent
          else
          #  println("$whosTurn:$port")
            write(client,"8")
          end
          (host1,port1) = getsockname(player1)
          (host2,port2) = getsockname(player2)
          global whosTurn = port1 == port ? port2 : port1  #After move is made, change the turn
        elseif wincode == 3 #Accuse opponent of cheating

        elseif wincode == 10 #Bad payload

        end
        if !settingsSet
          global settingsSet = true
          bothPlayersConnected = false
          while !(size(collect(keys(connections)))[1]==2) #waits until both players connected
            sleep(.5)
          end
          bothPlayersConnected = size(collect(keys(connections)))[1]==2

          if bothPlayersConnected
            #Roll to determine player 1 and player 2
            player1index = rand([1,2])
            player2index = player1index == 1 ? 2 : 1
            global player1 = collect(values(connections))[player1index]
            global player2 = collect(values(connections))[player2index]
            (host1,port1) = getsockname(player1)
            global whosTurn = port1
            println("$port1:first turn")
            try
              (host1,port1) = getsockname(player1)
              (host2,port2) = getsockname(player2)
                write(player1,"$(player1index-1):$(port1*10^3):$gametype:$legality:$timelimit:$limitadd")
                write(player2,"$(player2index-1):$(port2*10^3):$gametype:$legality:$timelimit:$limitadd")
            catch err
              println("$err")
            end
          end

        end
        #Prints output to all connections
      #= for i in values(connections)
          try
            global output
            write(i,output)
          catch err
            println(err)
            continue
          end
        end=#
     end

end
