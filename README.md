RGXP Data Tools
===============

This is a collection of tools for working with data from games made with RPG Maker XP.

Currently, it can be used to build an SQLite database for viewing the data from a specific game.

Installation
------------

The terminal commands shown are just examples, and should be tweaked to be appropriate for your system and your preferences.

1. Clone this repository to a local directory of your choice.

        git clone https://github.com/Andrew-Foote/rpgxp.git

2. Set the current working directory to the root directory of the repository.

        cd rpgxp

3. Create a Python virtual environment in a directory called `env` within the root directory.

        python3 -m venv env

4. Install the required Python modules within the virtual environment.

        env/bin/pip install -r requirements.txt

5. Run the script named `run` in the root directory and pass the path to the `Data` folder within the game you want to inspect as its argument.

        ./run ~/games/MyGame/Data
