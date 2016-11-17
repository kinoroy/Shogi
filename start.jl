#=start.jl - Starts the game and accepts 3 command line arguments,<filename> => database
<type> => gameType, <cheating> => cheating
=#
include("board.jl")
module start

using BM


using SQLite

database = ARGS[1] #/path/to/database/file {string}
gameTypeDict = Dict("S" => "standard","M" => "minishogi")
gameType = gameTypeDict[ARGS[2]] #Either "standard" or "minishogi" {string}
cheatingDict = Dict("T" => "cheating", "F" => "legal")
cheating = cheatingDict[ARGS[3]] #Either "cheating" or "legal" {string}=#
#captures = Array(square(),0)
seed = time() #current unix time
db = SQLite.DB(database) #Opens the database gamefile
SQLite.query(db,"CREATE TABLE moves (move_number,move_type,sourcex,sourcey,targetx,targety,option,i_am_cheating);")
SQLite.query(db,"CREATE TABLE meta (key,value);")
SQLite.query(db,"""INSERT INTO meta (key,value) VALUES ("type","$(gameType)");""")
SQLite.query(db,"""INSERT INTO meta (key,value) VALUES ("legality","$(cheating)");""")
SQLite.query(db,"""INSERT INTO meta (key,value) VALUES ("seed","$(seed)");""")

end
