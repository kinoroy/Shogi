#=display.jl - will replay the game
from start to finish, displaying the current game state.
Accepts 1 command line argument,<filename> => database
=#
include("square.jl")
include("start.jl")
using ST
module display
pathToDatabase = ARGS[1]
db = SQLite.DB(pathToDatabase) #Opens the database gamefile
#calculates all black piece positions

#=----Gets last move number----=#
res = SQLite.query(db,"SELECT MAX(move_number) FROM moves;") #Finds the last played move (maximum move_number)
lastMoveIDNullable = res[1,1] #SQL query with max move_number (POSSIBLY "NULL" if no moves have been made)

if (!isnull(lastMoveIDNullable)) #Checks that lastMoveID was not NULL
lastMoveID = get(res[1,1]) #Parses the last move move_number as an Int

else #lastMoveID is NULL
lastMoveID = 0 #move_number "0" is unsused. This implies no moves have been made

end
currentMoveID=1
#=----Replays the game until move_id = lastMoveID----=#
while currentMoveID<=lastMoveID
  res = SQLite.query(db,"SELECT sourcex,sourcey,targetx,targety,move_type,option FROM moves WHERE move_id = $(currentMoveID);")
  sourcexNullable = res[1][1]
  sourceyNullable = res[1][2]
  targetxNullable = res[1][3]
  targetyNullable = res[1][4]
  move_type = get(res[1][5])
  optionNullable = res[1][6]

  if move_type == "move" #Regular Move
    targetx = get(targetxNullable)
    targety = get(targetyNullable)
    sourcex = get(sourcexNullable)
    sourcey = get(sourceyNullable)
    if !(isEmpty(board[targetx][targety]))# capture
      #push(captures,board[targetx][targety])
    end
    board[targetx][targety].piece = board[sourcex][sourcey].piece
    board[targetx][targety].team = board[sourcex][sourcey].team
    clear!(board[sourcex][sourcey])

  elseif move_type == "drop"
    option = get(optionNullable)
    try
      #deleteat!(captures,findfirst(x->x.piece==option))
    end
    targetx = get(targetxNullable)
    targety = get(targetyNullable)
    board[targetx][targety].piece = board[sourcex][sourcey].piece
    board[targetx][targety].team = board[sourcex][sourcey].team
  elseif move_type == "resign"
    #Do nothing
  end
  ST.saveBoard(board)
  if gameType == "standard"
    display()
  else
    displayminishogi()
  end
  sleep(500) #Waits half a second before running displaying a new board
end

function displayminishogi()
  board = ST.loadBoard()
  global dboard = Array(Char,9,9)
  for i in eachindex(iboard)
    board[i]=iboard[i].piece
  end

  for x_index in (1:11)
    for y_index in (1:11)
      if y_index==1
        if x_index==1
          print("┌")
        elseif x_index==11
          print("└")
        elseif rem(x_index,2)==0
          print("|")
        else
          print("├")
        end
      elseif y_index==11
        if x_index==1
          print("┐")
        elseif x_index==11
          print("┘")
        elseif rem(x_index,2)==0
          print("|")
        else
          print("┤")
        end
      elseif rem(y_index,2)==1
        if x_index==1
          print("┬")
        elseif x_index==11
          print("┴")
        elseif rem(x_index,2)==1
          print("┼")
        else
          print("|")
        end
      else
        if rem(x_index,2)==1
          print("-")
        else
          if board[div(x_index,2),(6-div(y_index,2))]=='k'
            print_with_color(:green, "$(board[div(x_index,2),(6-div(y_index,2))])")
            continue
          end
          print(board[div(x_index,2),(6-div(y_index,2))])
        end
      end
    end
    print("\n")
  end
end



function display()

  board = ST.loadBoard()
  global dboard = Array(Char,9,9)
  for i in eachindex(iboard)
    board[i]=iboard[i].piece
  end

for x_index in (1:19)
  for y_index in (1:19)
    if y_index==1
      if x_index==1
        print("┌")
      elseif x_index==19
        print("└")
      elseif rem(x_index,2)==0
        print("|")
      else
        print("├")
      end
    elseif y_index==19
      if x_index==1
        print("┐")
      elseif x_index==19
        print("┘")
      elseif rem(x_index,2)==0
        print("|")
      else
        print("┤")
      end
    elseif rem(y_index,2)==1
      if x_index==1
        print("┬")
      elseif x_index==19
        print("┴")
      elseif rem(x_index,2)==1
        print("┼")
      else
        print("|")
      end
    else
      if rem(x_index,2)==1
        print("-")
      else
        if board[div(x_index,2),(10-div(y_index,2))]=='k'
          print_with_color(:green, "$(board[div(x_index,2),(10-div(y_index,2))])")
          continue
        end
        print(board[div(x_index,2),(10-div(y_index,2))])
      end
    end
  end
  print("\n")
end

end#Func

end
