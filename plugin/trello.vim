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
URL = 'https://trello.com/1/members/my/cards?key=%s&token=%s' % (KEY, TOKEN)

try:
    request = json.loads(urllib2.urlopen(URL).read())
    vim.command("vnew trello")
    del vim.current.buffer[:]
    vim.current.buffer[0] = "Cards assigned to you"
    vim.current.buffer.append(35*"-")

    for x in request:
        name = x['name'].encode("utf-8")
        url = x['url'].encode("utf-8")
        vim.current.buffer.append("→ %s"%name)
        vim.current.buffer.append("URL: %s"%url)
        vim.current.buffer.append(35*"-")

except Exception, e:
    print e

EOF

endfunction

command! -nargs=0 Cards call Cards()