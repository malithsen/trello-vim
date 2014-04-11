### Modified version of https://github.com/sarumont/py-trello/blob/master/trello/util.py

import os
import urlparse
import codecs

import oauth2 as oauth

CON_FILE = '.trello-vim'

def create_oauth_token():
    """
    Script to obtain an OAuth token from Trello.

    More info on token scope here:
        https://trello.com/docs/gettingstarted/#getting-a-token-from-a-user
    """
    request_token_url = 'https://trello.com/1/OAuthGetRequestToken'
    authorize_url = 'https://trello.com/1/OAuthAuthorizeToken'
    access_token_url = 'https://trello.com/1/OAuthGetAccessToken'


    print "Visit https://trello.com/1/appKey/generate to obtain API keys" + "\n"
    expiration = 'never'
    scope = 'read'
    trello_key = str(raw_input('API KEY >'))
    trello_secret = str(raw_input('API SECRET >'))

    consumer = oauth.Consumer(trello_key, trello_secret)
    client = oauth.Client(consumer)

    # Step 1: Get a request token. This is a temporary token that is used for
    # having the user authorize an access token and to sign the request to obtain
    # said access token.

    resp, content = client.request(request_token_url, "GET")
    if resp['status'] != '200':
        raise Exception("Invalid response %s." % resp['status'])

    request_token = dict(urlparse.parse_qsl(content))

    print "Request Token:"
    print "    - oauth_token        = %s" % request_token['oauth_token']
    print "    - oauth_token_secret = %s" % request_token['oauth_token_secret']
    print

    # Step 2: Redirect to the provider. Since this is a CLI script we do not
    # redirect. In a web application you would redirect the user to the URL
    # below.

    print "Go to the following link in your browser:"
    print "{authorize_url}?oauth_token={oauth_token}&scope={scope}&expiration={expiration}".format(
        authorize_url=authorize_url,
        oauth_token=request_token['oauth_token'],
        expiration=expiration,
        scope=scope,
    )

    # After the user has granted access to you, the consumer, the provider will
    # redirect you to whatever URL you have told them to redirect to. You can
    # usually define this in the oauth_callback argument as well.
    accepted = 'n'
    while accepted.lower() == 'n':
        accepted = raw_input('Have you authorized me? (y/n) ')
    oauth_verifier = raw_input('What is the PIN? ')

    # Step 3: Once the consumer has redirected the user back to the oauth_callback
    # URL you can request the access token the user has approved. You use the
    # request token to sign this request. After this is done you throw away the
    # request token and use the access token returned. You should store this
    # access token somewhere safe, like a database, for future use.
    token = oauth.Token(request_token['oauth_token'],
                        request_token['oauth_token_secret'])
    token.set_verifier(oauth_verifier)
    client = oauth.Client(consumer, token)

    resp, content = client.request(access_token_url, "POST")
    access_token = dict(urlparse.parse_qsl(content))

    f = codecs.open(os.path.expanduser('~') + '/' + CON_FILE, 'a')
    f.write(trello_key+'\n')
    f.write(access_token['oauth_token'])
    f.close

    print "Access Token:"
    print "    - oauth_token        = %s" % access_token['oauth_token']
    print
    print "key and token are now saved in .trello-vim file in home directory."
    print "You are ready to use the plugin"

if __name__ == '__main__':
    create_oauth_token()