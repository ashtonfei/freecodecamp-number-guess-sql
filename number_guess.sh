#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t -c"

RANDOM_NUMBER=$(( $RANDOM % 1000 + 1 ))
# echo "GUESS what is $RANDOM_NUMBER"

MAIN_MENU(){
  echo -e "\nEnter your username:"
  # read username
  read USERNAME
  
  # if user name is < 22
  if [[ ${#USERNAME} < 22 ]]
  then
    # echo "The username should be at least 22 characters, please try another one:"
    exit 0
  fi
  
  # get user from the database
  USER_GAME_DATA=$($PSQL "SELECT username, games_played, best_game FROM games WHERE username = '$USERNAME'")
  
  if [[ ! -z $USER_GAME_DATA ]]
  then
    # if user in database
    echo $USER_GAME_DATA | while read NAME BAR GAMES BAR BEST
    do
      echo -e "\nWelcome back, $USERNAME! You have played $GAMES games, and your best game took $BEST guesses."
    done
  else
    # if user not in database
    # insert username to the database
    INSERT_USER_RESULT=$($PSQL "INSERT INTO games (username) VALUES('$USERNAME')")
    # get user from the database
    USER_GAME_DATA=$($PSQL "SELECT username, games_played, best_game FROM games WHERE username = '$USERNAME'")
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  fi
  GUESS_MENU
}

NUMBER_OF_GUESSSES=0
GUESS_MENU(){
  (( NUMBER_OF_GUESSSES++ ))
  if [[ $1 ]]
  then
    echo -e $1
  else
    echo -e "\nGuess the secret number between 1 and 1000:"
  fi
  read USER_INPUT

  if [[ $USER_INPUT == $RANDOM_NUMBER ]]
  then
    BEST_GAME=$($PSQL "SELECT best_game FROM games WHERE username='$USERNAME'")
    BEST_GAME=$(( $BEST_GAME * 1 ))
    if [[ $BEST_GAME == 0 ]]
    then
      BEST_GAME=$NUMBER_OF_GUESSSES
    elif [[ $BEST_GAME > $NUMBER_OF_GUESSSES ]]
    then
      BEST_GAME=$NUMBER_OF_GUESSSES
    fi

    GAMES_PLAYED=$($PSQL "SELECT games_played FROM games WHERE username='$USERNAME'")
    GAMES_PLAYED=$(( $GAMES_PLAYED + 1))
    UDPATE_USER_GAME_DATA=$($PSQL "UPDATE games SET games_played=$GAMES_PLAYED, best_game=$BEST_GAME WHERE username='$USERNAME'")

    echo -e "\nYou guessed it in $NUMBER_OF_GUESSSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
    exit 0
  elif [[ ! $USER_INPUT =~ ^[0-9]+$ ]]
  then
    GUESS_MENU "\nThat is not an integer, guess again:"
  elif  [[ $USER_INPUT > $RANDOM_NUMBER ]]
  then
    GUESS_MENU "\nIt's lower than that, guess again:"
  elif [[ $USER_INPUT < $RANDOM_NUMBER ]]
  then
    GUESS_MENU "\nIt's higher than that, guess again:"
  fi
}

MAIN_MENU
