###Start credentials.py setup###

import tweepy


consumer_key="your_consumer_key"
consumer_secret="your_consumer_secret_key"

access_token="your_access_token"
access_token_secret="your_secret_ access_token"


auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_token_secret)

api = tweepy.API(auth)

###End credentials.py setup###
