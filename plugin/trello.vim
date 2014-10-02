if !has('python')
    echo "Error: Requires vim compiled with python"
    finish
endif

function! Cards()

python << EOF

import vim
import urllib2
import os
import json
import codecs

CON_FILE = '.trello-vim'

f = codecs.open(os.path.expanduser('~') + '/' + CON_FILE)
keys = f.read().split('\n')
KEY = keys[0]
TOKEN = keys[1]
KEY_TOKEN = {'key': KEY, 'token': TOKEN}
CARDS_URL = 'https://trello.com/1/members/my/cards?key={key}&token={token}'.format(**KEY_TOKEN)
LISTS_URL = 'https://trello.com/1/lists/%s?key={key}&token={token}'.format(**KEY_TOKEN)

try:
    request = json.loads(urllib2.urlopen(CARDS_URL).read())
    vim.command("vnew trello")
    del vim.current.buffer[:]
    vim.current.buffer[0] = "Cards assigned to you"
    vim.current.buffer.append(35 * "=")

    columns = {}
    for card in request:
        name = card['name'].encode("UTF-8")
        url = card['url'].encode("UTF-8")
        labels = []
        for label in card['labels']:
            labels.append(label['name'].encode('UTF-8') or 'Unnamed')
        column_id = card['idList']
        column_name = columns.get(column_id, None)
        if not column_name:
            COLUMN_URL = LISTS_URL % column_id
            column_request = json.loads(urllib2.urlopen(COLUMN_URL).read())
            columns.update({column_id: column_request['name'].encode('UTF-8')})

        vim.current.buffer.append("→→ %s" % column_request['name'].encode('UTF-8'))
        vim.current.buffer.append("→ %s" % name)
        if labels:
            all_labels = ', '.join(labels)
            vim.current.buffer.append("Labels: %s" % all_labels)
        vim.current.buffer.append("URL: %s" % url)
        vim.current.buffer.append(35 * "-")

except Exception, e:
    print e

EOF

endfunction

command! -nargs=0 Cards call Cards()
