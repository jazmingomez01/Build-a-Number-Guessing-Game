#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

CHOOSE_NUMBER=$(( RANDOM % 1000 + 1 ))

echo "Enter your username:"

read USERNAME

USERNAME_PLAYER=$($PSQL "SELECT username, games_played, 
                         best_game  FROM  users_number 
                         WHERE username = '$USERNAME'")

if [[ -z $USERNAME_PLAYER ]]
then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    INSERT_USER=$($PSQL "INSERT INTO users_number(username, games_played, best_game) VALUES('$USERNAME', 0, NULL)")
else
    echo "$USERNAME_PLAYER" | sed 's/|/ /g' | while read USERNAME GAMES_PLAYED BEST_GAME
    do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    done
fi

echo "Guess the secret number between 1 and 1000:"
read GUESS_NUMBER
NUMBER_OF_GUESSES=1


 while ! [[ $GUESS_NUMBER =~ $CHOOSE_NUMBER ]]
  do
   
   if ! [[ $GUESS_NUMBER =~ ^[0-9]+$ ]]
   then
       echo "That is not an integer, guess again:"
       read GUESS_NUMBER
       ((NUMBER_OF_GUESSES++))
       echo "$$NUMBER_OF_GUESSES"
   
   elif [[ $CHOOSE_NUMBER -lt $GUESS_NUMBER ]]
   then
       echo "It's lower than that, guess again:"
       read GUESS_NUMBER
       ((NUMBER_OF_GUESSES++))
   else 
       echo "It's higher than that, guess again:"
       read GUESS_NUMBER
        ((NUMBER_OF_GUESSES++)) 
   fi
done

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $CHOOSE_NUMBER. Nice job!"

USER_GAMES=$($PSQL "SELECT games_played, best_game FROM users_number WHERE username = '$USERNAME'")

echo "$USER_GAMES" | sed 's/|/ /g' | while read GAMES_PLAYED BEST_GAME
do
    GAMES_PLAYED=$((GAMES_PLAYED + 1))
    
    if [[ -z $BEST_GAME || $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
    
    then
        UPDATE_USER=$($PSQL "UPDATE users_number SET games_played = $GAMES_PLAYED, best_game = $NUMBER_OF_GUESSES WHERE username = '$USERNAME'")
    
    else
        UPDATE_USER=$($PSQL "UPDATE users_number SET games_played = $GAMES_PLAYED WHERE username = '$USERNAME'")
    fi
done
