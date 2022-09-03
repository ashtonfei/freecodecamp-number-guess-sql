#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

RANDOM_NUMBER=$(( $RANDOM % 1000 + 1 ))
# echo "GUESS what is $RANDOM_NUMBER"
NUMBER_OF_GUESSSES=0


MAIN_MENU(){
  echo "Enter your username:"
  # read username
  read USERNAME
  # get user from the database
  USER_GAME_DATA=$($PSQL "SELECT username, games_played, best_game FROM games WHERE username = '$USERNAME'")
  if [[ -z $USER_GAME_DATA ]]
  then
    # if user not in database
    echo "Welcome, $USERNAME! It looks like this is your first time here."
  else
    # if user in database
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM games WHERE username = '$USERNAME'")
    BEST_GAME=$($PSQL "SELECT best_game FROM games WHERE username = '$USERNAME'")
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi
  echo "Guess the secret number between 1 and 1000:"
  GUESS_MENU
  exit 0
}


GUESS_MENU(){
  if [[ $1 ]]
  then
    echo $1
  fi
  read USER_INPUT
  (( NUMBER_OF_GUESSSES++ ))
  if [[ $USER_INPUT == $RANDOM_NUMBER ]]
  then
    if [[ -z $USER_GAME_DATA ]]
    then
      INSERT_USER_GAME_DATA=$($PSQL "INSERT INTO games(username, games_played, best_game) VALUES('$USERNAME', 1, $NUMBER_OF_GUESSSES)")
    else
      BEST_GAME=$($PSQL "SELECT best_game FROM games WHERE username='$USERNAME'")
      BEST_GAME=$(( $BEST_GAME * 1 ))
      if (( BEST_GAME == 0 ))
      then
        BEST_GAME=$NUMBER_OF_GUESSSES
      elif (( BEST_GAME > NUMBER_OF_GUESSSES ))
      then
        BEST_GAME=$NUMBER_OF_GUESSSES
      fi
      GAMES_PLAYED=$($PSQL "SELECT games_played FROM games WHERE username='$USERNAME'")
      GAMES_PLAYED=$(( $GAMES_PLAYED + 1))
      UDPATE_USER_GAME_DATA=$($PSQL "UPDATE games SET games_played=$GAMES_PLAYED, best_game=$BEST_GAME WHERE username='$USERNAME'")
    fi

    echo "You guessed it in $NUMBER_OF_GUESSSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
  elif [[ ! $USER_INPUT =~ ^[0-9]+$ ]]
  then
    GUESS_MENU "That is not an integer, guess again:"
  elif  [[ $USER_INPUT > $RANDOM_NUMBER ]]
  then
    GUESS_MENU "It's lower than that, guess again:"
  elif [[ $USER_INPUT < $RANDOM_NUMBER ]]
  then
    GUESS_MENU "It's higher than that, guess again:"
  fi
}

MAIN_MENU
