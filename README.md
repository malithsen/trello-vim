A barebone vim plugin to fetch user assigned cards from Trello

## Requirements##
* Vim compiled with Python
* Trello API keys

## Installation##
####Using Vundle####

Append this to .vimrc
<pre><code>Plugin 'malithsen/trello-vim'
</code></pre>

Then install in the usual way
<pre><code>:PluginInstall
</code></pre>

Run INSTALL.py and follow the instructions
<pre><code>python ~/.vim/bundle/trello-vim/INSTALL.py
</code></pre>

Above step is an one time procedure to set up trello oauth tokens

## Usage##
Open assigned cards in a new buffer
<pre><code>:Cards
</code></pre>

