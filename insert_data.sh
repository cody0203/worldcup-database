#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo "$($PSQL "TRUNCATE TABLE games, teams;")"

INSERTED="INSERT 0 1"
WINNER_ID=""
OPPONENT_ID=""

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != 'year' ]]
  then
    # get team id
    WINNER_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")"
    OPPONENT_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")"
    # if not exist
    if [[ -z $WINNER_ID  ]]
    then
      # add team
      WINNER_INSERTED="$($PSQL "INSERT INTO teams(name) VALUES('$WINNER');")"

      # set id
      if [[ $WINNER_INSERTED == $INSERTED ]]
      then
        WINNER_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")"
      fi
    fi

    if [[ -z $OPPONENT_ID ]]
    then
      OPPONENT_INSERTED="$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');")"

      # set id
      if [[ $WINNER_INSERTED == $INSERTED ]]
      then
        OPPONENT_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")"
      fi
    fi

    if [[ $WINNER_ID && $OPPONENT_ID ]]
    then
      echo "$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals)
      VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);")"
    fi
  fi
done