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
configs = json.loads(f.read())

SHOW_CARD_URL = configs['url']
SHOW_LABELS = configs['label']
SHOW_DONE_CARDS = configs['done_cards']

KEY_TOKEN = {'key': configs['key'], 'token': configs['token']}
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
        column_id = card['idList']
        column_name = columns.get(column_id, None)
        if not column_name:
            COLUMN_URL = LISTS_URL % column_id
            column_request = json.loads(urllib2.urlopen(COLUMN_URL).read())
            column_name = column_request['name'].encode('UTF-8')
            columns.update({column_id: column_name})

        if SHOW_DONE_CARDS or column_name != 'Done':
            vim.current.buffer.append("→→ %s" % column_request['name'].encode('UTF-8'))
            vim.current.buffer.append("→ %s" % name)
            if SHOW_LABELS:
                labels = []
                for label in card['labels']:
                    labels.append(label['name'].encode('UTF-8') or label['color'].encode('UTF-8'))
                all_labels = ', '.join(labels)
                if all_labels:
                    vim.current.buffer.append("Labels: %s" % all_labels)
            if SHOW_CARD_URL:
                vim.current.buffer.append("URL: %s" % url)
            vim.current.buffer.append(35 * "-")

except Exception, e:
    print e

EOF

endfunction

command! -nargs=0 Cards call Cards()
