#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# truncate table to remove existing rows
echo $($PSQL "TRUNCATE teams, games")

# read variables from CSV file, create a while loop to run while file is open
cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do

  # ignore first line of the file
  if [[ $YEAR != year ]]
  then

    # Get id of winners from the teams table
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")

    # If team id not found
    if [[ -z $WINNER_ID ]]
    then

      # Insert winners into teams table
      INSERT_WINNERS_RESULT=$($PSQL "INSERT INTO teams(name) VALUES ('$WINNER')")
      if [[ $INSERT_WINNERS_RESULT == "INSERT 0 1" ]]
      then

        # confirm that team was added
        echo Inserted team: $WINNER into teams
      fi
    fi

    # get id of opponents from the teams table
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")

    # If opponent_id not found
    if [[ -z $OPPONENT_ID ]]
    then

      # Insert opponents into teams table
      INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES ('$OPPONENT')")

      # confirm opponent was inserted
      if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted team: $OPPONENT into teams
      fi
    fi

    # check if game is already in games
    GAME_ID=$($PSQL "SELECT game_id FROM games WHERE year = $YEAR AND round = '$ROUND' and winner_id = (SELECT team_id FROM teams WHERE name = '$WINNER')")
    
    # if not
    if [[ -z $GAME_ID ]]
    then

      # generate winner_id
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")

      # generate opponent_id
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
    
      # insert into games table
      INSERTED_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, winner_goals, opponent_id, opponent_goals) VALUES ($YEAR, '$ROUND', $WINNER_ID, $WINNER_GOALS, $OPPONENT_ID, $OPPONENT_GOALS)")
    
      # confirm insert worked
      if [[ $INSERTED_GAME_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted $WINNER vs $OPPONENT, $YEAR into games
      fi
    fi
  fi

done